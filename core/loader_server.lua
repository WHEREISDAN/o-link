-- Server loader: prints startup summary after all modules have self-registered via globs
local caps = olink._getCapabilities()

print('^2[o-link] Server modules loaded:^0')
local modules = { 'callback', 'framework', 'character', 'job', 'money', 'inventory', 'vehicles', 'vehicleOwnership', 'banking', 'notify', 'phone', 'clothing', 'dispatch', 'doorlock', 'housing', 'bossmenu', 'skills', 'entity' }
for _, ns in ipairs(modules) do
    if caps[ns] then
        print(('  ^5%-12s^0 : ^2loaded^0'):format(ns))
    elseif Config.Debug then
        print(('  ^5%-12s^0 : ^1not loaded^0'):format(ns))
    end
end

print('^2[o-link] Server initialization complete.^0')
