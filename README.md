<div align="center">
  <h1>Untargetable-MoreGhostExpansionPack</h1>
  <p><strong>Ghost-themed weapon and item expansion pack for Brotato, rebuilt on Godot 3.x structured resources.</strong></p>
  <p>Weapons · Items · Effects · Localization</p>
  <p>
    <a href="https://github.com/syy674998887/Untargetable-MoreGhostExpansionPack/releases"><img src="https://img.shields.io/github/v/release/syy674998887/Untargetable-MoreGhostExpansionPack?display_name=tag&sort=semver&style=flat-square&label=release" alt="Latest release"></a>
    <a href="https://github.com/syy674998887/Untargetable-MoreGhostExpansionPack/actions/workflows/release.yml"><img src="https://img.shields.io/github/actions/workflow/status/syy674998887/Untargetable-MoreGhostExpansionPack/release.yml?style=flat-square&label=build" alt="Build status"></a>
    <img src="https://img.shields.io/badge/Brotato-1.2.0.5-478CBF?style=flat-square" alt="Brotato 1.2.0.5">
    <img src="https://img.shields.io/badge/Mod%20Loader-6.3.0-5965FF?style=flat-square" alt="Mod Loader 6.3.0">
    <a href="LICENSE"><img src="https://img.shields.io/github/license/syy674998887/Untargetable-MoreGhostExpansionPack?style=flat-square" alt="License"></a>
  </p>
  <p><a href="#overview">Overview</a> · <a href="#content">Content</a> · <a href="#runtime-model">Runtime</a> · <a href="#installation">Install</a> · <a href="#credits--license">Credits</a></p>
</div>

> **Core boundary:** resources describe content, `Yoko-NewContentLoader` owns shared registration, and `extensions/` handles behavior that requires deeper Brotato integration.

## Overview

Untargetable-MoreGhostExpansionPack restores and modernizes the *More Ghost Weapons* content pack. Every weapon, item, projectile and effect is expressed as a structured Godot 3.x resource whose field layout matches the current Brotato `1.2.0.5` data schema, so the pack loads cleanly against the vanilla resource definitions instead of relying on ad-hoc scripted registration.

```text
content data → NewContentData.tres → Yoko-NewContentLoader → Brotato services
                                   ↘ extensions/ ↗
```

## Content

| Category | Location | Count |
| :--- | :--- | :--- |
| Melee weapons | `content/weapons/melee/` | 6 families × 4 tiers |
| Ranged weapons | `content/weapons/ranged/` | 5 families × 4 tiers |
| Items | `content/items/` | 1 (`ghost_tree`) |
| Projectiles | `content/projectile/player/` | 3 |
| Particles | `content/particles/` | 1 |
| Localization | `translations/` | 13 languages |

Weapon families (each with four upgrade tiers):

| Melee | Ranged |
| :--- | :--- |
| Ghost Pruner | Ghost Bow |
| Ghost Sword | Ghost Pistol |
| Ghost Trident | Ghost Rocket Launcher |
| Ghost Wrench | Ghost Taser |
| Ghost Spiky Shield | Ghost Wand |
| Ghost Jousting Lance | — |

`NewContentData.tres` is the aggregate resource consumed by the loader. Item `ghost_tree` (幽魂树, tier 1) is registered through the standard item data schema.

## Runtime model

Runtime extensions stay organized around the system that owns the behavior:

| Area | Extension |
| :--- | :--- |
| Weapons | `melee_weapon.gd`, `ranged_weapon.gd` |
| Turrets / turret weapons | `turret.gd` |
| Explosions | `player_explosion.gd` |
| Run / player state | `player_run_data.gd` |
| Weapon services | `weapon_service.gd` |
| Spawning | `entity_spawner.gd` |
| Shared helpers | `utils.gd` |
| Custom effects | `extensions/effects/` |

The custom `mgep_gain_stat_when_killed_single_scaling` effect scales a stat when enemies are killed and is implemented cooperatively across `weapon_service.gd`, `entity_spawner.gd`, `melee_weapon.gd` and `ranged_weapon.gd`.

`mod_main.gd` is the runtime entry point and installs every extension above. `MGEPNewContent.gd` extends the loader's `NewContent.gd` base.

## Installation

Requirements: **Brotato 1.2.0.5**, **Brotato Mod Loader 6.3.0**, and [Yoko-NewContentLoader](https://github.com/CYoJkoY/Yoko-NewContentLoader).

1. Install the required game and loader versions.
2. Install the matching NewContentLoader release.
3. Download the latest `MoreGhostExpansionPack-*.zip` from [Releases](https://github.com/syy674998887/Untargetable-MoreGhostExpansionPack/releases).
4. Place the ZIP in the Mod Loader `mods` directory.
5. Launch Brotato and verify the dependency chain loads.

For development, the intended unpacked layout is:

```text
mods-unpacked/
├── Yoko-NewContentLoader/
└── Untargetable-MoreGhostExpansionPack/
```

## Development

Resources are authored to match the current Godot 3.x data schema field order (`item_data.gd`, `weapon_data.gd`, `weapon_stats.gd`, `melee_weapon_stats.gd`, `ranged_weapon_stats.gd`, `effect.gd`, `structure_effect.gd`, `turret_effect.gd`). When editing content, keep `[resource]` fields ordered as declared by the owning script and let `load_steps` follow the actual `ext_resource` + `sub_resource` count.

`manifest.json` is authoritative for the version number, dependencies, and the declared Brotato / Mod Loader compatibility. Tagging `vX.Y.Z` triggers `.github/workflows/release.yml`, which validates the tag against the manifest, imports resources headlessly with Godot 3.7, and publishes `MoreGhostExpansionPack-<version>.zip` with a matching `.sha256`.

## Credits & License

Content derives from **Untargetable's More Ghost Weapons**, with contributions from **Flowers**, **Mengbao**, **Untargetable** and **Yoko**. Shared registration is provided by `Yoko-NewContentLoader`.

This pack is licensed under the [Yoko Restricted Source License](LICENSE).

<div align="center"><sub>Untargetable-MoreGhostExpansionPack · Brotato ghost weapon expansion.</sub></div>
