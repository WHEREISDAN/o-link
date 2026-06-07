-- CDN image replacement (client): when `Config.ImageBaseUrl` is set,
-- `GetImagePath` returns `<base>/<item>.png` instead of the adapter's path.
-- Loaded after all adapters via fxmanifest glob order.

if not olink.inventory then return end
if olink._imageReplacementLoaded then return end
olink._imageReplacementLoaded = true

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
