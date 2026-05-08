if not olink._guardImpl('Death', 'es_extended', 'es_extended') then return end
if not olink._hasOverride('Death') and GetResourceState('oxide-death') == 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

olink._register('death', {
    ---@param src number
    ---@return boolean
    IsPlayerDowned = function(src)
        -- ESX has no native downed/laststand concept — only dead or alive
        return false
    end,

    ---@param src number
    ---@return boolean
    IsPlayerDead = function(src)
        return Player(src).state.isDead == true
    end,

    ---@param src number
    ---@return table|nil
    GetDeathState = function(src)
        local state = Player(src).state.isDead and 'dead' or 'alive'
        return { state = state }
    end,

    ---@param src number
    ---@param reviverSrc number|nil
    ---@return boolean
    RevivePlayer = function(src, reviverSrc)
        TriggerEvent('esx_ambulancejob:revive', src)
        return true
    end,

    ---@param src number
    ---@param cause string|nil
    ---@return boolean
    KillPlayer = function(src, cause)
        TriggerClientEvent('esx:killPlayer', src)
        return true
    end,

    ---@param src number
    ---@param coords vector4|nil
    ---@return boolean
    RespawnPlayer = function(src, coords)
        if coords then
            SetEntityCoords(GetPlayerPed(src), coords.x, coords.y, coords.z)
            if coords.w then SetEntityHeading(GetPlayerPed(src), coords.w) end
        end
        TriggerEvent('esx_ambulancejob:revive', src)
        return true
    end,

    ---@param src number
    ---@param cause string|nil
    ---@param coords vector3|nil
    ---@param heading number|nil
    ---@return boolean
    DownPlayer = function(src, cause, coords, heading)
        -- ESX has no native downed/laststand — kill instead
        TriggerClientEvent('esx:killPlayer', src)
        return true
    end,
})

local lastState = {}
local deathContext = {}

AddEventHandler('esx:onPlayerDeath', function(data)
    local src = source
    if not src or src <= 0 then return end
    deathContext[src] = {
        attacker = data and data.killerServerId or nil,
        weapon = data and data.killedByWeapon or nil,
        cause = data and data.deathCause or nil,
        coords = data and data.killerCoords or nil,
    }
end)

AddStateBagChangeHandler('isDead', nil, function(bagName, _, value)
    local src = GetPlayerFromStateBagName(bagName)
    if not src or src <= 0 then return end

    local newState = value and 'dead' or 'alive'
    local oldState = lastState[src] or 'alive'
    if newState == oldState then return end
    lastState[src] = newState

    local data = deathContext[src] or {}
    if newState == 'dead' then
        TriggerEvent('olink:server:playerDied', src, data)
    else
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
