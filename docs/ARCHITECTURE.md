# o-link Architecture

## Overview

o-link is a FiveM framework bridge that abstracts differences between Oxide, QBCore, QBX, and ESX. Resources code against `olink.*` APIs and the correct framework implementation activates at runtime via guard clauses.

## How It Works

### Loading (glob + guard clause pattern)

All implementation files are loaded via `**` glob patterns in `fxmanifest.lua`:

```lua
server_scripts {
    'modules/framework/**/server.lua',
    'modules/character/**/server.lua',
    -- etc
}
```

Every implementation file starts with a guard clause:

```lua
if GetResourceState('oxide-core') ~= 'started' then return end
```

FiveM loads ALL files. The ones whose resource isn't running `return` immediately. The one that matches calls `olink._register('namespace', { ... })` to register its functions. Last writer wins if multiple pass (controlled by priority guards).

### Priority System

When multiple implementations could be active (e.g., both ox_lib and oxide-notify are running), priority guards prevent duplicates:

```lua
-- ox_lib notify defers to oxide-notify
if GetResourceState('oxide-notify') == 'started' then return end
```

General priority: Oxide-specific > dedicated third-party > ox_lib fallback.

### Module Registration

```lua
-- core/shared.lua creates the global:
olink = {}

function olink._register(namespace, impl)
    olink[namespace] = impl
end

-- Each module file self-registers:
olink._register('framework', {
    GetName = function() return 'oxide-core' end,
    -- ...
})
```

### No Dynamic Loading

Unlike the original design (which used `LoadResourceFile` + `load()`), o-link uses the community_bridge pattern of loading all files as scripts. This avoids timing issues — all modules are available before any consuming resource starts.

## File Structure

```
o-link/
├── fxmanifest.lua              -- Glob patterns load everything
├── config.lua                  -- Override config (rarely needed)
├── core/
│   ├── shared.lua              -- olink table, _register, supports, export
│   ├── loader_server.lua       -- Summary print only
│   └── loader_client.lua       -- Summary print only
├── modules/
│   ├── callback/shared.lua     -- Loaded via shared_scripts (available immediately)
│   ├── framework/<impl>/       -- 4 frameworks: oxide-core, qb-core, qbx_core, es_extended
│   ├── character/<impl>/       -- Same 4 frameworks
│   ├── job/<impl>/             -- Same 4 frameworks
│   ├── money/<impl>/           -- oxide-accounts, qb-core, qbx_core, es_extended
│   ├── inventory/<impl>/       -- 10 inventory systems
│   ├── vehicles/<impl>/        -- oxide-vehicles, qb-garages, qbx_vehicles, esx_vehicleshop
│   ├── notify/<impl>/          -- 14 notification systems
│   ├── target/<impl>/          -- ox_target, qb-target, sleepless_interact
│   ├── helptext/<impl>/        -- 7 implementations
│   ├── progressbar/<impl>/     -- 7 implementations
│   ├── vehiclekey/<impl>/      -- 14 key systems
│   ├── entity/                 -- Framework-agnostic (server.lua + client.lua)
│   ├── fuel/<impl>/            -- 14 fuel systems
│   ├── weather/<impl>/         -- 5 weather systems
│   ├── input/<impl>/           -- 3 input systems
│   ├── menu/<impl>/            -- 5 menu systems
│   ├── zones/<impl>/           -- oxlib, polyzone
│   ├── banking/<impl>/         -- 8 banking systems
│   ├── phone/<impl>/           -- 7 phone systems
│   ├── clothing/<impl>/        -- 7 clothing systems
│   ├── dispatch/<impl>/        -- 14 dispatch systems
│   ├── doorlock/<impl>/        -- 4 doorlock systems
│   ├── housing/<impl>/         -- 5 housing systems
│   ├── bossmenu/<impl>/        -- 3 boss menu systems
│   ├── skills/<impl>/          -- 3 skill systems
│   └── vehicleOwnership/<impl>/ -- 4 ownership systems
└── lifecycle/
    ├── oxide-core/             -- Translates oxide events → olink:* events
    ├── qb-core/
    ├── qbx_core/
    └── es_extended/
```

## Modules Unique to o-link (not in community_bridge)

These modules don't exist in community_bridge — they're o-link originals:

| Module | Purpose |
|--------|---------|
| `character` | First-class character data: identifier, name, metadata, SetBoss, offline Search/GetOffline |
| `job` | Separated from framework: Get, Set, SetDuty, GetPlayersWithJob |
| `money` | Separated from framework: Add, Remove, GetBalance + offline operations |
| `vehicles` | Vehicle search: SearchByPlate, GetByPlate, GetByOwner |
| `entity` | Proximity-based entity system with server→client sync |
| `callback` | Framework-agnostic RPC system |

## Identifier Convention

| Framework | GetIdentifier returns | DB column |
|-----------|----------------------|-----------|
| Oxide | `stateId` (e.g., "ABC123") | `characters.state_id` |
| QBCore | `citizenid` (e.g., "HJK84920") | `players.citizenid` |
| QBX | `citizenid` | `players.citizenid` |
| ESX | `identifier` (license) | `users.identifier` |

Internal o-link modules that need framework-specific DB primary keys (e.g., oxide-accounts needs numeric `char_id`) resolve the identifier internally via `ResolveCharId()`. Consumers never need to know about this.

## Event Naming Convention

- **Local events** (TriggerEvent): `olink:` prefix — `olink:server:playerReady`, `olink:client:playerUnload`
- **Network events** (TriggerClientEvent): `o-link:` prefix — `o-link:client:notify`, `o-link:client:entity:create`
- **Callback events**: `o-link:CS:Callback`, `o-link:SC:Callback`

## Self-Registration Pattern

Resources that provide APIs through o-link (like oxide-banking) register themselves after initialization:

```lua
-- oxide-banking depends on o-link (in fxmanifest)
-- o-link does NOT depend on oxide-banking
-- oxide-banking self-registers after init:
olink._register('banking', { ... })
```

This avoids circular dependencies while still making the API available through the bridge.

## Ensure Order

```
# Framework core (before o-link)
ensure oxide-core / qb-core / es_extended
ensure oxide-accounts / oxide-inventory / oxide-vehicles / etc

# Bridge (after resources it detects, before resources that consume it)
ensure o-link

# Resources that self-register AND consume o-link
ensure oxide-banking

# Pure consumers
ensure oxide-police
ensure oxide-shops
```
