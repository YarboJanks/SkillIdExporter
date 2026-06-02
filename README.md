# SkillIdExporter

ESO addon that exports complete skill data (IDs, names, descriptions, icons) for use in external build editors and tools.

## Features

- Export all skills visible to a character (class, weapon, armor, world, guild, racial, trade, etc.)
- Capture full ability details: name, description, icon, cost, range, duration, etc.
- Organized by skill type and skill line
- Separate collections for active vs passive abilities
- Safe API calls with error handling
- Works with any ESO API version (graceful degradation)

## Installation

1. Download this repository
2. Copy to your ESO AddOns folder:
   ```
   ~/Documents/Elder Scrolls Online/live/Addons/SkillIdExporter/
   ```
3. Launch ESO and log in

## Usage

In-game, use these slash commands:

### Export Skill Lines (Recommended)
```
/exportskills
```
Exports all skill lines, abilities, and passives visible to the current character.

### Raw Ability Scan
```
/exportabilities 1 250000
```
Scans a range of ability IDs and exports any that exist. Default range is 1-250000.

### Finalize Export
After running a command:
```
/reloadui
```
This forces ESO to write the export to disk.

## Output

Exported data is saved to:
```
~/Documents/Elder Scrolls Online/live/SavedVariables/SkillIdExporter_SavedVariables.lua
```

The Lua table contains:
- `skillLines[skillType][line]` - Organized skill lines with abilities
- `activeSkills` - Array of all active (non-passive) abilities
- `passives` - Array of all passive abilities
- `rawAbilities` - Raw scan results (if using /exportabilities)
- Character metadata: name, race, class, export timestamp

## For Complete Coverage

Run on multiple characters to capture all skills:
- One per class (Dragonknight, Sorcerer, Nightblade, Warden, Necromancer, Templar)
- Different races for racial passives
- Merge exported files for a master skills database

ESO API limitations prevent a single character from seeing all skills (only visible to that character/account). Multiple exports provide comprehensive coverage.

## Use Cases

- Build editor tools (web/desktop apps)
- Build sharing and import/export systems
- Skill availability checkers
- Leveling guides
- API research and reverse engineering

## License

Public domain. Use freely in your projects.

## Notes

- Exports only skills the character has visibility for
- SafeCall wrapper prevents crashes if API functions change
- Large scans (1-250000) may take a minute or more; this is normal
- No warranty; tested with ESO API v101049
