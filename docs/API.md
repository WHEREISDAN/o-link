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
| `ItemList()` | | `table` | Passthrough to the active inventory's item definitions (community_bridge compat) |
| `GetStatus(src, column)` | `src: number, column: string` | `any\|nil` | Read a framework status column. Delegates hunger/thirst/stress to `needs.GetNeed`; returns `nil` otherwise. |

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
| `GetDob(src)` | `src: number` | `string\|nil` | Convenience wrapper for the player's date of birth |
| `GetAccountCharacterIdentifiers(identifier)` | `identifier: string` | `string[]` | All character identifiers tied to the same game account. Returns `{identifier}` on ESX (identifier == license); on QB/QBX resolves via the `players.license` column. |

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
| `DoesPlayerHaveJob(src, jobName, minGrade?)` | `src: number, jobName: string, minGrade: number\|nil` | `boolean` | True if player holds the job (optionally at or above the given grade) |

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
| `IsOwnedBy(src, plate)` | `src: number, plate: string` | `boolean` | Whether the vehicle with that plate belongs to the player |
| `GetOwnedPlates(src)` | `src: number` | `string[]` | Plates owned by the player |

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
| `Send(src, message, type?, duration?, title?, props?)` | `src: number, message: string, type?: string, duration?: number, title?: string, props?: table` | `nil` | Send notification to a client. `title` is surfaced by adapters that support it (okokNotify, ox_lib, t-notify, r_notify, pNotify, lation_ui, zsxui, brutal_notify, FL-Notify, oxide-notify). `props` are merged for adapters that accept extra fields (ox_lib, oxide-notify). |
| `SendNotification(src, title, message, type?, duration?, props?)` | | `nil` | community_bridge-style alias — same event under the hood, with `title` as the first data argument. |
| `Confirm(src, options, callback)` | `src: number, options: table, callback: function(accepted)` | `nil` | Open client confirm UI and resolve through callback |

### Client
| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Send(message, type?, duration?, title?, props?)` | | `nil` | Show notification locally. Adapters that don't support `title`/`props` silently ignore them. |

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
| `GetResourceName()` | | `string` | Name of the active target resource |
| `DisableTargeting(bool)` | `bool: boolean` | `nil` | Toggle targeting on/off (ox_target only; no-op on others) |
| `AddBoxZone(name, coords, size, heading, options, debug?)` | | `any` | Add box zone (returns adapter-specific id) |
| `AddSphereZone(name, coords, radius, options, debug?)` | | `any` | Add sphere zone |
| `RemoveZone(name)` | `name: string` | `nil` | Remove zone |
| `AddLocalEntity(entity, options)` | | `nil` | Add local entity target |
| `RemoveLocalEntity(entity, optionNames?)` | | `nil` | Remove local entity target |
| `AddModel(models, options)` | | `nil` | Add model target |
| `RemoveModel(model)` | | `nil` | Remove model target |
| `AddGlobalPed(options)` | `options: table` | `nil` | Add options to every NPC ped |
| `RemoveGlobalPed(optionNames)` | `optionNames: string[]` | `nil` | Remove global ped options |
| `AddGlobalPlayer(options)` | `options: table` | `nil` | Add options to every player ped |
| `RemoveGlobalPlayer(optionNames?)` | `optionNames?: string[]` | `nil` | Remove global player options |
| `AddGlobalVehicle(options)` | `options: table` | `nil` | Add global vehicle options |
| `RemoveGlobalVehicle(options)` | `options: table\|string[]` | `nil` | Remove global vehicle options. Accepts an options table (names are extracted) or a raw name list. |
| `AddNetworkedEntity(netId, options)` | `netId: number\|number[], options: table` | `nil` | Add target options to a networked entity |
| `RemoveNetworkedEntity(netId, optionNames?)` | `netId: number\|number[], optionNames?: string\|string[]` | `nil` | Remove target options from a networked entity |

Zones created through `AddBoxZone` / `AddSphereZone` are tracked per calling resource and cleaned up automatically when that resource stops.

## Module: progressbar (client only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Open(options, callback?, isQBInput?)` | `options: table, callback?: function, isQBInput?: boolean` | `boolean` | Open progress UI. When `isQBInput` is true, `options` is treated as QB-format (`controlDisables`, `animation`, `prop`/`propTwo`) and converted internally. The `qb-progressbar` adapter takes a `qbFormat` boolean with the inverse meaning (skip conversion because options are already QB-shaped). |

## Module: menu (client only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetResourceName()` | | `string` | Active menu resource |
| `Open(data, useQb?)` | `data: table, useQb?: boolean` | `string` | Open a context menu (returns the menu id). Auto-generates `data.id` if not provided. |
| `OpenMenu(id, data, useQBinput?)` | `id: string, data: table, useQBinput?: boolean` | `string` | community_bridge-style alias for `Open`. Sets `data.id` from the first argument. |

## Module: vehiclekey (client only)

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetResourceName()` | | `string` | Active vehicle key resource |
| `Give(vehicle, plate?)` | `vehicle: number, plate?: string` | `nil` | Give keys to the local player |
| `Remove(vehicle, plate?)` | `vehicle: number, plate?: string` | `nil` | Remove keys from the local player |
| `GiveKeys(vehicle, plate?)` | | `nil` | community_bridge-style alias for `Give` |
| `RemoveKeys(vehicle, plate?)` | | `nil` | community_bridge-style alias for `Remove` |

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

## Module: dispatch (server + client)

The base `SendAlert` contract is supported by every adapter. Adapters backed by
`oxide-dispatch` additionally expose persistent alert management — read/respond/close
— callable from both sides. When a non-persistent adapter is active, the extension
functions return empty results; guard with `olink.supports('dispatch.GetActiveAlerts')`.

### Client

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `SendAlert(data)` | `data: table` | `nil` | Submit a new alert. `data = { code?, title?, message?, priority?, icon?, jobs?, coords?, vehicle_model?, vehicle_plate?, blipData?, expireMinutes?, source_type? }` |
| `GetActiveAlerts(jobFilter?)` | `jobFilter?: string\|string[]` | `table[]` | Active alerts, optionally scoped to a responder group (`'police'`, `'ems'`, `'fire'`) or raw job |
| `GetAlert(alertId)` | `alertId: integer` | `table\|nil` | One alert with responder list |
| `RespondToAlert(alertId)` | `alertId: integer` | `boolean, string?` | Attach self as responder |
| `StopResponding(alertId)` | `alertId: integer` | `boolean` | Detach self as responder |
| `UpdateResponderStatus(alertId, status)` | `alertId: integer, status: 'responding'\|'on_scene'\|'cleared'` | `boolean` | Transition responder status |
| `CloseAlert(alertId, reason?)` | `alertId: integer, reason?: string` | `boolean, string?` | Close an alert |

### Server

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `CreateAlert(data)` | `data: table` | `table\|nil` | Server-authored alert (911, panic, manual) — same shape as `SendAlert` |
| `GetActiveAlerts(jobFilter?)` | `jobFilter?: string\|string[]` | `table[]` | |
| `GetAlert(alertId)` | `alertId: integer` | `table\|nil` | |
| `RespondToAlert(alertId, src)` | `alertId: integer, src: number` | `boolean, string?` | |
| `StopResponding(alertId, src)` | `alertId: integer, src: number` | `boolean` | |
| `UpdateResponderStatus(alertId, src, status)` | `alertId: integer, src: number, status: string` | `boolean` | |
| `CloseAlert(alertId, src?, reason?)` | `alertId: integer, src?: number, reason?: string` | `boolean, string?` | |

### Client-side events (subscribe to these to react to live alert changes)

| Event | Args | Description |
|-------|------|-------------|
| `olink:client:dispatch:alertCreated` | `(alert)` | New alert dispatched to your job |
| `olink:client:dispatch:alertUpdated` | `(alert)` | Responder attached / status change |
| `olink:client:dispatch:alertClosed` | `(alertId, reason)` | Alert closed (`'closed'` or `'expired'`) |

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
| `dispatch` | server + client | 16 |
| `doorlock` | server + client | 4 |
| `housing` | server + client | 5 |
| `bossmenu` | server + client | 3 |
| `skills` | server + client | 4 |
| `vehicleOwnership` | server | 4 |
| `death` | server + client | 4 |
| `needs` | server | 4 |
| `gang` | server + client | 4 |

**Gang helpers (server)**

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `Get(src)` | `src: number` | `table\|nil` | Normalized gang data |
| `Set(src, name, label?, gradeName?, gradeLabel?, gradeRank?)` | | `boolean` | Assign gang (or `nil`/`'none'` to clear) |
| `DoesPlayerHaveGang(src, gangName, minGrade?)` | `src: number, gangName: string, minGrade: number\|nil` | `boolean` | True if player belongs to gang (optionally at or above the given grade) |

**Clothing helpers (server, adapter-dependent)**

Functions common across `esx_skin`, `qb-clothing`, `fivem-appearance`, `illenium-appearance`, `rcore_clothing`, `oxide-clothing`, `oxide-identity`:

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `GetAppearance(src, fullData?)` | `src: number, fullData?: boolean` | `table\|nil` | Converted skin data, or full data when `fullData` is true |
| `SetAppearance(src, data, updateBackup?, save?)` | | `table\|nil` | Apply appearance and (optionally) persist to DB |
| `SetAppearanceExt(src, data)` | | `nil` | Apply gender-specific data (`{ male = ..., female = ... }`) |
| `Revert(src)` | `src: number` | `table\|nil` | Restore previous backup appearance |
| `OpenMenu(src)` | `src: number` | `nil` | Open the adapter's clothing menu for the player |
| `IsMale(src)` | `src: number` | `boolean` | True when the player ped uses the male freemode model |
| `SaveOutfit(src, name, data)` | | `number\|nil` | Persist a named outfit, returns its id |
| `GetOutfits(src)` | | `table[]` | Saved outfits for the player |
| `UpdateOutfit(src, outfitId, name, data)` | | `boolean` | Update a stored outfit |
| `DeleteOutfit(src, outfitId)` | | `boolean` | Delete a stored outfit |
| `Save(src)` | `src: number` | `boolean` | Flush cached skin to DB (esx_skin) |

Adapter-specific: `esx_skin` and `qb-clothing` use the framework's native table (`users.skin` / `playerskins`); `fivem-appearance` mirrors QB-style storage. The shared helpers (`EsxSkinConvertTo/FromDefault`, `QbClothingConvertTo/FromDefault`) live in each adapter's `shared.lua`.

**Vehicles helpers (server)**

| Function | Args | Returns | Description |
|----------|------|---------|-------------|
| `SearchByPlate(plate, limit?)` | | `table[]` | Search by plate |
| `GetByPlate(plate)` | | `table\|nil` | Vehicle record with owner data |
| `GetByOwner(identifier)` | | `table[]` | Vehicles for an owner |
| `IsOwnedBy(src, plate)` | | `boolean` | True if the vehicle with that plate belongs to the player |
| `GetOwnedPlates(src)` | | `string[]` | Plates owned by the player |

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
