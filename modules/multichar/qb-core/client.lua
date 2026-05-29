local RESOURCE = 'qb-core'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Multichar', RESOURCE, RESOURCE) then return end

olink._register('multichar', {
    GetResourceName = function() return RESOURCE end,

    -- Post-creation onboarding. If qb-apartments is installed, hand off to it
    -- (it natively triggers qb-clothes:client:CreateFirstCharacter on submit,
    -- AND fires OnPlayerLoaded). Otherwise we fire OnPlayerLoaded ourselves then
    -- open the appearance creator — mirroring native qb-multicharacter's
    -- closeNUIdefault path which fires the event before CreateFirstCharacter.
    OnboardNewCharacter = function(charId, opts, onDone)
        local gender = opts and opts.gender or 0

        if GetResourceState('qb-apartments') == 'started' then
            TriggerEvent('apartments:client:setupSpawnUI', { citizenid = charId })
            if onDone then onDone(true) end
            return
        end

        TriggerEvent('QBCore:Client:OnPlayerLoaded')

        if olink.clothing and olink.clothing.StartCreation then
            olink.clothing.StartCreation(gender, onDone)
        elseif onDone then
            onDone(true)
        end
    end,

    -- Existing-character spawn. With the selector enabled and a spawn/apartments
    -- resource present, hand off to the framework's native spawn UI (it owns the
    -- teleport, screen, and OnPlayerLoaded). Returning true tells oxide-multichar
    -- to stop. Otherwise we fire OnPlayerLoaded and return false so oxide does
    -- its default teleport + appearance apply.
    ---@return boolean handled
    SpawnCharacter = function(charId, position, useSelector)
        if useSelector and GetResourceState('qb-apartments') == 'started' then
            TriggerEvent('apartments:client:setupSpawnUI', { citizenid = charId })
            return true
        end
        if useSelector and GetResourceState('qb-spawn') == 'started' then
            TriggerEvent('qb-spawn:client:setupSpawns', { citizenid = charId }, false, nil)
            TriggerEvent('qb-spawn:client:openUI', true)
            return true
        end

        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        return false
    end,
})

-- Bridge qb-multicharacter's "return to selection" client event (only fires if
-- the customer kept that resource installed; harmless when it's disabled) and
-- o-link's generic start event to the unified event the multichar resource
-- listens on.
RegisterNetEvent('qb-multicharacter:client:chooseChar', function()
    TriggerEvent('olink:client:startCharacterSelect')
end)

RegisterNetEvent('o-link:multichar:startSelect', function()
    TriggerEvent('olink:client:startCharacterSelect')
end)

-- Mirror native qb-multicharacter / qb-spawn: when Client:OnPlayerLoaded fires
-- (now from our server adapter), bounce it back as Server:OnPlayerLoaded so
-- third-party server resources hooked into that event also get notified.
-- Without this, server-side resources (qb-banking financetimer, qb-houses,
-- qb-management, etc.) never know the player loaded.
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
end)

-- Replaces qb-multicharacter's boot trigger (its server-side playerConnecting
-- handler natively fires qb-multicharacter:client:chooseChar, which we no
-- longer get because customers disable that resource). Mirrors QBX's pattern:
-- wait for session, disable auto-spawn, dismiss the loadscreen explicitly
-- (qb-loadingscreen and most QB-era loadscreens also wait for external
-- shutdown), then hand off to oxide-multichar.
CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(0) end
    pcall(function() exports.spawnmanager:setAutoSpawn(false) end)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    Wait(250)
    TriggerEvent('olink:client:startCharacterSelect')
end)
