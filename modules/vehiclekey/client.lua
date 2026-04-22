-- Community-bridge naming aliases for vehiclekey.
-- cb exposes `VehicleKey.GiveKeys(vehicle, plate)` / `VehicleKey.RemoveKeys(...)`
-- whereas o-link adapters register `Give` / `Remove`. This shim adds the cb
-- names that delegate to whichever adapter registered, so code ported from
-- community_bridge keeps working.

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
