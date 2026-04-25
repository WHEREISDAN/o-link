-- Shared notify adapter selection.
-- ox_lib is mandatory for o-link, but its notification UI is treated as a
-- fallback provider unless explicitly selected by Config.Overrides.Notify.

local notifyPriority = {
    { implName = 'oxide-notify', resourceName = 'oxide-notify' },
    { implName = 'brutal_notify', resourceName = 'brutal_notify' },
    { implName = 'fl-notify', resourceName = 'FL-Notify' },
    { implName = 'lation_ui', resourceName = 'lation_ui' },
    { implName = 'mythic_notify', resourceName = 'mythic_notify' },
    { implName = 'okokNotify', resourceName = 'okokNotify' },
    { implName = 'pNotify', resourceName = 'pNotify' },
    { implName = 'r_notify', resourceName = 'r_notify' },
    { implName = 't-notify', resourceName = 't-notify' },
    { implName = 'wasabi_notify', resourceName = 'wasabi_notify' },
    { implName = 'zsxui', resourceName = 'ZSX_UIV2' },
    { implName = 'ox_lib', resourceName = 'ox_lib', isOxLib = true },
    { implName = '_default', resourceName = false, isDefault = true },
}

local warnedMultipleNotify = false

local function normalizeName(value)
    return type(value) == 'string' and value:lower() or nil
end

local function matchesName(value, implName, resourceName)
    local normalized = normalizeName(value)
    if not normalized then return false end
    return normalized == normalizeName(implName) or normalized == normalizeName(resourceName)
end

local function copySelection(adapter, isOxLibFallback)
    return {
        implName = adapter.implName,
        resourceName = adapter.resourceName,
        isDefault = adapter.isDefault == true,
        isOxLibFallback = isOxLibFallback == true,
    }
end

local function getStartedState(resourceName)
    return resourceName ~= false and resourceName ~= nil and GetResourceState(resourceName) == 'started'
end

local function findAdapterByName(name)
    for _, adapter in ipairs(notifyPriority) do
        if matchesName(name, adapter.implName, adapter.resourceName) then
            return adapter
        end
    end
end

local function warnMultipleNotify(startedAdapters, selected)
    if warnedMultipleNotify or not IsDuplicityVersion() or #startedAdapters <= 1 then return end
    warnedMultipleNotify = true

    local names = {}
    for _, adapter in ipairs(startedAdapters) do
        names[#names + 1] = adapter.implName
    end

    print(('[o-link] Multiple notify resources are started (%s). Using "%s". Set Config.Overrides.Notify to choose explicitly.')
        :format(table.concat(names, ', '), selected.implName))
end

function olink._getNotifySelection()
    local override = olink._getOverride('Notify')
    if override then
        local adapter = findAdapterByName(override)
        if adapter then
            return copySelection(adapter, false)
        end

        return {
            implName = override,
            resourceName = override,
            isDefault = override == '_default',
            isOxLibFallback = false,
        }
    end

    local startedAdapters = {}
    local oxLibAdapter

    for _, adapter in ipairs(notifyPriority) do
        if not adapter.isDefault and getStartedState(adapter.resourceName) then
            if adapter.isOxLib then
                oxLibAdapter = adapter
            else
                startedAdapters[#startedAdapters + 1] = adapter
            end
        end
    end

    if #startedAdapters > 0 then
        warnMultipleNotify(startedAdapters, startedAdapters[1])
        return copySelection(startedAdapters[1], false)
    end

    if oxLibAdapter then
        return copySelection(oxLibAdapter, true)
    end

    return copySelection(notifyPriority[#notifyPriority], false)
end

function olink._guardNotifyAdapter(implName, resourceName)
    local override = olink._getOverride('Notify')
    if override then
        if not matchesName(override, implName, resourceName) then return false end
    else
        local selection = olink._getNotifySelection()
        if not matchesName(selection.implName, implName, resourceName) then return false end
    end

    if resourceName == false then return true end

    local resolvedResource = resourceName or implName
    local state = GetResourceState(resolvedResource)
    if state ~= 'started' and state ~= 'missing' and Config and Config.Debug then
        print(('[o-link] Notify adapter "%s" skipped: resource "%s" is %s (not started)')
            :format(implName, resolvedResource, state))
    end
    return state == 'started'
end
