-- QBX housing provider (qbx_properties). Starter apartments are written directly
-- to the `properties` table (mirroring qbx_properties/server/apartmentselect.lua)
-- rather than via `qbx_properties:server:apartmentSelect`, because that native
-- path fires `qb-clothes:client:CreateFirstCharacter` — the appearance is already
-- set by multichar's creator, so we must not re-open it. Entering delegates to
-- qbx_properties:server:enterProperty (which enforces owner/keyholder access).

local RESOURCE = 'qbx_properties'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Housing', RESOURCE, false) then return end

local function isStarted() return GetResourceState(RESOURCE) == 'started' end

local function getCitizenId(src)
    local ok, player = pcall(function() return exports.qbx_core:GetPlayer(src) end)
    if ok and player and player.PlayerData then return player.PlayerData.citizenid end
    return nil
end

-- Insert a starter apartment row for the citizen from the caller-supplied def
-- (label, interior, enter, interact[], stash) — mirrors apartmentselect.lua.
---@return integer|nil id, string|nil propertyName
local function createApartmentRow(cid, def)
    if type(def) ~= 'table' or not def.interior or not def.enter or not def.stash then return nil end

    local interactData = {}
    for _, opt in ipairs(def.interact or {}) do
        interactData[#interactData + 1] = { type = opt.type, coords = opt.coords }
    end
    local stashData = { { coords = def.stash.coords, slots = def.stash.slots, maxWeight = def.stash.maxWeight } }

    local last = MySQL.single.await('SELECT id FROM properties ORDER BY id DESC')
    local n = (last and last.id) or 0
    local name
    repeat
        n = n + 1
        name = ('%s %s'):format(def.label, n)
    until not MySQL.single.await('SELECT 1 FROM properties WHERE property_name = ?', { name })

    local id = MySQL.insert.await(
        'INSERT INTO properties (coords, property_name, owner, interior, interact_options, stash_options) VALUES (?, ?, ?, ?, ?, ?)',
        { json.encode(def.enter), name, cid, def.interior, json.encode(interactData), json.encode(stashData) })
    if not id then return nil end

    TriggerClientEvent('qbx_properties:client:addProperty', -1, def.enter)
    return id, name
end

olink._register('housing', {
    GetResourceName = function() return RESOURCE end,

    GetOwnedProperties = function(src, identifier)
        if not isStarted() then return {} end
        local cid = identifier or getCitizenId(src)
        if not cid then return {} end
        local rows = MySQL.query.await('SELECT id, property_name, coords FROM properties WHERE owner = ?', { cid }) or {}
        local out = {}
        for _, p in ipairs(rows) do
            local entry = { id = p.id, kind = 'property', label = p.property_name }
            local ok, c = pcall(json.decode, p.coords)
            if ok and type(c) == 'table' and c.x then
                entry.coords = { x = c.x, y = c.y, z = c.z }
            end
            out[#out + 1] = entry
        end
        return out
    end,

    -- `def` is supplied by the caller (oxide-multichar): label, interior, enter,
    -- interact[], stash — verbatim from qbx_properties' apartmentOptions shape.
    CreateStartingApartment = function(src, def)
        if not isStarted() then return false end
        local cid = getCitizenId(src)
        if not cid then return false end

        local existing = MySQL.single.await('SELECT id, property_name FROM properties WHERE owner = ?', { cid })
        if existing then
            TriggerClientEvent('o-link:housing:qbx:enter', src, { id = existing.id, isSpawn = true })
            return { id = existing.id, label = existing.property_name }
        end

        local id, name = createApartmentRow(cid, def)
        if not id then return false end
        TriggerClientEvent('o-link:housing:qbx:enter', src, { id = id, isSpawn = true })
        return { id = id, label = name }
    end,

    -- enterProperty enforces hasAccess (owner/keyholder) server-side.
    SpawnInside = function(src, id)
        if not isStarted() or not id then return false end
        TriggerClientEvent('o-link:housing:qbx:enter', src, { id = id, isSpawn = true })
        return true
    end,
})
