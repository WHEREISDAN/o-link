-- Server loader: prints startup summary after all modules have self-registered via globs
local caps = olink._getCapabilities()

print('^2[o-link] Server modules loaded:^0')
local modules = { 'callback', 'framework', 'character', 'job', 'money', 'inventory', 'vehicles', 'vehicleOwnership', 'banking', 'notify', 'phone', 'clothing', 'dispatch', 'doorlock', 'housing', 'bossmenu', 'skills', 'entity', 'death', 'needs', 'gang', 'jobcount', 'helptext' }
for _, ns in ipairs(modules) do
    local state = caps[ns]
    if state and state.loaded then
        if state.kind == 'fallback' then
            print(('  ^5%-12s^0 : ^3fallback^0'):format(ns))
        else
            print(('  ^5%-12s^0 : ^2loaded^0'):format(ns))
        end
    elseif Config.Debug then
        print(('  ^5%-12s^0 : ^1not loaded^0'):format(ns))
    end
end

print('^2[o-link] Server initialization complete.^0')
