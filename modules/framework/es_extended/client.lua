if not olink._guardImpl('Framework', 'es_extended', 'es_extended') then return end

local ESX = exports['es_extended']:getSharedObject()

olink._register('framework', {
    GetResourceName = function()
        return 'es_extended'
    end,

    ---@return string
    GetName = function()
        return 'es_extended'
    end,

    ---@return boolean
    GetIsPlayerLoaded = function()
        return ESX.IsPlayerLoaded()
    end,

    ShowHelpText = function(message, _position)
        if GetResourceState('esx_textui') ~= 'started' then return end
        return exports.esx_textui:TextUI(message, 'info')
    end,

    HideHelpText = function()
        if GetResourceState('esx_textui') ~= 'started' then return end
        return exports.esx_textui:HideUI()
    end,
})
