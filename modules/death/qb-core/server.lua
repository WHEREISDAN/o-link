if not olink._guardImpl('Death', 'qb-core', 'qb-core') then return end
if not olink._hasOverride('Death') and GetResourceState('qbx_core') == 'started' then return end
if not olink._hasOverride('Death') and GetResourceState('oxide-death') == 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

olink._register('death', {
    ---@param src number
    ---@return boolean
    IsPlayerDowned = function(src)
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return false end
        return p.PlayerData.metadata.inlaststand == true
    end,

    ---@param src number
    ---@return boolean
    IsPlayerDead = function(src)
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return false end
        return p.PlayerData.metadata.isdead == true
    end,

    ---@param src number
    ---@return table|nil
    GetDeathState = function(src)
        local p = QBCore.Functions.GetPlayer(src)
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
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return false end
        p.Functions.SetMetaData('isdead', false)
        p.Functions.SetMetaData('inlaststand', false)
        TriggerClientEvent('hospital:client:Revive', src)
        return true
    end,

    ---@param src number
    ---@param cause string|nil
    ---@return boolean
    KillPlayer = function(src, cause)
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return false end
        p.Functions.SetMetaData('isdead', true)
        p.Functions.SetMetaData('inlaststand', false)
        TriggerClientEvent('hospital:client:KillPlayer', src)
        return true
    end,

    ---@param src number
    ---@param coords vector4|nil
    ---@return boolean
    RespawnPlayer = function(src, coords)
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return false end
        p.Functions.SetMetaData('isdead', false)
        p.Functions.SetMetaData('inlaststand', false)
        if coords then
            SetEntityCoords(GetPlayerPed(src), coords.x, coords.y, coords.z)
            if coords.w then SetEntityHeading(GetPlayerPed(src), coords.w) end
        end
        TriggerClientEvent('hospital:client:Revive', src)
        return true
    end,

    ---@param src number
    ---@param cause string|nil
    ---@param coords vector3|nil
    ---@param heading number|nil
    ---@return boolean
    DownPlayer = function(src, cause, coords, heading)
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return false end
        p.Functions.SetMetaData('inlaststand', true)
        TriggerClientEvent('hospital:client:SetLaststand', src)
        return true
    end,
})

local lastState = {}

local function emitTransition(src, newState)
    local oldState = lastState[src] or 'alive'
    if newState == oldState then return end
    lastState[src] = newState

    if newState == 'dead' then
        TriggerEvent('olink:server:playerDied', src, {})
    elseif newState == 'downed' then
        TriggerEvent('olink:server:playerDowned', src, {})
    elseif newState == 'alive' then
        TriggerEvent('olink:server:playerRevived', src, {})
    end
    TriggerEvent('olink:server:playerDeathStateChanged', src, newState, oldState, {})
end

RegisterNetEvent('hospital:server:SetDeathStatus', function(isDead)
    local src = source
    if not src or src <= 0 then return end
    if isDead then
        emitTransition(src, 'dead')
    else
        emitTransition(src, 'alive')
    end
end)

RegisterNetEvent('hospital:server:SetLaststandStatus', function(bool)
    local src = source
    if not src or src <= 0 then return end
    if bool then
        emitTransition(src, 'downed')
    else
        emitTransition(src, 'alive')
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    lastState[src] = nil
end)
