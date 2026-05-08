# o-link vs community_bridge Audit

Date: 2026-04-22

Scope:
- Full structural comparison of `o-link` against reference `community_bridge`
- Deep audit of bootstrap, config, detection flow, module registration, and adapter coverage
- Focused review of high-coverage modules first: `notify` and `phone`

Reference paths:
- `o-link`: [o-link](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link>)
- `community_bridge`: [community_bridge](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge>)

## Executive Summary

`o-link` is not yet a drop-in replacement for `community_bridge`.

The main problem is not missing adapter folders in `notify` and `phone`. Coverage there is mostly present. The larger issue is that `o-link` changed the bridge architecture and detection semantics:

- `community_bridge` builds one global bridge table and opportunistically fills it.
- `o-link` uses self-registering modules, lowercase namespaces, capability flags, default stubs, and override-aware guard clauses.

That redesign introduced several regressions that can make a module appear "not detected" even when a usable fallback exists.

There are also real port gaps outside `notify` and `phone`: `dialogue`, `shops`, `version`, `locales`, and parts of the old utility/bootstrap surface are not fully represented in `o-link`.

## Audit Method

The audit covered:

1. `fxmanifest.lua` load order and loaded folders
2. bootstrap files and shared export surfaces
3. config-driven detection in `community_bridge`
4. guard-based self-registration in `o-link`
5. top-level module inventory diffs
6. implementation inventory diffs per common namespace
7. file-level comparison of `notify`
8. file-level comparison of `phone`
9. supporting checks against current `o-link` API docs and support matrix

## Architecture Comparison

### community_bridge

Bootstrap and loading:
- Shared config in [settings/sharedConfig.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/settings/sharedConfig.lua:1>)
- Shared utility loader in [lib/init.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/lib/init.lua:1>)
- Central bridge registration in [init.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/init.lua:1>)

Behavior:
- Modules assign to globals like `Notify`, `Phone`, `Framework`
- `init.lua` wraps those globals into `Bridge.RegisterModule(...)`
- Selection is usually config-controlled through `BridgeSharedConfig.* = "auto"` or a specific resource name

### o-link

Bootstrap and loading:
- Shared state and registration helpers in [core/shared.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/core/shared.lua:1>)
- Server defaults in [core/defaults_server.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/core/defaults_server.lua:1>)
- Client defaults in [core/defaults_client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/core/defaults_client.lua:1>)
- Loader summaries in [core/loader_server.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/core/loader_server.lua:1>) and [core/loader_client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/core/loader_client.lua:1>)
- Overrides in [config.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/config.lua:1>)

Behavior:
- Modules self-register with `olink._register(namespace, impl)`
- Fallbacks self-register with `olink._registerDefault(namespace, impl)`
- Capability tracking is separate from namespace existence
- `olink.supports(...)` depends on capability flags, not just function presence

## Top-Level Resource Coverage

### Present in community_bridge but not in o-link

- `dialogue`
- `locales`
- `shops`
- `version`

### Present in o-link but not in community_bridge

- `callback`
- `character`
- `death`
- `entity`
- `gang`
- `job`
- `jobcount`
- `money`
- `needs`
- `vehicles`

This means `o-link` is broader in some internal/system namespaces, but it has not fully replaced the old bridge surface.

## Manifest and Bootstrap Differences

### community_bridge manifest

See [community_bridge fxmanifest.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/fxmanifest.lua:10>).

Important points:
- loads `settings/sharedConfig.lua`
- loads `lib/init.lua`
- loads `modules/locales/*.lua`
- loads `modules/version/server/*.lua`
- loads `modules/shops/**`
- loads `modules/dialogue/**`
- exports one central bridge through `init.lua`

### o-link manifest

See [o-link fxmanifest.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/fxmanifest.lua:14>).

Important points:
- no `settings/*`
- no `lib/init.lua`
- no `modules/locales`
- no `shops`
- no `dialogue`
- server notify is centralized in `modules/notify/server.lua`
- default stubs load before real implementations

## Highest-Risk Findings

### 1. `o-link` is not yet a full replacement

Severity: High

This is the largest audit conclusion.

`community_bridge` still ships and loads old bridge areas that are absent from `o-link`:
- `dialogue`
- `shops`
- `version`
- `locales`
- old shared utility init surface

Evidence:
- [community_bridge fxmanifest.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/fxmanifest.lua:10>)
- [o-link fxmanifest.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/fxmanifest.lua:14>)

Impact:
- servers moving from `community_bridge` to `o-link` can lose bridge-visible behavior even if `notify` and `phone` adapters exist
- some resources may fail because expected legacy bridge namespaces are simply gone

### 2. notify auto-detection is effectively biased toward `oxide-notify`

Severity: High

Many `o-link` notify adapters contain this pattern:

- guard for their own implementation
- then immediately exit if `oxide-notify` is started

Example:
- [notify/ox_lib/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/modules/notify/ox_lib/client.lua:1>)

The first two lines:
- `if not olink._guardImpl('Notify', 'ox_lib', 'ox_lib') then return end`
- `if not olink._hasOverride('Notify') and GetResourceState('oxide-notify') == 'started' then return end`

The old bridge did not do this. It used config selection:
- [settings/sharedConfig.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/settings/sharedConfig.lua:4>)

Impact:
- if a server has `oxide-notify` installed or started, other notify systems may never register
- users interpret this as `o-link` not detecting their notify module
- this is likely one of the primary real-world causes of the complaints you described

### 3. fallback modules exist but are treated as "not loaded"

Severity: High

`o-link` differentiates between:
- namespace exists
- capability exists

The critical behavior:
- `olink._register(...)` sets capability flags
- `olink._registerDefault(...)` does not

Evidence:
- [core/shared.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/core/shared.lua:73>)
- [core/shared.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/core/shared.lua:83>)
- [core/shared.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/core/shared.lua:169>)

So default `notify` and `phone` fallbacks are callable, but:
- `olink.supports('notify')` returns `false`
- loader output reports them as not loaded

Examples:
- [notify/_default/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/modules/notify/_default/client.lua:26>)
- [phone/_default/server.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/modules/phone/_default/server.lua:12>)

Impact:
- false-negative detection
- misleading debug output
- compatibility code using `olink.supports(...)` may disable behavior even though fallback functions are present

This matches the exact symptom pattern of "community bridge detected it, o-link does not."

### 4. `qb-phone` is now directly coupled to `qb-core`

Severity: Medium

In `community_bridge`, `qb-phone` used bridge abstraction:
- [community_bridge qb-phone server](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/phone/qb-phone/server.lua:24>)
- [community_bridge qb-phone server](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/phone/qb-phone/server.lua:34>)

It called:
- `Bridge.Framework.GetPlayerPhone(src)`
- `Bridge.Framework.GetPlayerIdentifier(src)`

In `o-link`, the adapter now directly grabs `qb-core`:
- [o-link qb-phone server](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/modules/phone/qb-phone/server.lua:8>)

Impact:
- narrower portability
- more direct framework assumptions
- more likely to drift if framework handling changes elsewhere in `o-link`

### 5. notify client compatibility surface was reduced

Severity: Medium

`community_bridge` client notify fallback exposed:
- `SendNotify`
- `SendNotification`
- confirm fallback event
- deprecated helptext aliases

See:
- [community_bridge notify/_default/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/notify/_default/client.lua:16>)
- [community_bridge notify/_default/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/notify/_default/client.lua:28>)
- [community_bridge notify/_default/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/notify/_default/client.lua:41>)
- [community_bridge notify/_default/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/notify/_default/client.lua:58>)

`o-link` client docs only present:
- `Send(message, type?, duration?, title?, props?)`

See:
- [o-link docs/API.md](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/docs/API.md:179>)

Also, the default implementation changed from `Framework.Notify(...)` to a GTA feed ticker:
- [community_bridge notify/_default/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/notify/_default/client.lua:16>)
- [o-link notify/_default/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/modules/notify/_default/client.lua:20>)

Impact:
- old client-side notify compatibility is incomplete
- downstream resources still expecting old bridge aliases can silently regress

### 6. support matrix overstates notify implementation reality

Severity: Low

The support matrix lists these under notify:
- `confirm`
- `oxide-core`

See:
- [docs/SUPPORT-MATRIX.md](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/docs/SUPPORT-MATRIX.md:26>)

But:
- `confirm` is just a confirm event handler, not a full notify implementation
- `oxide-core` is explicitly empty and says oxide notifications are handled by `oxide-notify`

Evidence:
- [notify/confirm/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/modules/notify/confirm/client.lua:1>)
- [notify/oxide-core/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/modules/notify/oxide-core/client.lua:1>)

Impact:
- current docs and audit surface imply more complete notify coverage than actually exists

## Notify Audit

### Coverage Comparison

Common implementations:
- `_default`
- `brutal_notify`
- `fl-notify`
- `lation_ui`
- `mythic_notify`
- `okokNotify`
- `ox_lib`
- `oxide-core`
- `oxide-notify`
- `pNotify`
- `r_notify`
- `t-notify`
- `wasabi_notify`
- `zsxui`

Only in `o-link`:
- `confirm`

Raw adapter count is not the problem.

### Key Behavioral Differences

#### community_bridge notify

Selection style:
- config-based through `BridgeSharedConfig.Notify`

Server side:
- adapter-specific server files still exist
- default server notify relays `community_bridge:Client:Notify`

Client side:
- adapters expose `SendNotify` and `SendNotification`
- `_default` uses `Framework.Notify(...)`

#### o-link notify

Selection style:
- self-registering client adapters
- centralized server relay in [modules/notify/server.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/modules/notify/server.lua:1>)
- many adapters are blocked when `oxide-notify` is started

Client API:
- standardized around `Send(...)`

#### Regressions

1. hidden precedence toward `oxide-notify`
2. fallback notify does not count as loaded capability
3. old compatibility aliases are reduced
4. `oxide-core` is listed as a notify implementation but is intentionally empty

## Phone Audit

### Coverage Comparison

Common implementations:
- `_default`
- `gksphone`
- `lb-phone`
- `okokPhone`
- `oxide-phone`
- `qb-phone`
- `qs-smartphone`
- `yseries`

`o-link` also adds:
- `oxide-phone` client adapter file, while `community_bridge` only had server-side `oxide-phone`

Raw phone coverage is close to parity.

### Key Behavioral Differences

#### community_bridge phone

Selection style:
- mostly presence-based
- some ordered exclusions for `qb-phone`
- optional config mention through `BridgeSharedConfig.Phone`

Behavior:
- global `Phone` table
- old generic relay event names like `community_bridge:Server:genericEmail`

#### o-link phone

Selection style:
- `_guardImpl(...)`
- explicit exclusion guards in specific adapters
- default fallback registers stubs only

Behavior:
- lowercase namespace `olink.phone`
- adapter-specific relay events like `o-link:phone:qb-phone:sendEmail`

### Specific Regressions and Risks

#### `qb-phone`

`community_bridge`:
- framework-abstracted through `Bridge.Framework`

`o-link`:
- direct `qb-core` dependency via `exports['qb-core']:GetCoreObject()`

Risk:
- more coupling
- less reusable behavior

#### fallback visibility

The default phone fallback is callable but not considered supported:
- [phone/_default/server.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/modules/phone/_default/server.lua:12>)

Risk:
- debug output says phone not loaded
- callers using `olink.supports('phone')` will assume nothing exists

## Other Notable Gaps Outside Notify and Phone

### Missing namespaces

Not fully ported into `o-link`:
- `shops`
- `dialogue`
- `version`
- `locales`

### Clothing shared-file drift

`community_bridge` still contains adapter `shared.lua` files for:
- `fivem-appearance`
- `illenium-appearance`

`o-link` loads `modules/clothing/**/shared.lua` in the manifest, but those files are absent for those adapters.

Evidence:
- [community_bridge fivem-appearance/shared.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/clothing/fivem-appearance/shared.lua:1>)
- [community_bridge illenium-appearance/shared.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/clothing/illenium-appearance/shared.lua:1>)

This may be harmless if the conversion helpers were intentionally removed, but it is still a port delta worth validating.

### Menu typo inherited from community_bridge

`community_bridge` contains `_defualt` under `modules/menu`.

This was not brought over to `o-link`.

This may be intentional cleanup, but if any downstream code depended on that exact old folder or behavior, it is another incompatibility point.

## Root Cause Analysis for "o-link is not detecting my module"

Most likely causes, in order:

1. The module is actually falling back to a default stub, but `olink.supports(...)` and loader output say it is not loaded.
2. A higher-priority guard is suppressing the expected adapter.
   Example: notify adapters being suppressed by `oxide-notify`.
3. The user expects the old `community_bridge` config-driven selection model, but `o-link` now expects guard/override semantics.
4. The user expects a legacy bridge namespace or API alias that no longer exists.
5. The resource area was not fully ported at all.

## Recommended Fix Order

### Phase 1: Detection and Observability

1. Change loader output to distinguish:
- real adapter loaded
- fallback loaded
- namespace unavailable

2. Add an exported inspection helper, for example:
- active implementation name per namespace
- whether the namespace is real or fallback
- why competing adapters were skipped

3. Revisit `olink.supports(...)` semantics for fallback namespaces.
   Option A:
   - leave behavior as-is, but add `olink.hasNamespace(...)`
   Option B:
   - make `_registerDefault()` optionally mark fallback capability

### Phase 2: Notify

1. Remove hard-coded `oxide-notify` suppression from other adapters, or make it configurable.
2. Add explicit active adapter reporting for notify.
3. Restore compatibility aliases where needed:
- `SendNotification`
- optional `SendNotify`

### Phase 3: Phone

1. Rework `qb-phone` to use bridge abstractions where possible.
2. Add active adapter reporting for phone.
3. Validate every phone adapter's relay event path end to end.

### Phase 4: Port Completeness

1. Decide whether `o-link` is intended to be:
- a true `community_bridge` replacement
- or a new bridge with partial compatibility

2. If true replacement is the goal, port or compatibility-shim:
- `shops`
- `dialogue`
- `version`
- `locales`
- any legacy bridge aliases still used by Oxide resources

## Practical Next Steps

Recommended immediate work:

1. Fix notify precedence first.
2. Add real-vs-fallback visibility to `o-link`.
3. Add a one-command runtime debug dump for active implementations.
4. Then do a second pass on:
- `helptext`
- `progressbar`
- `target`
- `vehiclekey`

Those are the next highest-risk categories for "worked on community_bridge, looks undetected on o-link" style issues.

## Final Conclusion

The current `o-link` tree is substantial and not a stub project. The problem is not that nothing was ported. The problem is that:

- some resource areas were not fully ported
- several compatibility assumptions changed
- module detection semantics changed
- fallback modules are intentionally invisible to capability checks
- notify specifically has a strong built-in priority bias that did not exist before

So the user complaints are credible and consistent with the codebase.

This is a real migration gap, not just user misconfiguration.
