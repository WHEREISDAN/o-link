# Standalone Integration Guide

This guide is for server owners and developers who want to run Oxide resources without relying on one of the built-in framework paths.

The goal is not to build full bridge coverage for every namespace. The goal is to identify what your target resource needs, then add only that support to `o-link`.

## Important Constraint

For encrypted releases, the correct workflow is:

1. Open a ticket in the Oxide Discord.
2. Tell us which Oxide resource you are trying to run.
3. Ask which `o-link` namespaces and functions that resource depends on.
4. Build support only for that reported surface.

That is the supported path for standalone servers running the encrypted version.

## What You Are Actually Wiring

Oxide resources do not talk directly to QBCore, QBX, ESX, or Oxide resources. They talk to `o-link`:

```lua
olink = exports['o-link']:olink()
Callback = olink.callback
```

That means your standalone work usually looks like this:

1. Pick the Oxide resource you want to run.
2. Get the exact `o-link` namespaces and functions that resource uses.
3. Add an implementation for those namespaces inside `o-link`.
4. Force your implementation with `Config.Overrides` while testing.

If the resource never calls a function, you do not need to implement it.

## How To Identify What The Resource Depends On

### If you are using the encrypted release

Open a Discord ticket and ask for the `o-link` dependency surface for the specific resource you are trying to run.

Good ticket example:

```text
I am running a standalone server and need to wire custom o-link support.
Which o-link namespaces and functions does <resource-name> require?
Please list client and server requirements separately if they differ.
```

What you want back from that ticket:

- Every namespace used, such as `character`, `money`, `inventory`, or `target`
- Every function used in that namespace, such as `GetIdentifier` or `Remove`
- Whether the call happens on `client`, `server`, or both
- Whether the resource uses `Callback = olink.callback`
- Whether any dependencies are optional behind `olink.supports(...)`

### If you are working from source internally

If you do have source access, you can inspect `olink.` calls directly. That is a maintainer workflow, not the encrypted-release workflow this guide is primarily written for.

## Verified Example Dependency Surfaces

These lists were verified from the current source tree in this repository. They are useful examples of the kind of dependency report you should request in your ticket.

### `oxide-roadsideassistancejob`

- `character`: `GetIdentifier`, `GetName`
- `clothing`: `GetAppearance`, `IsMale`, `Revert`, `SetAppearance`
- `framework`: `GetIsPlayerLoaded`
- `fuel`: `SetFuel`
- `menu`: `Open`
- `money`: `Add`, `Remove`
- `notify`: `Send`
- `phone`: `SendEmail`
- `progressbar`: `Open`
- `target`: `AddLocalEntity`, `AddSphereZone`, `RemoveLocalEntity`, `RemoveZone`
- `vehiclekey`: `Give`, `Remove`

### `oxide-banking`

- `character`: `GetIdentifier`, `GetName`, `GetOffline`, `Search`
- `framework`: `GetIsPlayerLoaded`, `GetJobs`, `GetName`, `GetPlayers`, `IsAdmin`, `RegisterUsableItem`
- `inventory`: `AddItem`, `GetPlayerInventory`, `HasItem`, `RemoveItem`
- `job`: `Get`
- `money`: `Add`, `AddOffline`, `GetBalance`, `GetBalanceOffline`, `Remove`, `RemoveOffline`
- `notify`: `Send`
- `progressbar`: `Open`
- `target`: `AddModel`, `AddSphereZone`, `RemoveModel`, `RemoveZone`

### `oxide-weaponprinting`

- `character`: `GetIdentifier`, `GetMetadata`, `SetMetadata`
- `framework`: `GetIsPlayerLoaded`, `RegisterUsableItem`
- `inventory`: `AddItem`, `GetImagePath`, `GetItemBySlot`, `GetItemCount`, `GetPlayerInventory`, `RemoveItem`, `SetMetadata`
- `notify`: `Send`
- `progressbar`: `Open`
- `target`: `AddLocalEntity`, `RemoveLocalEntity`

## Map The Dependency To An `o-link` Module

Each namespace lives under `o-link/modules/<namespace>/`.

Common examples:

- `character` -> `modules/character/<implementation>/server.lua` and sometimes `client.lua`
- `money` -> `modules/money/<implementation>/server.lua`
- `inventory` -> `modules/inventory/<implementation>/server.lua` and sometimes `client.lua`
- `target` -> `modules/target/<implementation>/client.lua`
- `notify` -> `modules/notify/<implementation>/client.lua` plus the shared server relay in `modules/notify/server.lua`
- `clothing` -> `modules/clothing/<implementation>/shared.lua`, `server.lua`, and `client.lua` depending on the implementation

The load pattern is verified in [`../fxmanifest.lua`](../fxmanifest.lua). `o-link` loads broad glob patterns, and each implementation file decides for itself whether it should register.

## Create Only The Files You Need

You do not need a full framework adapter just because your server is standalone.

Examples:

- If your target resource only needs `target` and `notify`, add only those namespaces.
- If your target resource only needs server-side `money` and `character`, do not create client files for them.
- If the resource uses `Callback = olink.callback`, you usually do not need to implement anything for that. `callback` is already provided by `modules/callback/shared.lua`.

A good starting rule is: one namespace at a time, one failing requirement at a time.

## Register A New Implementation

Create a new implementation folder under the namespace you are adding.

Example path:

```text
o-link/modules/money/my-standalone/server.lua
```

Use the same guard and registration style as the shipped adapters.

### If your standalone system is its own resource

```lua
if not olink._guardImpl('Money', 'my-standalone', 'my-standalone-core') then return end

olink._register('money', {
    GetBalance = function(src, accountType)
        return 0
    end,

    Add = function(src, accountType, amount, reason)
        return true
    end,

    Remove = function(src, accountType, amount, reason)
        return true
    end,
})
```

### If there is no backing resource to check

`olink._guardImpl(..., false)` is supported by the current `core/shared.lua` implementation and skips the resource-state check.

```lua
if not olink._guardImpl('Money', 'my-standalone', false) then return end

olink._register('money', {
    GetBalance = function(src, accountType)
        return 0
    end,

    Add = function(src, accountType, amount, reason)
        return true
    end,

    Remove = function(src, accountType, amount, reason)
        return true
    end,
})
```

Important rules:

- The namespace passed to `_register` must match what consumers call, such as `money`, `inventory`, or `target`.
- The function names must match the reported dependency list exactly.
- Use the exact override name you want to set later in `Config.Overrides`. In the example above, that is `my-standalone`.

## Use `Config.Overrides` While Developing

`Config.Overrides` is the safest way to force your new implementation while you test.

Example:

```lua
Config.Overrides = {
    Character = 'my-standalone',
    Money = 'my-standalone',
    Inventory = 'my-standalone',
    Target = 'my-standalone',
}
```

Current behavior, verified from `core/shared.lua`:

- Override values are matched case-insensitively.
- Overrides are per namespace.
- When an override is set for a namespace, only the matching implementation is allowed to load for that namespace.
- The selected implementation bypasses the normal priority blockers for that namespace.

This is useful when your server has other compatible resources installed and you do not want auto-detection to pick the wrong adapter.

## Validate Namespace By Namespace

Use small checks instead of trying to make the whole server work at once.

Validation checklist:

1. Start `o-link` and confirm your implementation file does not return early.
2. Check that the consumer resource starts after `o-link`.
3. Verify the namespace exists with `olink.supports('money')` or `olink.supports('money.GetBalance')`.
4. Trigger one real path in-game that exercises the function you just added.
5. Move to the next missing function only after the previous one works.

If a resource requirement is reported as optional behind `olink.supports('...')`, you may be able to leave that function unimplemented and accept reduced functionality. If the function is reported as a direct call, the function is required.

## Practical Advice For Standalone Servers

- Start with the Oxide resource you care about most. Do not try to support every Oxide resource at once.
- Build the smallest possible adapter surface first.
- Keep framework concerns separated. In `o-link`, `framework`, `character`, `job`, and `money` are different namespaces even if your standalone system stores them in one place.
- Reuse existing adapters as references. The shipped implementations under `modules/*/*` are the project-standard examples.
- Prefer returning normalized data in the shape expected by the existing API docs rather than exposing your own internal objects directly.
- If you are on the encrypted release, treat the Discord ticket response as the source of truth for what the resource needs.

## When You Need More Than A Minimal Adapter

You are no longer doing minimal standalone wiring if:

- multiple Oxide resources need the same namespace but with different function coverage
- you need lifecycle behavior from `lifecycle/**`
- you want auto-detection without `Config.Overrides`
- you want your implementation to behave like a first-class maintained adapter

At that point, treat it as a full adapter project instead of a one-off bridge patch.
