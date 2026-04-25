# o-link Support Matrix

This matrix is rebuilt from the current filesystem under `o-link/modules` and `o-link/lifecycle`.

It lists implementation folders that exist today. It does not guarantee every implementation is bug-free; it only verifies that the bridge ships that adapter in the current tree.

## Core and Framework Namespaces

| Namespace | Side | Implementation folders |
|-----------|------|------------------------|
| `callback` | shared | built-in shared module |
| `framework` | server + client | `es_extended`, `oxide-core`, `qb-core`, `qbx_core` |
| `character` | server + client | `es_extended`, `oxide-core`, `qb-core`, `qbx_core` |
| `job` | server + client | `es_extended`, `oxide-core`, `qb-core`, `qbx_core` |
| `money` | server | `es_extended`, `oxide-accounts`, `qb-core`, `qbx_core` |
| `inventory` | server + client | `codem-inventory`, `core_inventory`, `jpr-inventory`, `origen_inventory`, `oxide-inventory`, `ox_inventory`, `ps-inventory`, `qb-inventory`, `qs-inventory`, `tgiann-inventory` |
| `vehicles` | server | `esx_vehicleshop`, `oxide-vehicles`, `qb-garages`, `qbx_vehicles` |
| `vehicleproperties` | client | `modules/vehicles/properties` |
| `entity` | server + client | built-in framework-agnostic module |
| `jobcount` | server | built-in framework-agnostic module |

## UI and Interaction

| Namespace | Side | Implementation folders |
|-----------|------|------------------------|
| `notify` | server + client | `brutal_notify`, `confirm`, `fl-notify`, `lation_ui`, `mythic_notify`, `okokNotify`, `oxide-core`, `oxide-notify`, `ox_lib`, `pNotify`, `r_notify`, `t-notify`, `wasabi_notify`, `zsxui` |
| `helptext` | server + client | server relay plus `cd_drawtextui`, `jg-textui`, `lab-HintUI`, `lation_ui`, `okokTextUI`, `ox_lib`, `zsxui` |
| `target` | client | `ox_target`, `qb-target`, `sleepless_interact` |
| `progressbar` | client | `esx_progressbar`, `keep-progressbar`, `lation_ui`, `oxide-progressbar`, `ox_lib`, `qb-progressbar`, `wasabi_uikit`, `zsxui` |
| `input` | client | `lation_ui`, `ox_lib`, `qb-input` |
| `menu` | client | `lation_ui`, `oxide-menu`, `ox_lib`, `qb-menu`, `wasabi_uikit` |
| `radial` | client | `oxide-menu`, `ox_lib` |
| `zones` | client | `oxlib`, `polyzone` |

`notify` auto-detection selects one renderer. `ox_lib` is fallback-only unless
forced with `Config.Overrides.Notify = 'ox_lib'`; if multiple non-`ox_lib`
notify resources are running, set `Config.Overrides.Notify`.

`radial` auto-detection prefers `oxide-menu` as the full provider. The `ox_lib`
adapter remains available as a fallback/global registration provider; private
radials opened through `olink.radial.Open(data)` are exposed as global submenus.
Direct `lib.addRadialItem(...)` calls are not intercepted.

## Gameplay Systems

| Namespace | Side | Implementation folders |
|-----------|------|------------------------|
| `fuel` | client | `bigDaddy-Fuel`, `cdn-fuel`, `esx-sna-fuel`, `lc_fuel`, `legacyfuel`, `okokGasStation`, `oxide-vehicles`, `ox_fuel`, `ps-fuel`, `qb-fuel`, `qs-fuelstations`, `renewed-Fuel`, `ti_fuel`, `x-fuel` |
| `weather` | client | `cd_easytime`, `night_natural_disasters`, `oxide-weather`, `qb-weathersync`, `renewed-weathersync` |
| `vehiclekey` | client | `cd_garage`, `f_realcarkeyssystem`, `jacksam`, `mk_vehiclekeys`, `mrnewbvehiclekeys`, `mVehicle`, `okokGarage`, `oxide-vehicles`, `qb-vehiclekeys`, `qbx_vehiclekeys`, `qs-vehiclekeys`, `renewed-vehiclekeys`, `t1ger_keys`, `wasabi_carlock` |
| `vehicleOwnership` | server | `esx_vehicleshop`, `oxide-vehicles`, `qb-garages`, `qbx_vehicles` |
| `death` | server + client | `es_extended`, `oxide-death`, `qb-core`, `qbx_core` |
| `needs` | server | `es_extended`, `oxide-needs`, `qb-core`, `qbx_core` |
| `gang` | server + client | `es_extended`, `oxide-core`, `qb-core`, `qbx_core` |

## Economy, Services, and World

| Namespace | Side | Implementation folders |
|-----------|------|------------------------|
| `banking` | server | `fd_banking`, `kartik-banking`, `okokBanking`, `qb-banking`, `renewed-banking`, `tgg-banking`, `tgiann-bank`, `wasabi_banking` |
| `phone` | server + client | `gksphone`, `lb-phone`, `okokPhone`, `oxide-phone`, `qb-phone`, `qs-smartphone`, `yseries` |
| `clothing` | shared + server + client | `esx_skin`, `fivem-appearance`, `illenium-appearance`, `oxide-clothing`, `oxide-identity`, `qb-clothing`, `rcore_clothing` |
| `dispatch` | server + client | `_default`, `bub-mdt`, `cd_dispatch`, `emergencydispatch`, `fd_dispatch`, `kartik-mdt`, `lb-tablet`, `linden_outlawalert`, `origen_police`, `oxide-dispatch`, `piotreq_gpt`, `ps-dispatch`, `qs_dispatch`, `redutzu-mdt`, `tk_dispatch`, `wasabi_mdt` |
| `doorlock` | server + client | `doors_creator`, `ox_doorlock`, `qb-doorlock`, `rcore_doorlock` |
| `housing` | server + client | `bcs-housing`, `esx_property`, `ps-housing`, `qb-appartments`, `qb-houses` |
| `bossmenu` | server + client | `esx_society`, `qb-management`, `qbx_management` |
| `skills` | server + client | `_default`, `evolent_skills`, `ot_skills`, `pickle_xp` |

## Lifecycle Adapters

| Framework | Files |
|-----------|-------|
| `oxide-core` | `lifecycle/oxide-core/server.lua`, `lifecycle/oxide-core/client.lua` |
| `qb-core` | `lifecycle/qb-core/server.lua`, `lifecycle/qb-core/client.lua` |
| `qbx_core` | `lifecycle/qbx_core/server.lua`, `lifecycle/qbx_core/client.lua` |
| `es_extended` | `lifecycle/es_extended/server.lua`, `lifecycle/es_extended/client.lua` |
