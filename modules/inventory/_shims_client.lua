-- Underscore prefix keeps this out of the `**/client.lua` adapter glob so it
-- loads once via its explicit fxmanifest entry, after all adapters.

if not olink.inventory then return end

local realGetImagePath = olink.inventory.GetImagePath

olink._register('inventory', {
    GetImagePath = function(item)
        local base = Config and Config.ImageBaseUrl
        if type(base) == 'string' and base ~= '' and type(item) == 'string' and item ~= '' then
            if not base:match('/$') then base = base .. '/' end
            local stripped = item:gsub('%.png$', ''):gsub('%.webp$', '')
            return base .. stripped .. '.png'
        end
        return realGetImagePath and realGetImagePath(item) or ''
    end,
}, 'o-link')
