# o-link API Reference

## Consuming o-link

```lua
-- shared/init.lua in any resource:
olink = exports['o-link']:olink()
Callback = olink.callback

-- fxmanifest.lua:
dependencies { 'ox_lib', 'oxmysql', 'o-link' }
```

## Capability Checks

```lua
olink.supports('character')            -- true if character module loaded
olink.supports('character.SetBoss')    -- true if function exists
olink.supports('vehicles.GetByOwner')  -- true if vehicles module has GetByOwner
```

---

## Module: framework (server + client)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetName()` | | `string` | Framework name: `'oxide-core'`, `'qb-core'`, `'qbx_core'`, `'es_extended'` |
| `GetIsPlayerLoaded(src)` | `src: number` | `boolean` | Whether player has a loaded character |
| `GetPlayers()` | | `number[]` | All online player source IDs |
| `IsAdmin(src)` | `src: number` | `boolean` | Whether player has admin ACE permission |
| `GetJobs()` | | `table[]` | All registered jobs: `{ name, label, grades }`. Returns `{}` on Oxide. |
| `RegisterUsableItem(name, cb)` | `name: string, cb: function(src, itemData)` | | Register an item use callback |

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetName()` | | `string` | Framework name |
| `GetIsPlayerLoaded()` | | `boolean` | Whether local player has a loaded character |

---

## Module: character (server + client)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetIdentifier(src)` | `src: number` | `string\|nil` | Character identifier (stateId on Oxide, citizenid on QB, identifier on ESX) |
| `GetName(src)` | `src: number` | `string\|nil, string\|nil` | firstName, lastName |
| `GetMetadata(src, key)` | `src: number, key: string` | `any\|nil` | Character metadata value |
| `SetMetadata(src, key, value)` | `src: number, key: string, value: any` | `boolean` | Set character metadata |
| `GetAllMetadata(src)` | `src: number` | `table\|nil` | All metadata |
| `SetBoss(src, isBoss)` | `src: number, isBoss: boolean` | `boolean` | Set boss status (metadata fallback on ESX) |
| `IsBoss(src)` | `src: number` | `boolean` | Get boss status |
| `Search(query, limit?)` | `query: string, limit?: number` | `table[]` | Search characters by name/ID (offline). Returns `CharacterData[]` |
| `GetOffline(identifier)` | `identifier: string` | `table\|nil` | Get character data by identifier (offline) |

**CharacterData shape:**
```lua
{
    charId    = string,  -- same as identifier (stateId/citizenid/identifier)
    firstName = string,
    lastName  = string,
    dob       = string,
    gender    = number,  -- 0=male, 1=female
    stateId   = string,
    job       = { name, label, grade, gradeLabel, rank } or nil,
}
```

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetIdentifier()` | | `string\|nil` | Local player's character identifier |
| `GetName()` | | `string\|nil, string\|nil` | Local player's firstName, lastName |
| `GetMetadata(key)` | `key: string` | `any\|nil` | Local player's metadata value |

---

## Module: job (server + client)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Get(src)` | `src: number` | `JobData\|nil` | Get player's job data |
| `Set(src, jobName, grade)` | `src: number, jobName: string, grade: string\|number` | `boolean` | Set player's job |
| `SetDuty(src, status)` | `src: number, status: boolean` | `boolean` | Set duty status |
| `GetDuty(src)` | `src: number` | `boolean` | Get duty status |
| `GetPlayersWithJob(jobName)` | `jobName: string` | `number[]` | All sources with this job |

**JobData shape:**
```lua
{
    name       = string,   -- job name
    label      = string,   -- display name
    grade      = string,   -- grade name
    gradeLabel = string,   -- grade display name
    rank       = number,   -- numeric grade level
    isBoss     = boolean,
    onDuty     = boolean,
}
```

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Get()` | | `JobData\|nil` | Local player's job data |
| `GetDuty()` | | `boolean` | Local player's duty status |

---

## Module: money (server only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Add(src, accountType, amount, reason?)` | `src: number, accountType: string, amount: number, reason?: string` | `boolean` | Add money to online player |
| `Remove(src, accountType, amount, reason?)` | `src: number, accountType: string, amount: number, reason?: string` | `boolean` | Remove money from online player |
| `GetBalance(src, accountType)` | `src: number, accountType: string` | `number` | Get online player's balance |
| `AddOffline(identifier, accountType, amount)` | `identifier: string, accountType: string, amount: number` | `boolean` | Add money to offline player |
| `RemoveOffline(identifier, accountType, amount)` | `identifier: string, accountType: string, amount: number` | `boolean` | Remove money from offline player |
| `GetBalanceOffline(identifier, accountType)` | `identifier: string, accountType: string` | `number` | Get offline player's balance |

**Account types:** `'cash'`, `'bank'` (normalized internally per framework)

---

## Module: inventory (server + client)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetItemCount(src, item)` | `src: number, item: string` | `number` | Count of item in player's inventory |
| `HasItem(src, item, count?)` | `src: number, item: string, count?: number` | `boolean` | Whether player has item (count defaults to 1) |
| `AddItem(src, item, count, slot?, metadata?)` | | `boolean` | Add item to player |
| `RemoveItem(src, item, count, slot?, metadata?)` | | `boolean` | Remove item from player |
| `GetItemBySlot(src, slot)` | | `SlotData\|nil` | Get item in specific slot |
| `GetPlayerInventory(src)` | | `SlotData[]` | Get all player items |
| `OpenPlayerInventory(src, targetSrc)` | | `boolean` | Open target's inventory |
| `RegisterStash(id, label, slots, weight, owner?)` | | `boolean` | Register a stash |
| `OpenStash(src, stashId)` | | `nil` | Open a stash for player |
| `GetItemInfo(item)` | `item: string` | `table` | Get item definition `{name, label, weight, description}` (returns `{}` if not found) |
| `GetImagePath(item)` | `item: string` | `string` | Get NUI image path for item (returns `''` if not found) |

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetPlayerInventory()` | | `SlotData[]` | Local player's items |
| `GetItemCount(item)` | `item: string` | `number` | Count of item in inventory |
| `HasItem(item, count?)` | `item: string, count?: number` | `boolean` | Whether player has item |
| `GetItemInfo(item)` | `item: string` | `table` | Get item definition `{name, label, weight, description}` (returns `{}` if not found) |
| `GetImagePath(item)` | `item: string` | `string` | Get NUI image path for item (returns `''` if not found) |

---

## Module: vehicles (server only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `SearchByPlate(plate, limit?)` | `plate: string, limit?: number` | `table[]` | Search vehicles by plate with owner info |
| `GetByPlate(plate)` | `plate: string` | `table\|nil` | Single vehicle with full owner details |
| `GetByOwner(identifier)` | `identifier: string` | `table[]` | All vehicles owned by identifier |

---

## Module: notify (server + client)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Send(src, message, type?, duration?)` | `src: number, message: string, type?: string, duration?: number` | `nil` | Send notification to player |

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Send(message, type?, duration?)` | `message: string, type?: string, duration?: number` | `nil` | Show notification locally |

**Types:** `'success'`, `'error'`, `'info'`, `'warning'`

---

## Module: target (client only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `AddBoxZone(name, coords, size, heading, options, debug?)` | | `nil` | Add box target zone |
| `AddSphereZone(name, coords, radius, options, debug?)` | | `nil` | Add sphere target zone |
| `RemoveZone(name)` | | `nil` | Remove a zone by name |
| `AddLocalEntity(entity, options)` | | `nil` | Add target to entity |
| `RemoveLocalEntity(entity, optionNames?)` | | `nil` | Remove entity target |
| `AddModel(models, options)` | | `nil` | Add target to model(s) |
| `RemoveModel(model)` | | `nil` | Remove model target |
| `AddGlobalPed(options)` | `options: table` | `nil` | Add target options to all peds |
| `RemoveGlobalPed(optionNames)` | `optionNames: string[]` | `nil` | Remove global ped options by name |

---

## Module: helptext (client only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Show(message, position?)` | `message: string, position?: string` | `nil` | Show help text UI |
| `Hide()` | | `nil` | Hide help text UI |

---

## Module: progressbar (client only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Open(options, callback?)` | `options: table, callback?: function` | `boolean` | Show progress bar |

**Options:** `{ duration, label, canCancel?, disable?: { move, car, combat, mouse }, anim?: { dict, clip, flag } }`

---

## Module: vehiclekey (client only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Give(vehicle, plate?)` | `vehicle: number, plate?: string` | `nil` | Give keys to player |
| `Remove(vehicle, plate?)` | `vehicle: number, plate?: string` | `nil` | Remove keys from player |

---

## Module: callback (shared)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Register(name, handler)` | `name: string, handler: function(src, ...)` | `nil` | Register server callback |
| `Trigger(name, target, ...)` | `name: string, target: number, ...` | `any` | Trigger client callback (sync) |

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Register(name, handler)` | `name: string, handler: function(...)` | `nil` | Register client callback |
| `Trigger(name, ...)` | `name: string, ...` | `any` | Trigger server callback (sync) |

---

## Module: entity (server + client)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Create(data)` | `data: table` | `EntityRecord` | Create server entity (syncs to clients) |
| `Destroy(id)` | `id: string\|number` | `nil` | Destroy entity |
| `Get(id)` | `id: string\|number` | `table\|nil` | Get entity data |
| `Set(id, data)` | `id: string\|number, data: table` | `boolean` | Update entity fields |

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Create(entityData)` | `entityData: table` | `table` | Create client entity with proximity spawn |
| `Destroy(id)` | `id: string\|number` | `nil` | Destroy entity |
| `Get(id)` | `id: string\|number` | `table\|nil` | Get entity data |
| `GetAll()` | | `table` | All entities |
| `SetOnCreate(propertyKey, handler)` | `propertyKey: string, handler: function` | `nil` | Hook entity creation |

---

## Additional Modules (bridged from community_bridge)

These modules follow the same self-register pattern. Each has multiple implementations for different third-party resources:

| Module | Side | Description | Implementations |
|--------|------|-------------|-----------------|
| `fuel` | client | Get/set vehicle fuel | 14 (oxide-vehicles, ox_fuel, ps-fuel, etc.) |
| `weather` | client | Get weather/time | 5 (oxide-weather, qb-weathersync, etc.) |
| `input` | client | Input dialogs | 3 (ox_lib, qb-input, lation_ui) |
| `menu` | client | Context menus | 5 (oxide-menu, ox_lib, qb-menu, etc.) |
| `zones` | client | Zone definitions | 2 (oxlib, polyzone) |
| `banking` | server | Banking operations | 8 (fd_banking, qb-banking, etc.) |
| `phone` | server+client | Phone integration | 7 (oxide-phone, lb-phone, etc.) |
| `clothing` | shared+server+client | Appearance system | 7 (oxide-identity, fivem-appearance, etc.) |
| `dispatch` | server+client | Police dispatch | 14 (ps-dispatch, cd_dispatch, etc.) |
| `doorlock` | server+client | Door lock system | 4 (ox_doorlock, qb-doorlock, etc.) |
| `housing` | server+client | Property system | 5 (ps-housing, qb-houses, etc.) |
| `bossmenu` | server+client | Boss/society menus | 3 (qb-management, esx_society, etc.) |
| `skills` | server+client | Skill/XP system | 3 (evolent_skills, ot_skills, etc.) |
| `vehicleOwnership` | server | Vehicle ownership ops | 4 (oxide-vehicles, qb-garages, etc.) |

---

## Lifecycle Events

| Event | Side | Args | Description |
|-------|------|------|-------------|
| `olink:server:playerReady` | server | `(source)` | Character loaded and ready |
| `olink:server:playerUnload` | server | `(source)` | Character unloaded |
| `olink:server:playerDropped` | server | `(source)` | Player disconnected |
| `olink:client:playerReady` | client | none | Local player loaded |
| `olink:client:playerUnload` | client | none | Local player unloaded |
| `olink:client:jobChanged` | client | `(jobData)` | Local player's job changed |
