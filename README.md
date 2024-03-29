# Doom the Gungeon
**Doom the Gungeon** (name subject to change) is a total conversion mod for _DOOM_ that introduces a variety of guns, items, maps and mechanics from _Enter the Gungeon_.

# Requirements

[GZDoom](https://www.zdoom.org/downloads) is required to run this mod. Sacrifices had to be made in order to \*squeeze the juice\*.

# Installing

Download the packed **.pk3** from the [Releases](https://github.com/G3Kappa/Doom-the-Gungeon/releases) page and add it to your launcher of choice, such as [ZDL](https://zdoom.org/wiki/ZDL). Make sure that GZDoom is the selected source port.

# For Contributors

Sprites are ripped from EtG and converted into 3D sprites manually by first recreating them in [MagicaVoxel](https://ephtracy.github.io/) as 3D models and then passing the exported .vox to [IsoVoxel](https://github.com/tommyettinger/IsoVoxel). **This process is suitable for being automated in the near future**.

Sounds are ripped from EtG with the aid of a few tools provided in the `_GungeonSoundbank` directory. **TODO: Explain usage there**.

## Naming Conventions

TODO: Tbh le sigle sono ambigue e dovremmo dedicare una lettera o due al tipo di risorsa.

| Template | Example | Description |
| --- | --- | --- |
| NNNNF*0* | RSGNA*0* | Viewmodel sprites for a gun |
| NNNNFA[FA] | RSGLA2A8 | Sprites for a projectile |
| NNNNNN*F*X | ROGSPE*F*0 | Sound for a gun being shot |
| NNNNNN*R*X | ROGSPE*R*0 | Sound for a gun being reloaded |

# Issues

This mod is not multiplayer compatible yet. However, it will be eventually since EtG's coop is wack.

1. TODO: _Find a way to count passive items from the right player's inventory when shooting bullets._
2. TODO: _Figure out respawning mechanics and such._

# Roadmap

## Guns
- Starting Guns:
    - ~~Rogue Special (Pilot)~~
    - Marine Sidearm (Marine)
    - Rusty Sidearm (Hunter)
    - Crossbow (Hunter)
    - Budget Revolver (Convict)
    - Sawed Off (Convict)
    - Robot's Right Hand (Robot)
    - Slinger (Gunslinger)
    - Blasphemy (Bullet)
    - Dart Gun (Cultist)
- D-Tier:
    - Casey
- C-Tier:
- B-Tier:
- A-Tier:
- S-Tier:
    - ~~Railgun~~

## Items
- Passive Items:
    - Starting Passives:
        - Disarming Personality (Pilot)
        - Hidden Compartment (Pilot)
        - Enraging Photo (Convict)
        - Dog (Hunter)
        - Military Training (Marine)
        - Number 2 (Cultist)
        - Live Ammo (Bullet)
        - Battery Bullets (Robot)
        - Lich's Eye Bullets (Gunslinger, _also yeah right_)
    - Bouncy Bullets
- Active Items:
    - Starting Actives:
        - Trusty Lockpicks (Pilot)
        - Supply Drop (Marine)
        - Friendship Cookie (Cultist)
        - Coolant Leak (Robot)
        - Molotov (Convict)

## Maps
TODO

## Mechanics
- ~~Weapon Damage~~
- Player Health Mechanics:
    - Hearts
    - Armor
- Dodge Rolling
- Blanks
- Casings
- Orbitals (Guon Stones, etc.)
- Chests
    - Mimics
- NPCs
    - Shopkeepers
- Enemy Projectiles
- Projectile Mechanics:
    - ~~Bouncy Bullets~~
