if not olink._guardImpl('Death', 'qbx_core', 'qbx_core') then return end
if not olink._hasOverride('Death') and GetResourceState('oxide-death') == 'started' then return end

olink._register('death', {
    ---@param src number
    ---@return boolean
    IsPlayerDowned = function(src)
        local p = exports.qbx_core:GetPlayer(src)
        if not p then return false end
        return p.PlayerData.metadata.inlaststand == true
    end,

    ---@param src number
    ---@return boolean
    IsPlayerDead = function(src)
        local p = exports.qbx_core:GetPlayer(src)
        if not p then return false end
        return p.PlayerData.metadata.isdead == true
    end,

    ---@param src number
    ---@return table|nil
    GetDeathState = function(src)
        local p = exports.qbx_core:GetPlayer(src)
        if not p then return nil end
        local meta = p.PlayerData.metadata
        local state = 'alive'
        if meta.isdead then state = 'dead'
        elseif meta.inlaststand then state = 'downed' end
        return { state = state }
    end,

    ---@param src number
    ---@param reviverSrc number|nil
    ---@return boolean
    RevivePlayer = function(src, reviverSrc)
        local p = exports.qbx_core:GetPlayer(src)
        if not p then return false end
        p.Functions.SetMetaData('isdead', false)
        p.Functions.SetMetaData('inlaststand', false)
        TriggerClientEvent('qbx_medical:client:playerRevived', src)
        return true
    end,

    ---@param src number
    ---@param cause string|nil
    ---@return boolean
    KillPlayer = function(src, cause)
        local p = exports.qbx_core:GetPlayer(src)
        if not p then return false end
        p.Functions.SetMetaData('isdead', true)
        p.Functions.SetMetaData('inlaststand', false)
        return true
    end,

    ---@param src number
    ---@param coords vector4|nil
    ---@return boolean
    RespawnPlayer = function(src, coords)
        local p = exports.qbx_core:GetPlayer(src)
        if not p then return false end
        p.Functions.SetMetaData('isdead', false)
        p.Functions.SetMetaData('inlaststand', false)
        if coords then
            SetEntityCoords(GetPlayerPed(src), coords.x, coords.y, coords.z)
            if coords.w then SetEntityHeading(GetPlayerPed(src), coords.w) end
        end
        TriggerClientEvent('qbx_medical:client:playerRevived', src)
        return true
    end,

    ---@param src number
    ---@param cause string|nil
    ---@param coords vector3|nil
    ---@param heading number|nil
    ---@return boolean
    DownPlayer = function(src, cause, coords, heading)
        local p = exports.qbx_core:GetPlayer(src)
        if not p then return false end
        p.Functions.SetMetaData('inlaststand', true)
        return true
    end,
})

-- qbx_medical/config/shared.lua: deathState = { ALIVE = 1, LAST_STAND = 2, DEAD = 3 }
local STATE_MAP = { [1] = 'alive', [2] = 'downed', [3] = 'dead' }

local lastState = {}
local deathContext = {}

RegisterNetEvent('qbx_medical:server:onPlayerDied', function(attacker, weapon)
    local src = source
    if not src or src <= 0 then return end
    deathContext[src] = { attacker = attacker, weapon = weapon }
end)

RegisterNetEvent('qbx_medical:server:onPlayerLaststand', function(attacker, weapon)
    local src = source
    if not src or src <= 0 then return end
    deathContext[src] = { attacker = attacker, weapon = weapon }
end)

AddStateBagChangeHandler('qbx_medical:deathState', nil, function(bagName, _, value)
    local src = GetPlayerFromStateBagName(bagName)
    if not src or src <= 0 then return end

    local newState = STATE_MAP[value]
    if not newState then return end
    local oldState = lastState[src] or 'alive'
    if newState == oldState then return end
    lastState[src] = newState

    local data = deathContext[src] or {}
    if newState == 'dead' then
        TriggerEvent('olink:server:playerDied', src, data)
    elseif newState == 'downed' then
        TriggerEvent('olink:server:playerDowned', src, data)
    elseif newState == 'alive' then
        TriggerEvent('olink:server:playerRevived', src, data)
        deathContext[src] = nil
    end
    TriggerEvent('olink:server:playerDeathStateChanged', src, newState, oldState, data)
end)

AddEventHandler('playerDropped', function()
    local src = source
    lastState[src] = nil
    deathContext[src] = nil
end)
