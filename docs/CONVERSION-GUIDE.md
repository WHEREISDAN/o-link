# Converting a Resource from community_bridge to o-link

## Quick Reference: Bridge → o-link Mapping

### Initialization
```lua
-- OLD (community_bridge)
Bridge = exports['community_bridge']:Bridge()
Callback = Bridge.Callback

-- NEW (o-link)
olink = exports['o-link']:olink()
Callback = olink.callback
```

### fxmanifest.lua
Replace `'community_bridge'` with `'o-link'` in dependencies.

### Framework Detection
```lua
-- OLD
Bridge.IsOxide
Bridge.IsQBCore
Bridge.FrameworkName
Bridge.Framework.GetResourceName()

-- NEW
olink.framework.GetName() == 'oxide-core'
olink.framework.GetName() == 'qb-core' or olink.framework.GetName() == 'qbx_core'
olink.framework.GetName()
olink.framework.GetName()
```

### Player Identity
```lua
-- OLD
Bridge.Framework.GetPlayerIdentifier(src)
Bridge.Framework.GetPlayerName(src)
Bridge.Framework.GetPlayerMetadata(src, key)
Bridge.Framework.SetPlayerMetadata(src, key, value)
Bridge.Framework.GetIsFrameworkAdmin(src)

-- NEW
olink.character.GetIdentifier(src)
olink.character.GetName(src)           -- returns firstName, lastName (TWO values)
olink.character.GetMetadata(src, key)
olink.character.SetMetadata(src, key, value)
olink.framework.IsAdmin(src)
```

### Jobs
```lua
-- OLD
Bridge.Framework.GetPlayerJobData(src)    -- returns { jobName, jobLabel, gradeRank, boss, onDuty }
Bridge.Framework.SetPlayerJob(src, name, grade)
Bridge.Framework.SetPlayerDuty(src, status)
Bridge.Framework.GetPlayers()

-- NEW
olink.job.Get(src)                        -- returns { name, label, grade, gradeLabel, rank, isBoss, onDuty }
olink.job.Set(src, name, grade)
olink.job.SetDuty(src, status)
olink.framework.GetPlayers()
```

**IMPORTANT: Job field names changed:**
| community_bridge | o-link |
|-----------------|--------|
| `jobName` | `name` |
| `jobLabel` | `label` |
| `gradeName` | `grade` |
| `gradeRank` | `rank` |
| `boss` | `isBoss` |
| `onDuty` | `onDuty` |

### Money
```lua
-- OLD
Bridge.Framework.AddAccountBalance(src, type, amount)
Bridge.Framework.RemoveAccountBalance(src, type, amount)
Bridge.Framework.GetAccountBalance(src, type)

-- NEW
olink.money.Add(src, type, amount, reason?)
olink.money.Remove(src, type, amount, reason?)
olink.money.GetBalance(src, type)

-- NEW (offline - not in community_bridge)
olink.money.AddOffline(identifier, type, amount)
olink.money.RemoveOffline(identifier, type, amount)
olink.money.GetBalanceOffline(identifier, type)
```

### Inventory
```lua
-- OLD
Bridge.Inventory.AddItem(src, item, count, slot, metadata)
Bridge.Inventory.RemoveItem(src, item, count, slot)
Bridge.Inventory.GetPlayerInventory(src)
Bridge.Inventory.GetItemBySlot(src, slot)
Bridge.Inventory.OpenPlayerInventory(src, targetSrc)
Bridge.Inventory.RegisterStash(id, label, slots, weight, owner)
Bridge.Inventory.OpenStash(src, stashId)
-- NOTE: community_bridge OpenStash was (src, type, id). o-link is (src, id). Drop the type arg.

-- NEW
olink.inventory.AddItem(src, item, count, slot, metadata)
olink.inventory.RemoveItem(src, item, count, slot)
olink.inventory.GetPlayerInventory(src)
olink.inventory.GetItemBySlot(src, slot)
olink.inventory.OpenPlayerInventory(src, targetSrc)
olink.inventory.RegisterStash(id, label, slots, weight, owner)
olink.inventory.OpenStash(src, stashId)
```

### Notifications
```lua
-- OLD (server) - note the nil title parameter
Bridge.Notify.SendNotification(src, nil, message, type, duration)

-- NEW (server)
olink.notify.Send(src, message, type, duration)

-- OLD (client) - note the nil title parameter
Bridge.Notify.SendNotification(nil, message, type, duration)

-- NEW (client) - no source on client
olink.notify.Send(message, type, duration)
```

### Help Text
```lua
-- OLD
Bridge.Notify.ShowHelpText(message)
Bridge.Notify.HideHelpText()

-- NEW
olink.helptext.Show(message, position?)
olink.helptext.Hide()
```

### Target
```lua
-- OLD
Bridge.Target.AddBoxZone(name, coords, size, heading, options)
Bridge.Target.AddSphereZone(name, coords, radius, options)
Bridge.Target.RemoveZone(name)
Bridge.Target.AddLocalEntity(entity, options)
Bridge.Target.RemoveLocalEntity(entity, optionNames)
Bridge.Target.AddModel(models, options)

-- NEW (same signatures)
olink.target.AddBoxZone(name, coords, size, heading, options, debug?)
olink.target.AddSphereZone(name, coords, radius, options, debug?)
olink.target.RemoveZone(name)
olink.target.AddLocalEntity(entity, options)
olink.target.RemoveLocalEntity(entity, optionNames?)
olink.target.AddModel(models, options)
olink.target.RemoveModel(model)     -- NEW: not in community_bridge
```

### Progress Bar
```lua
-- OLD
Bridge.ProgressBar.Open(options)

-- NEW (same signature)
olink.progressbar.Open(options, callback?)
```

### Vehicle Keys
```lua
-- OLD
Bridge.VehicleKey.GiveKeys(vehicle, plate)
Bridge.VehicleKey.RemoveKeys(vehicle, plate)

-- NEW
olink.vehiclekey.Give(vehicle, plate?)
olink.vehiclekey.Remove(vehicle, plate?)
```

### Entity System
```lua
-- OLD
Bridge.ServerEntity.Create(data)
Bridge.ServerEntity.Destroy(id)
Bridge.ClientEntity.SetOnCreate(propertyKey, handler)

-- NEW
olink.entity.Create(data)
olink.entity.Destroy(id)
olink.entity.SetOnCreate(propertyKey, handler)
```

### Usable Items
```lua
-- OLD
Bridge.Framework.RegisterUsableItem(itemName, callback)

-- NEW
olink.framework.RegisterUsableItem(itemName, callback)
```

### Commands
```lua
-- OLD
Bridge.Framework.Commands.Add(name, description, args, job, callback)

-- NEW (use ox_lib directly)
lib.addCommand(name, {
    help = description,
    params = { { name = 'arg', help = 'desc', type = 'string', optional = false } },
    restricted = 'group.admin',  -- or false
}, function(source, args, raw)
    -- handler
end)
```

### Lifecycle Events
```lua
-- OLD
'community_bridge:Server:OnPlayerLoaded'   → 'olink:server:playerReady'
'community_bridge:Server:OnPlayerUnload'   → 'olink:server:playerUnload'
'community_bridge:Client:OnPlayerLoaded'   → 'olink:client:playerReady'
'community_bridge:Client:OnPlayerUnload'   → 'olink:client:playerUnload'
```

### Bridge Utility Functions
```lua
-- OLD (on Bridge object)
Bridge.FormatNumber(n)
Bridge.FormatMoney(n)

-- NEW (define as globals in your shared init, not bridge concerns)
function FormatNumber(n)
    if not n then return '0' end
    local formatted = tostring(math.floor(n))
    local k
    while true do
        formatted, k = formatted:gsub('^(-?%d+)(%d%d%d)', '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function FormatMoney(n)
    return '$' .. FormatNumber(n)
end
```

---

## Self-Registration Pattern

If your resource provides an API that other resources should access through o-link (like oxide-banking provides banking), self-register at the end of initialization:

```lua
-- At the end of your onResourceStart handler:
if olink and olink._register then
    olink._register('banking', {
        GetBalance = function(accountName) ... end,
        AddMoney = function(accountName, amount, reason) ... end,
        -- etc
    })
end
```

This avoids circular dependencies: your resource depends on o-link (to consume it), and o-link doesn't depend on your resource (your resource registers itself).

---

## Common Pitfalls

1. **GetName returns TWO values.** `olink.character.GetName(src)` returns `firstName, lastName`. Don't do `local name = olink.character.GetName(src)` — you'll only get firstName.

2. **OpenStash signature changed.** community_bridge was `(src, type, id)`. o-link is `(src, id)`. Drop the type parameter.

3. **Notify signature changed.** Remove the nil title/source args. Server: `Send(src, msg, type)`. Client: `Send(msg, type)`.

4. **Job field names changed.** `jobName` → `name`, `gradeRank` → `rank`, `boss` → `isBoss`.

5. **Money reason parameter.** `olink.money.Add/Remove` accepts an optional 4th arg `reason`. Pass it so framework money change events have context.

6. **No Bridge.Framework.Commands.** Use `lib.addCommand()` from ox_lib instead.

7. **Direct DB queries to characters/players/users.** Use `olink.character.Search()`, `olink.character.GetOffline()`, `olink.vehicles.SearchByPlate()` etc. instead of querying framework-specific tables directly.
