local RESOURCE = 'es_extended'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Multichar', RESOURCE, RESOURCE) then return end

olink._register('multichar', {
    GetResourceName = function() return RESOURCE end,

    -- ESX has no native apartments flow; identity is already saved by the
    -- server adapter's Create, so onboarding is just the appearance creator.
    OnboardNewCharacter = function(charId, opts, onDone)
        local gender = opts and opts.gender or 0
        if olink.clothing and olink.clothing.StartCreation then
            olink.clothing.StartCreation(gender, onDone)
        elseif onDone then
            onDone(true)
        end
    end,

    -- ESX has no spawn selector — it always spawns at the last saved position
    -- (esx:onPlayerJoined, fired in the server Select, already kicked the load
    -- chain). Return false so oxide-multichar does its default teleport.
    ---@return boolean handled
    SpawnCharacter = function()
        return false
    end,
})

-- Bridge ESX's "show character selection" client event (only fires if the
-- customer kept esx_multicharacter installed; harmless when it's disabled),
-- ESX's logout event, and o-link's generic start event to the unified event
-- the multichar resource listens on.
RegisterNetEvent('esx_multicharacter:SetupUI', function()
    TriggerEvent('olink:client:startCharacterSelect')
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    TriggerEvent('olink:client:startCharacterSelect')
end)

RegisterNetEvent('o-link:multichar:startSelect', function()
    TriggerEvent('olink:client:startCharacterSelect')
end)

-- Replaces esx_multicharacter's boot trigger (it natively fires
-- esx_multicharacter:SetupUI from its playerConnecting handler, which we no
-- longer get because customers disable that resource). Mirrors QBX/QBCore:
-- wait for session, disable auto-spawn, dismiss the loadscreen (esx_loadingscreen
-- and similar wait for external shutdown), fire ESX's loadingScreenOff event for
-- any consumers that hook it, then hand off to oxide-multichar.
CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(0) end
    pcall(function() exports.spawnmanager:setAutoSpawn(false) end)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    TriggerEvent('esx:loadingScreenOff')
    Wait(250)
    TriggerEvent('olink:client:startCharacterSelect')
end)
