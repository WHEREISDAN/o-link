olink = {}

local capabilities = {}

---@param namespace string Module namespace (e.g. 'framework', 'character', 'job')
---@param impl table Table of functions returned by the module implementation
function olink._register(namespace, impl)
    olink[namespace] = impl
    capabilities[namespace] = true
end

---Check whether a module or specific function is available.
---@param path string Dot-separated path (e.g. 'character', 'character.SetBoss')
---@return boolean
function olink.supports(path)
    local node = olink
    for part in path:gmatch('[^.]+') do
        if type(node) ~= 'table' then return false end
        node = node[part]
        if node == nil then return false end
    end
    return true
end

---@return table<string, boolean> Map of loaded module namespaces
function olink._getCapabilities()
    return capabilities
end

exports('olink', function()
    return olink
end)
