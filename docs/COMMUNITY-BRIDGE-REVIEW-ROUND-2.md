# Community Bridge Review Round 2

This review compares `o-link` against `community_bridge` again with `community_bridge` treated as the source of truth.

Scope of this pass:
- verify the recent detection / observability fixes did not leave other porting gaps
- identify remaining behavior differences that were not properly ported
- focus on practical replacement compatibility, not redesign ideas

## Findings

### 1. High: Client-side notify is still not fully ported

`community_bridge` client notify adapters expose:
- `GetResourceName`
- `SendNotify`
- `SendNotification`

The default notify client also keeps deprecated helptext passthroughs:
- `ShowHelpText`
- `HideHelpText`

`o-link` client notify adapters now expose only `Send`, and most real adapters do not expose `GetResourceName` at all. That means detection may now work correctly, but client resources still written against the old bridge notify surface are not drop-in compatible.

References:
- [community_bridge/modules/notify/ox_lib/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/notify/ox_lib/client.lua:7>)
- [community_bridge/modules/notify/_default/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/notify/_default/client.lua:16>)
- [community_bridge/modules/notify/_default/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/notify/_default/client.lua:58>)
- [o-link/modules/notify/ox_lib/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/modules/notify/ox_lib/client.lua:3>)
- [o-link/modules/notify/_default/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/modules/notify/_default/client.lua:26>)

### 2. High: Server-side notify is still missing part of the old bridge API

`community_bridge` server notify behavior exposed:
- `SendNotify`
- `SendNotification`
- `Confirm`
- `GetResourceName` depending on implementation

`o-link` currently exposes:
- `Send`
- `SendNotification`
- `Confirm`

There is no `SendNotify` alias on the server notify surface, and no active notify-resource name surface comparable to the old bridge shape. Any server resource still calling `Notify.SendNotify(...)` is not actually ported.

References:
- [community_bridge/modules/notify/_default/server.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/notify/_default/server.lua:19>)
- [community_bridge/modules/notify/oxide-notify/server.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/notify/oxide-notify/server.lua:9>)
- [o-link/modules/notify/server.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/modules/notify/server.lua:4>)

### 3. Medium: Default helptext fallback still does not match community_bridge behavior

In `community_bridge`, default helptext on the client delegates to:
- `Framework.ShowHelpText`
- `Framework.HideHelpText`

That means the fallback inherits the active framework's preferred text UI behavior.

In `o-link`, the default helptext fallback was changed to direct GTA help text natives instead. Detection is fine, but fallback behavior is no longer aligned with source-of-truth behavior on QB, QBX, and Oxide-based setups.

References:
- [community_bridge/modules/helptext/_default/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/helptext/_default/client.lua:8>)
- [community_bridge/modules/framework/qb-core/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/ref/community_bridge/modules/framework/qb-core/client.lua:80>)
- [o-link/modules/helptext/_default/client.lua](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/modules/helptext/_default/client.lua:16>)

### 4. Medium: The current o-link docs still document the reduced API surface

This confirms some remaining drift is still present by design in the current codebase, not just by accident.

`o-link` docs currently document:
- client `notify.Send(...)`
- helptext `Show/Hide`

They do not document the older compatibility aliases that `community_bridge` exposed and existing resources may still expect.

References:
- [o-link/docs/API.md](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/docs/API.md:179>)
- [o-link/docs/API.md](</E:/FiveM/Oxide Framework/txData/FiveMBasicServerCFXDefault_72585A.base/resources/[oxide]/o-link/docs/API.md:193>)

## Summary

I did not find another new high-severity detection bug in the areas we just fixed.

The remaining problems are now mostly:
- notify API compatibility gaps
- helptext fallback behavior drift
- reduced alias coverage compared to `community_bridge`

So the next remaining porting work is not mainly detection. It is restoring the old compatibility surface where `community_bridge` still exposed it.
