-- Naming aliases: `GiveKeys`/`RemoveKeys` delegate to the adapter's `Give`/`Remove`.

if not olink.vehiclekey then return end
if olink._vehiclekeyAliasesLoaded then return end
olink._vehiclekeyAliasesLoaded = true

olink._register('vehiclekey', {
    ---@param vehicle number Entity handle
    ---@param plate string|nil
    GiveKeys = function(vehicle, plate)
        if olink.vehiclekey and olink.vehiclekey.Give then
            olink.vehiclekey.Give(vehicle, plate)
        end
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    RemoveKeys = function(vehicle, plate)
        if olink.vehiclekey and olink.vehiclekey.Remove then
            olink.vehiclekey.Remove(vehicle, plate)
        end
    end,
})
