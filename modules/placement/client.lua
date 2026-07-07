-- In-world placement builder for admin/editor tools.
-- First-party, native-based (+ ox_lib for model load / poly preview) — no external resource dependency.
-- Ported from the copy previously forked into oxide-developer / oxide-police / oxide-dealerships so
-- consumers stop rebuilding it. Every customer already runs o-link, so it lives here.
--
-- AWAIT-STYLE API: the builder blocks and RETURNS the captured value. o-link exports run in o-link's
-- VM and a Lua callback argument won't marshal across the resource boundary, so callback-style
-- (onConfirm/onCancel) can't work cross-resource — the consumer awaits the return instead:
--     local coords = olink.placement.GhostPed({ model = 'a_m_y_business_03' })  -- {x,y,z,w} or nil
--
-- Controls: mouse aim to position, scroll wheel to rotate heading (LSHIFT = coarse),
--           LMB confirm, RMB / ESC cancel. Polygon: freecam + Enter place / arrows nudge / Space save.

if not olink._guardImpl('Placement', 'placement', false) then return end

local active = false
local polyActive = false
local previewEntity = nil
local previewModelHash = nil
local currentPromise = nil

local ROT_STEP = 5.0
local ROT_STEP_FAST = 15.0
local RAYCAST_DIST = 200.0
local MARKER_R, MARKER_G, MARKER_B = 232, 176, 68

-- ---------------------------------------------------------------------------
-- Native on-screen HUD (replaces the consumer-NUI hint bar the fork used, since
-- o-link can't message a consumer's NUI).
-- ---------------------------------------------------------------------------
local function drawHint(lines)
    local y = 0.80
    for _, line in ipairs(lines) do
        SetTextFont(4)
        SetTextScale(0.36, 0.36)
        SetTextColour(255, 255, 255, 220)
        SetTextOutline()
        SetTextEntry('STRING')
        AddTextComponentSubstringPlayerName(line)
        DrawText(0.5 - 0.14, y)
        y = y + 0.028
    end
end

local function unloadModel()
    if previewModelHash then
        SetModelAsNoLongerNeeded(previewModelHash)
        previewModelHash = nil
    end
end

local function destroyPreview()
    if previewEntity and DoesEntityExist(previewEntity) then
        if IsEntityAVehicle(previewEntity) then
            DeleteEntity(previewEntity)
        else
            DeletePed(previewEntity)
        end
    end
    previewEntity = nil
end

local function ghostify(entity)
    SetEntityAlpha(entity, 150, false)
    SetEntityCollision(entity, false, false)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    if IsEntityAPed(entity) then
        SetBlockingOfNonTemporaryEvents(entity, true)
        TaskStandStill(entity, -1)
    elseif IsEntityAVehicle(entity) then
        SetVehicleEngineOn(entity, false, true, true)
        SetVehicleDoorsLocked(entity, 2)
        SetVehicleNumberPlateText(entity, 'PREVIEW')
    end
end

-- Cast a ray from the gameplay camera; fall back to a point along the forward
-- vector so the marker still tracks when aiming at the sky.
local function raycastFromCamera()
    local camCoord = GetGameplayCamCoord()
    local camRot   = GetGameplayCamRot(2)
    local rx = math.rad(camRot.x)
    local rz = math.rad(camRot.z)
    local cosX = math.cos(rx)
    local fwd = vector3(-math.sin(rz) * math.abs(cosX), math.cos(rz) * math.abs(cosX), math.sin(rx))
    local endPos = camCoord + fwd * RAYCAST_DIST

    local handle = StartShapeTestRay(camCoord.x, camCoord.y, camCoord.z, endPos.x, endPos.y, endPos.z, -1, PlayerPedId(), 0)
    local _, hit, hitCoords = GetShapeTestResult(handle)
    if hit == 1 or hit == true then
        return true, hitCoords
    end
    return false, endPos
end

local function resolve(result)
    if not active then return end
    active = false
    destroyPreview()
    unloadModel()
    local p = currentPromise
    currentPromise = nil
    if p then p:resolve(result) end
end

-- Shared loop for point/ped/vehicle placement.
---@param kind 'ped' | 'vehicle' | 'coord'
local function startLoop(kind, o)
    local currentHeading = (o.initialHeading or GetEntityHeading(PlayerPedId())) or 0.0
    local lastHitCoords = nil
    local zOffset = (kind == 'ped') and 1.0 or 0.0

    CreateThread(function()
        while active do
            local _, hitCoords = raycastFromCamera()
            lastHitCoords = hitCoords

            if previewEntity and DoesEntityExist(previewEntity) then
                SetEntityCoordsNoOffset(previewEntity, hitCoords.x, hitCoords.y, hitCoords.z + zOffset)
                if kind ~= 'coord' then
                    SetEntityHeading(previewEntity, currentHeading)
                end
            end

            local groundZ = hitCoords.z - 0.98
            DrawMarker(
                1, hitCoords.x, hitCoords.y, groundZ, 0, 0, 0, 0, 0, 0,
                kind == 'vehicle' and 2.4 or 0.9,
                kind == 'vehicle' and 5.2 or 0.9,
                0.08, MARKER_R, MARKER_G, MARKER_B, 130, false, false, 2, false, nil, nil, false
            )

            if kind == 'coord' then
                drawHint({ 'Placement', 'LMB  Confirm', 'RMB / ESC  Cancel' })
            else
                drawHint({ 'Placement', 'Scroll  Rotate  (LSHIFT coarse)', 'LMB  Confirm', 'RMB / ESC  Cancel' })
            end
            Wait(0)
        end
    end)

    CreateThread(function()
        while active do
            if kind ~= 'coord' then
                local fast = IsControlPressed(0, 21) -- LSHIFT
                local step = fast and ROT_STEP_FAST or ROT_STEP
                if IsControlJustPressed(0, 14) or IsDisabledControlJustPressed(0, 14) then
                    currentHeading = (currentHeading - step) % 360.0
                end
                if IsControlJustPressed(0, 15) or IsDisabledControlJustPressed(0, 15) then
                    currentHeading = (currentHeading + step) % 360.0
                end
            end

            if (IsDisabledControlJustPressed(0, 24) or IsControlJustPressed(0, 24)) and lastHitCoords then
                local result
                if kind == 'coord' then
                    result = {
                        x = tonumber(('%.4f'):format(lastHitCoords.x)) + 0.0,
                        y = tonumber(('%.4f'):format(lastHitCoords.y)) + 0.0,
                        z = tonumber(('%.4f'):format(lastHitCoords.z)) + 0.0,
                    }
                else
                    result = {
                        x = tonumber(('%.4f'):format(lastHitCoords.x)) + 0.0,
                        y = tonumber(('%.4f'):format(lastHitCoords.y)) + 0.0,
                        z = tonumber(('%.4f'):format(lastHitCoords.z)) + 0.0,
                        w = tonumber(('%.2f'):format(currentHeading)) + 0.0,
                    }
                end
                resolve(result)
                return
            end

            if IsDisabledControlJustPressed(0, 25) or IsControlJustPressed(0, 25)
                or IsDisabledControlJustPressed(0, 200) or IsControlJustPressed(0, 200) then
                resolve(nil)
                return
            end

            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisablePlayerFiring(PlayerId(), true)
            Wait(0)
        end
    end)
end

local function loadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelInCdimage(hash) then return nil end
    lib.requestModel(hash, 5000)
    if not HasModelLoaded(hash) then return nil end
    return hash
end

-- ---------------------------------------------------------------------------
-- Public builders (await-style)
-- ---------------------------------------------------------------------------

---Raycast-only point picker. Returns { x, y, z } or nil.
local function Coord(o)
    if active then return nil end
    o = o or {}
    active = true
    currentPromise = promise.new()
    startLoop('coord', o)
    return Citizen.Await(currentPromise)
end

---Ghost ped picker. Returns { x, y, z, w } or nil.
local function GhostPed(o)
    if active then return nil end
    o = o or {}
    local hash = loadModel(o.model or 'a_m_y_business_03')
    if not hash then return nil end

    active = true
    currentPromise = promise.new()
    previewModelHash = hash
    local pc = GetEntityCoords(PlayerPedId())
    previewEntity = CreatePed(4, hash, pc.x, pc.y, pc.z, 0.0, false, false)
    if not previewEntity or previewEntity == 0 then
        active = false
        currentPromise = nil
        unloadModel()
        return nil
    end
    ghostify(previewEntity)
    startLoop('ped', o)
    return Citizen.Await(currentPromise)
end

---Ghost vehicle picker. Returns { x, y, z, w } or nil.
local function GhostVehicle(o)
    if active then return nil end
    o = o or {}
    if type(o.model) ~= 'string' or o.model == '' then return nil end
    local hash = loadModel(o.model)
    if not hash then return nil end

    active = true
    currentPromise = promise.new()
    previewModelHash = hash
    local pc = GetEntityCoords(PlayerPedId())
    previewEntity = CreateVehicle(hash, pc.x, pc.y, pc.z, 0.0, false, false)
    if not previewEntity or previewEntity == 0 then
        active = false
        currentPromise = nil
        unloadModel()
        return nil
    end
    ghostify(previewEntity)
    startLoop('vehicle', o)
    return Citizen.Await(currentPromise)
end

local function IsActive()
    return active or polyActive == true
end

local function Cancel()
    if active then resolve(nil) end
end

-- ---------------------------------------------------------------------------
-- Polygon builder (freecam zone authoring). Returns { shape, minZ, maxZ } or nil.
-- Native HUD instead of the fork's consumer-NUI hint messages.
-- ---------------------------------------------------------------------------
local POLY_THICKNESS_DEFAULT = 6.0
local POLY_NUDGE_SPEEDS = { 0.05, 0.25, 1.0, 5.0 }
local POLY_DEFAULT_NUDGE_INDEX = 2
local POLY_FREECAM_SPEED_BASE = 0.25
local POLY_FREECAM_MOUSE_SENS = 6.0

local function loadExistingPoints(existing, fallbackZ)
    local pts = {}
    if type(existing) ~= 'table' then return pts, POLY_THICKNESS_DEFAULT end
    local shape = existing.shape or existing.points
    if type(shape) ~= 'table' then return pts, POLY_THICKNESS_DEFAULT end
    for _, p in ipairs(shape) do
        local px = tonumber(p.x or p[1])
        local py = tonumber(p.y or p[2])
        local pz = tonumber(p.z or p[3]) or fallbackZ
        if px and py then pts[#pts + 1] = vector3(px + 0.0, py + 0.0, pz + 0.0) end
    end
    local thickness
    if existing.minZ and existing.maxZ then
        thickness = (tonumber(existing.maxZ) - tonumber(existing.minZ))
    end
    if not thickness or thickness < 1.0 then thickness = POLY_THICKNESS_DEFAULT end
    return pts, thickness + 0.0
end

local function Polygon(o)
    if active or polyActive then return nil end
    o = o or {}

    polyActive = true
    local p = promise.new()

    local ped = PlayerPedId()
    local startCoords = GetEntityCoords(ped)
    local startHeading = GetEntityHeading(ped)

    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, false)
    SetEntityCollision(ped, false, false)
    SetEntityInvincible(ped, true)

    local points, thickness = loadExistingPoints(o.existing, startCoords.z)
    local mode = 'place'
    local selectedIdx = 0
    local nudgeIdx = POLY_DEFAULT_NUDGE_INDEX
    local debugZone = nil

    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(cam, startCoords.x, startCoords.y, startCoords.z + 1.5)
    SetCamRot(cam, 0.0, 0.0, startHeading, 2)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    local camRot = vector3(0.0, 0.0, startHeading)

    local function clearDebugZone()
        if debugZone and debugZone.remove then
            pcall(function() debugZone:remove() end)
            debugZone = nil
        end
    end

    local function cleanup()
        clearDebugZone()
        RenderScriptCams(false, true, 500, true, true)
        if cam then
            SetCamActive(cam, false)
            DestroyCam(cam, false)
            cam = nil
        end
        FreezeEntityPosition(ped, false)
        SetEntityVisible(ped, true, false)
        SetEntityCollision(ped, true, true)
        SetEntityInvincible(ped, false)
        polyActive = false
    end

    local function raycastFromCam()
        local cc = GetCamCoord(cam)
        local cr = GetCamRot(cam, 2)
        local rZ = math.rad(cr.z)
        local rX = math.rad(cr.x)
        local cosX = math.cos(rX)
        local dir = vector3(-math.sin(rZ) * cosX, math.cos(rZ) * cosX, math.sin(rX))
        local dest = cc + dir * 200.0
        local _, hit, hitCoords = GetShapeTestResult(
            StartShapeTestRay(cc.x, cc.y, cc.z, dest.x, dest.y, dest.z, 17, 0, 7)
        )
        if hit == 1 then return hitCoords end
        return nil
    end

    local function selectNearest(hitPos)
        if #points == 0 then return end
        local bestDist, bestIdx = 2.0, 0
        for i, pt in ipairs(points) do
            local d = #(pt - hitPos)
            if d < bestDist then bestDist = d; bestIdx = i end
        end
        if bestIdx > 0 then selectedIdx = bestIdx end
    end

    local function refreshPreview()
        if not debugZone then return end
        clearDebugZone()
        if #points >= 3 then
            debugZone = lib.zones.poly({ points = points, thickness = thickness, debug = true })
        end
    end

    local function togglePreview()
        if debugZone then clearDebugZone(); return end
        if #points < 3 then return end
        debugZone = lib.zones.poly({ points = points, thickness = thickness, debug = true })
    end

    local function drawPoints()
        local halfT = thickness / 2
        local numPoints = #points
        for i, pt in ipairs(points) do
            local r, g, b = 232, 176, 68
            if i == selectedIdx then r, g, b = 255, 220, 0 end
            DrawMarker(28, pt.x, pt.y, pt.z, 0,0,0, 0,0,0, 0.18, 0.18, 0.18, r, g, b, 220, false, true, 2, false, nil, nil, false)
            DrawLine(pt.x, pt.y, pt.z - halfT, pt.x, pt.y, pt.z + halfT, r, g, b, 200)
        end
        if numPoints >= 2 then
            for i = 1, numPoints do
                local p1 = points[i]
                local p2 = points[i % numPoints + 1]
                DrawLine(p1.x, p1.y, p1.z + halfT, p2.x, p2.y, p2.z + halfT, 232, 176, 68, 200)
                DrawLine(p1.x, p1.y, p1.z - halfT, p2.x, p2.y, p2.z - halfT, 232, 176, 68, 200)
            end
        end
        if numPoints >= 3 then
            for i = 2, numPoints - 1 do
                local a, b2, c = points[1], points[i], points[i + 1]
                DrawPoly(a.x, a.y, a.z + halfT, b2.x, b2.y, b2.z + halfT, c.x, c.y, c.z + halfT, 232, 176, 68, 50)
                DrawPoly(c.x, c.y, c.z + halfT, b2.x, b2.y, b2.z + halfT, a.x, a.y, a.z + halfT, 232, 176, 68, 50)
            end
        end
    end

    CreateThread(function()
        while polyActive do
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)

            local mouseX = GetDisabledControlNormal(0, 1) * POLY_FREECAM_MOUSE_SENS
            local mouseY = GetDisabledControlNormal(0, 2) * POLY_FREECAM_MOUSE_SENS
            camRot = vector3(math.max(-89.0, math.min(89.0, camRot.x - mouseY)), camRot.y, camRot.z - mouseX)
            SetCamRot(cam, camRot.x, camRot.y, camRot.z, 2)

            local rZ = math.rad(camRot.z)
            local rX = math.rad(camRot.x)
            local cosZ, sinZ = math.cos(rZ), math.sin(rZ)
            local cosX, sinX = math.cos(rX), math.sin(rX)
            local v = vector3(0, 0, 0)
            if IsDisabledControlPressed(0, 32) then v = v + vector3(-sinZ * cosX, cosZ * cosX, sinX) end
            if IsDisabledControlPressed(0, 33) then v = v + vector3( sinZ * cosX, -cosZ * cosX, -sinX) end
            if IsDisabledControlPressed(0, 34) then v = v + vector3(-cosZ, -sinZ, 0) end
            if IsDisabledControlPressed(0, 35) then v = v + vector3( cosZ,  sinZ, 0) end
            if IsDisabledControlPressed(0, 38) then v = v + vector3(0, 0, 1) end
            if IsDisabledControlPressed(0, 44) then v = v + vector3(0, 0, -1) end

            local mult = 1.0
            if IsDisabledControlPressed(0, 21) and selectedIdx == 0 then mult = 3.0 end
            if IsDisabledControlPressed(0, 36) then mult = 0.3 end

            local frameMult = GetFrameTime() * 60.0
            local pos = GetCamCoord(cam)
            local newPos = pos + (v * POLY_FREECAM_SPEED_BASE * mult * frameMult)
            SetCamCoord(cam, newPos.x, newPos.y, newPos.z)

            local hitPos = raycastFromCam()
            drawPoints()
            if hitPos then
                DrawMarker(28, hitPos.x, hitPos.y, hitPos.z, 0,0,0, 0,0,0, 0.1, 0.1, 0.1, 0, 200, 255, 220, false, true, 2, false, nil, nil, false)
            end
            drawHint({
                ('Zone builder  [%s]  points: %d  thickness: %.1f'):format(mode, #points, thickness),
                'WASD/Q/E  Fly   Enter  Place/Select   RMB  Select',
                'Arrows  Nudge (Tab speed)   PgUp/PgDn  Thickness   R  Mode   P  Preview',
                'Del  Remove   Backspace  Clear   Space  Save   ESC  Cancel',
            })

            if IsDisabledControlJustPressed(0, 18) then
                if mode == 'place' and hitPos then
                    points[#points + 1] = vector3(
                        tonumber(('%.4f'):format(hitPos.x)) + 0.0,
                        tonumber(('%.4f'):format(hitPos.y)) + 0.0,
                        tonumber(('%.4f'):format(hitPos.z)) + 0.0)
                    selectedIdx = #points
                    refreshPreview()
                elseif mode == 'edit' and hitPos then
                    selectNearest(hitPos)
                end
            end
            if IsDisabledControlJustPressed(0, 25) and hitPos then selectNearest(hitPos) end

            if selectedIdx > 0 and selectedIdx <= #points then
                local nudge = POLY_NUDGE_SPEEDS[nudgeIdx]
                local pt = points[selectedIdx]
                local moved = false
                if IsDisabledControlPressed(0, 172) then
                    points[selectedIdx] = IsDisabledControlPressed(0, 21) and vector3(pt.x, pt.y, pt.z + nudge) or vector3(pt.x, pt.y + nudge, pt.z); moved = true
                end
                if IsDisabledControlPressed(0, 173) then
                    pt = points[selectedIdx]
                    points[selectedIdx] = IsDisabledControlPressed(0, 21) and vector3(pt.x, pt.y, pt.z - nudge) or vector3(pt.x, pt.y - nudge, pt.z); moved = true
                end
                if IsDisabledControlPressed(0, 174) then pt = points[selectedIdx]; points[selectedIdx] = vector3(pt.x - nudge, pt.y, pt.z); moved = true end
                if IsDisabledControlPressed(0, 175) then pt = points[selectedIdx]; points[selectedIdx] = vector3(pt.x + nudge, pt.y, pt.z); moved = true end
                if moved then refreshPreview() end
            end

            if IsDisabledControlJustPressed(0, 37) then nudgeIdx = nudgeIdx % #POLY_NUDGE_SPEEDS + 1 end
            if IsDisabledControlJustPressed(0, 45) then mode = mode == 'place' and 'edit' or 'place' end
            if IsDisabledControlJustPressed(0, 10) then thickness = math.min(50.0, thickness + (IsDisabledControlPressed(0, 21) and 5.0 or 1.0)); refreshPreview() end
            if IsDisabledControlJustPressed(0, 11) then thickness = math.max(1.0, thickness - (IsDisabledControlPressed(0, 21) and 5.0 or 1.0)); refreshPreview() end
            if IsDisabledControlJustPressed(0, 199) then togglePreview() end

            if IsDisabledControlJustPressed(0, 178) then
                if mode == 'edit' and selectedIdx > 0 and selectedIdx <= #points then
                    table.remove(points, selectedIdx)
                    if selectedIdx > #points then selectedIdx = #points end
                elseif #points > 0 then
                    points[#points] = nil
                    if selectedIdx > #points then selectedIdx = #points end
                end
                refreshPreview()
            end
            if IsDisabledControlJustPressed(0, 194) then points = {}; selectedIdx = 0; clearDebugZone() end

            if IsDisabledControlJustPressed(0, 22) and #points >= 3 then
                local sumZ, outShape = 0.0, {}
                for i, pt in ipairs(points) do
                    outShape[i] = {
                        x = tonumber(('%.4f'):format(pt.x)) + 0.0,
                        y = tonumber(('%.4f'):format(pt.y)) + 0.0,
                        z = tonumber(('%.4f'):format(pt.z)) + 0.0,
                    }
                    sumZ = sumZ + pt.z
                end
                local avgZ = sumZ / #points
                cleanup()
                p:resolve({
                    shape = outShape,
                    minZ  = tonumber(('%.2f'):format(avgZ - thickness / 2)) + 0.0,
                    maxZ  = tonumber(('%.2f'):format(avgZ + thickness / 2)) + 0.0,
                })
                return
            end

            if IsDisabledControlJustPressed(0, 200) then
                cleanup()
                p:resolve(nil)
                return
            end

            Wait(0)
        end
        cleanup()
    end)

    return Citizen.Await(p)
end

-- ---------------------------------------------------------------------------
-- Overlay markers: persistent editor annotations (colored ground cylinders +
-- floating labels over placed items). Grouped by id so several tools can
-- overlay at once; SetMarkers replaces the whole group. One shared draw
-- thread lives here so builder tools stop each running their own.
-- ---------------------------------------------------------------------------
local OVERLAY_DRAW_DIST = 200.0
local OVERLAY_LABEL_DIST = 30.0

local overlays = {}
local overlayThread = false

local function drawOverlayLabel(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

local function startOverlayThread()
    if overlayThread then return end
    overlayThread = true
    CreateThread(function()
        while next(overlays) do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local drewAny = false
            for _, markers in pairs(overlays) do
                for _, m in ipairs(markers) do
                    local dist = #(playerCoords - vector3(m.x, m.y, m.z))
                    if dist < OVERLAY_DRAW_DIST then
                        drewAny = true
                        DrawMarker(1, m.x, m.y, m.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                            m.scale, m.scale, 2.0, m.r, m.g, m.b, m.a,
                            false, true, 2, false, nil, nil, false)
                        if m.label and dist < OVERLAY_LABEL_DIST then
                            drawOverlayLabel(m.x, m.y, m.z + 1.5, m.label)
                        end
                    end
                end
            end
            Wait(drewAny and 0 or 250)
        end
        overlayThread = false
    end)
end

local function channel(col, key, idx, default)
    local v = col and tonumber(col[key] or col[idx])
    return v and math.floor(v) or default
end

---Replace a group's overlay markers. markers: array of
---{ coords = {x,y,z} | vector3/4, color? = {r,g,b,a?}, label?, scale? }.
---nil/empty markers clears the group.
local function SetMarkers(id, markers)
    if type(id) ~= 'string' or id == '' then return false end

    local clean = {}
    for _, m in ipairs(type(markers) == 'table' and markers or {}) do
        local c = m.coords
        local x, y, z = c and tonumber(c.x), c and tonumber(c.y), c and tonumber(c.z)
        if x and y and z then
            local col = type(m.color) == 'table' and m.color or nil
            clean[#clean + 1] = {
                x = x + 0.0, y = y + 0.0, z = z + 0.0,
                r = channel(col, 'r', 1, MARKER_R),
                g = channel(col, 'g', 2, MARKER_G),
                b = channel(col, 'b', 3, MARKER_B),
                a = channel(col, 'a', 4, 180),
                scale = tonumber(m.scale) or 1.0,
                label = type(m.label) == 'string' and m.label ~= '' and m.label or nil,
            }
        end
    end

    overlays[id] = #clean > 0 and clean or nil
    if next(overlays) then startOverlayThread() end
    return true
end

---Clear one overlay group, or every group when id is omitted.
local function ClearMarkers(id)
    if id ~= nil then
        overlays[id] = nil
    else
        overlays = {}
    end
end

olink._register('placement', {
    Coord = Coord,
    GhostPed = GhostPed,
    GhostVehicle = GhostVehicle,
    Polygon = Polygon,
    IsActive = IsActive,
    Cancel = Cancel,
    SetMarkers = SetMarkers,
    ClearMarkers = ClearMarkers,
})

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        Cancel()
        polyActive = false
    end
end)
