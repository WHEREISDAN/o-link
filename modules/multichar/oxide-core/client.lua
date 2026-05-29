if not olink._guardImpl('Multichar', 'oxide-core', 'oxide-core') then return end

olink._register('multichar', {
    ---@return string
    GetResourceName = function() return 'oxide-core' end,

    -- Post-creation onboarding for a fresh character. Each framework runs whatever
    -- it natively does at this point (apartment select, spawn picker, appearance
    -- editor). On Oxide today there's no housing or spawn UI, so we delegate
    -- straight to the appearance editor. When oxide-housing exists, slot it in
    -- ahead of the clothing call here -- the multichar resource never changes.
    ---@param charId any
    ---@param opts table { gender: 0|1 }
    ---@param onDone fun(success: boolean)
    OnboardNewCharacter = function(charId, opts, onDone)
        local gender = opts and opts.gender or 0
        if olink.clothing and olink.clothing.StartCreation then
            olink.clothing.StartCreation(gender, onDone)
        elseif onDone then
            onDone(true)
        end
    end,

    -- Oxide has no spawn selector yet; spawn at the last saved position. Return
    -- false so oxide-multichar does its default teleport. When oxide-housing /
    -- a spawn picker exists, branch here the same way the QB adapters do.
    ---@return boolean handled
    SpawnCharacter = function()
        return false
    end,
})

-- Bridge the framework's "show character selection" triggers to a unified event
-- the multichar resource can listen to regardless of framework.
RegisterNetEvent('oxide:core:startCharacterSelect', function()
    TriggerEvent('olink:client:startCharacterSelect')
end)

RegisterNetEvent('o-link:multichar:startSelect', function()
    TriggerEvent('olink:client:startCharacterSelect')
end)
