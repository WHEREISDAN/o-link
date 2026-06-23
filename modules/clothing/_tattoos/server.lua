-- Single tattoo persistence API for the clothing bridge. Drawing a tattoo is a
-- native (AddPedDecorationFromHashes), so the only question is WHERE the list is
-- stored. Clothing backends with a native appearance store keep it there; every
-- other backend (and none) uses the `shop_tattoos` table the consumer (oxide-shops)
-- owns. There is no "unsupported" state — the router below always persists.
--
-- Native backends register a handler in `olink._nativeTattoos[<resource>]`; this
-- router picks one by the active clothing module name and handles statebag/apply
-- sync uniformly so handlers only have to persist.
--
-- FORKING o-link? The fallback path expects a `shop_tattoos` table (identifier
-- VARCHAR PK, tattoos LONGTEXT) created by a consumer; o-link owns no SQL. Point
-- the two queries below at your own table if you reuse this bridge.

olink._nativeTattoos = olink._nativeTattoos or {}

local function shopGet(identifier)
    if not identifier then return {} end
    local row = MySQL.single.await('SELECT tattoos FROM shop_tattoos WHERE identifier = ?', { tostring(identifier) })
    if not row or not row.tattoos then return {} end
    local ok, decoded = pcall(json.decode, row.tattoos)
    return (ok and type(decoded) == 'table') and decoded or {}
end

local function shopSave(identifier, tattoos)
    if not identifier then return false end
    local affected = MySQL.update.await(
        'INSERT INTO shop_tattoos (identifier, tattoos) VALUES (?, ?) ON DUPLICATE KEY UPDATE tattoos = VALUES(tattoos)',
        { tostring(identifier), json.encode(tattoos) }
    )
    return affected ~= nil
end

local function activeBackend()
    return (olink.clothing.GetResourceName and olink.clothing.GetResourceName()) or 'none'
end

olink._register('clothing', {
    GetTattoos = function(src)
        local handler = olink._nativeTattoos[activeBackend()]
        if handler then return handler.Get(src) or {} end
        return shopGet(olink.character.GetIdentifier(src))
    end,

    SaveTattoos = function(src, tattoos)
        src = tonumber(src)
        if not src then return false end
        if type(tattoos) ~= 'table' then tattoos = {} end

        local handler = olink._nativeTattoos[activeBackend()]
        local ok
        if handler then
            ok = handler.Save(src, tattoos)
        else
            ok = shopSave(olink.character.GetIdentifier(src), tattoos)
        end

        if ok then
            Player(src).state:set('oxide:tattoos', tattoos, true)
            TriggerClientEvent('o-link:client:clothing:applyTattoos', src, tattoos)
        end
        return ok and true or false
    end,
})
