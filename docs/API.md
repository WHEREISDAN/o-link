# o-link API Reference

This file documents the public surface that has been verified against the current codebase.

For implementation coverage by resource name, see [`SUPPORT-MATRIX.md`](./SUPPORT-MATRIX.md).
For standalone server wiring, see [`STANDALONE-INTEGRATION.md`](./STANDALONE-INTEGRATION.md).

## Consuming o-link

```lua
olink = exports['o-link']:olink()
Callback = olink.callback
```

```lua
dependencies {
    'ox_lib',
    'oxmysql',
    'o-link',
}
```

## Capability Checks

```lua
olink.supports('character')
olink.supports('character.SetBoss')
olink.supports('vehicles.GetByOwner')
olink.supports('vehicleproperties.GetVehicleProperties')
```

## Module: callback (shared)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Register(name, handler)` | `name: string, handler: function(src, ...)` | `nil` | Register a server callback |
| `Trigger(name, target, ...)` | `name: string, target: number\|number[], ...` | `any` | Trigger a client callback. If no Lua callback arg is passed, this awaits and returns the response. |

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Register(name, handler)` | `name: string, handler: function(...)` | `nil` | Register a client callback |
| `Trigger(name, ...)` | `name: string, ...` | `any` | Trigger a server callback. If no Lua callback arg is passed, this awaits and returns the response. |

## Module: framework (server + client)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetName()` | | `string` | Framework name: `'oxide-core'`, `'qb-core'`, `'qbx_core'`, or `'es_extended'` |
| `GetIsPlayerLoaded(src)` | `src: number` | `boolean` | Whether the player currently has an active character/session |
| `GetPlayers()` | | `number[]` | Online player source IDs |
| `GetJobs()` | | `table[]` | Framework jobs list. Oxide currently returns `{}`. |
| `IsAdmin(src)` | `src: number` | `boolean` | ACE permission check against `command` |
| `RegisterUsableItem(itemName, cb)` | `itemName: string, cb: function(src, itemData)` | `nil` | Register item use callback through the active framework |
| `Logout(src)` | `src: number` | `boolean` | Trigger the framework-specific logout flow |

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetName()` | | `string` | Framework name |
| `GetIsPlayerLoaded()` | | `boolean` | Whether the local player is loaded |

## Module: character (server + client)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetIdentifier(src)` | `src: number` | `string\|nil` | Normalized character identifier |
| `GetName(src)` | `src: number` | `string\|nil, string\|nil` | `firstName, lastName` |
| `GetMetadata(src, key)` | `src: number, key: string` | `any\|nil` | Metadata value |
| `SetMetadata(src, key, value)` | `src: number, key: string, value: any` | `boolean` | Set metadata |
| `GetAllMetadata(src)` | `src: number` | `table\|nil` | Full metadata table |
| `SetBoss(src, isBoss)` | `src: number, isBoss: boolean` | `boolean` | Set boss state |
| `IsBoss(src)` | `src: number` | `boolean` | Get boss state |
| `Search(query, limit?)` | `query: string, limit?: number` | `table[]` | Search offline character records |
| `GetOffline(identifier)` | `identifier: string` | `table\|nil` | Get offline character data |

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetIdentifier()` | | `string\|nil` | Local player's identifier |
| `GetName()` | | `string\|nil, string\|nil` | `firstName, lastName` |
| `GetMetadata(key)` | `key: string` | `any\|nil` | Metadata value |

## Module: job (server + client)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Get(src)` | `src: number` | `JobData\|nil` | Get normalized job data |
| `Set(src, jobName, grade)` | `src: number, jobName: string, grade: string\|number` | `boolean` | Set player job |
| `SetDuty(src, status)` | `src: number, status: boolean` | `boolean` | Set duty state |
| `GetDuty(src)` | `src: number` | `boolean` | Get duty state |
| `GetPlayersWithJob(jobName)` | `jobName: string` | `number[]` | Online players with the job |

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Get()` | | `JobData\|nil` | Local player's normalized job data |
| `GetDuty()` | | `boolean` | Local duty state |

**JobData shape**

```lua
{
    name       = string,
    label      = string,
    grade      = string,
    gradeLabel = string,
    rank       = number,
    isBoss     = boolean,
    onDuty     = boolean,
}
```

## Module: money (server only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Add(src, accountType, amount, reason?)` | `src: number, accountType: string, amount: number, reason?: string` | `boolean` | Add money to an online player |
| `Remove(src, accountType, amount, reason?)` | `src: number, accountType: string, amount: number, reason?: string` | `boolean` | Remove money from an online player |
| `GetBalance(src, accountType)` | `src: number, accountType: string` | `number` | Online balance |
| `AddOffline(identifier, accountType, amount)` | `identifier: string, accountType: string, amount: number` | `boolean` | Add money offline |
| `RemoveOffline(identifier, accountType, amount)` | `identifier: string, accountType: string, amount: number` | `boolean` | Remove money offline |
| `GetBalanceOffline(identifier, accountType)` | `identifier: string, accountType: string` | `number` | Offline balance |

## Module: inventory (server + client)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetItemCount(src, item)` | `src: number, item: string` | `number` | Count item |
| `HasItem(src, item, count?)` | `src: number, item: string, count?: number` | `boolean` | Inventory check |
| `AddItem(src, item, count, slot?, metadata?)` | | `boolean` | Add item |
| `RemoveItem(src, item, count, slot?, metadata?)` | | `boolean` | Remove item |
| `GetItemBySlot(src, slot)` | | `table\|nil` | Slot data |
| `GetPlayerInventory(src)` | | `table[]` | Full inventory |
| `OpenPlayerInventory(src, targetSrc)` | | `boolean` | Open another player's inventory |
| `RegisterStash(id, label, slots, weight, owner?)` | | `boolean` | Register stash |
| `OpenStash(src, stashId)` | | `nil` | Open stash |
| `GetItemInfo(item)` | `item: string` | `table` | Item definition or `{}` |
| `GetImagePath(item)` | `item: string` | `string` | Image path or `''` |

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetPlayerInventory()` | | `table[]` | Local inventory |
| `GetItemCount(item)` | `item: string` | `number` | Count item |
| `HasItem(item, count?)` | `item: string, count?: number` | `boolean` | Inventory check |
| `GetItemInfo(item)` | `item: string` | `table` | Item definition or `{}` |
| `GetImagePath(item)` | `item: string` | `string` | Image path or `''` |

## Module: vehicles (server only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `SearchByPlate(plate, limit?)` | `plate: string, limit?: number` | `table[]` | Search by plate |
| `GetByPlate(plate)` | `plate: string` | `table\|nil` | Vehicle record with owner data |
| `GetByOwner(identifier)` | `identifier: string` | `table[]` | Vehicles for an owner |

## Module: vehicleproperties (client only)

Registered from [`../modules/vehicles/properties/client.lua`](../modules/vehicles/properties/client.lua).

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetVehicleProperties(vehicle)` | `vehicle: number` | `table\|nil` | Serialize GTA vehicle properties |
| `SetVehicleProperties(vehicle, props)` | `vehicle: number, props: table` | `boolean` | Apply serialized properties |

## Module: notify (server + client)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Send(src, message, type?, duration?)` | `src: number, message: string, type?: string, duration?: number` | `nil` | Send notify event to client |
| `Confirm(src, options, callback)` | `src: number, options: table, callback: function(accepted)` | `nil` | Open client confirm UI and resolve through callback |

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Send(message, type?, duration?)` | `message: string, type?: string, duration?: number` | `nil` | Show notification locally |

## Module: helptext (server + client)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Show(src, message, position?)` | `src: number, message: string, position?: string` | `nil` | Relay helptext to a client |
| `Hide(src)` | `src: number` | `nil` | Hide helptext for a client |

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Show(message, position?)` | `message: string, position?: string` | `nil` | Show helptext locally |
| `Hide()` | | `nil` | Hide helptext locally |

## Module: target (client only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `AddBoxZone(name, coords, size, heading, options, debug?)` | | `nil` | Add box zone |
| `AddSphereZone(name, coords, radius, options, debug?)` | | `nil` | Add sphere zone |
| `RemoveZone(name)` | | `nil` | Remove zone |
| `AddLocalEntity(entity, options)` | | `nil` | Add local entity target |
| `RemoveLocalEntity(entity, optionNames?)` | | `nil` | Remove local entity target |
| `AddModel(models, options)` | | `nil` | Add model target |
| `RemoveModel(model)` | | `nil` | Remove model target |
| `AddGlobalPed(options)` | `options: table` | `nil` | Add global ped options |
| `RemoveGlobalPed(optionNames)` | `optionNames: string[]` | `nil` | Remove global ped options |
| `AddGlobalVehicle(options)` | `options: table` | `nil` | Add global vehicle options |
| `RemoveGlobalVehicle(optionNames)` | `optionNames: string[]` | `nil` | Remove global vehicle options |
| `AddNetworkedEntity(netId, options)` | `netId: number\|number[], options: table` | `nil` | Add target options to a networked entity |
| `RemoveNetworkedEntity(netId, optionNames?)` | `netId: number\|number[], optionNames?: string\|string[]` | `nil` | Remove target options from a networked entity |

## Module: progressbar (client only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Open(options, callback?)` | `options: table, callback?: function` | `boolean` | Open progress UI |

## Module: vehiclekey (client only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Give(vehicle, plate?)` | `vehicle: number, plate?: string` | `nil` | Give keys |
| `Remove(vehicle, plate?)` | `vehicle: number, plate?: string` | `nil` | Remove keys |

## Module: entity (server + client)

### Server
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Create(data)` | `data: table` | `table` | Create tracked entity record |
| `Destroy(id)` | `id: string\|number` | `nil` | Destroy entity |
| `Get(id)` | `id: string\|number` | `table\|nil` | Get entity |
| `Set(id, data)` | `id: string\|number, data: table` | `boolean` | Merge or update entity |

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Create(entityData)` | `entityData: table` | `table` | Create client entity wrapper |
| `Destroy(id)` | `id: string\|number` | `nil` | Destroy entity |
| `Get(id)` | `id: string\|number` | `table\|nil` | Get entity |
| `GetAll()` | | `table` | All entities |
| `SetOnCreate(propertyKey, handler)` | `propertyKey: string, handler: function` | `nil` | Register create hook |

## Module: jobcount (server only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetJobCount(jobName)` | `jobName: string` | `number` | Count online players for a job |
| `GetJobCountTotal(tbl)` | `tbl: string[]` | `number` | Sum counts across jobs |
| `AddJobCount(src, jobName)` | `src: number, jobName: string` | `nil` | Force-add or update a job count entry |
| `RemoveJobCount(src, jobName?)` | `src: number, jobName?: string` | `nil` | Remove a source from tracking |
| `SearchJobCountBySource(src)` | `src: number` | `string\|nil` | Get tracked job name for a source |

## Additional verified namespaces

These namespaces are present in the current implementation and load through the same self-registration pattern, but this file does not attempt to fully document every function signature in every implementation:

| Namespace | Side | Verified implementation folders |
|-----------|------|---------------------------------|
| `fuel` | client | 14 |
| `weather` | client | 5 |
| `input` | client | 3 |
| `menu` | client | 5 |
| `zones` | client | 2 |
| `banking` | server | 8 |
| `phone` | server + client | 7 |
| `clothing` | shared + server + client | 7 |
| `dispatch` | server + client | 15 |
| `doorlock` | server + client | 4 |
| `housing` | server + client | 5 |
| `bossmenu` | server + client | 3 |
| `skills` | server + client | 4 |
| `vehicleOwnership` | server | 4 |
| `death` | server + client | 4 |
| `needs` | server | 4 |
| `gang` | server + client | 4 |

## Lifecycle events

| Event | Side | Args | Description |
|-------|------|------|-------------|
| `olink:server:playerReady` | server | `(source)` | Player is ready |
| `olink:server:playerUnload` | server | `(source)` | Player unload or logout |
| `olink:server:playerDropped` | server | `(source)` | Disconnect |
| `olink:server:jobChanged` | server | `(source, jobName)` | Server-side job change relay |
| `olink:client:playerReady` | client | none | Local player ready |
| `olink:client:playerUnload` | client | none | Local player unloaded |
| `olink:client:jobChanged` | client | `(jobData)` | Local job update |
