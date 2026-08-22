# Outgrow Crests Tracker

Track per-slot gear high watermark progress toward the seasonal crest discount achievements in Midnight, showing which slots are holding you back.

## What This Addon Does

Each Midnight season has five crest discount achievements that unlock a **50% crest cost discount for alts** and allow uptrading crests to the next tier. Each one requires **every equipment slot** to reach a specific item level watermark. This addon gives you a clear visual breakdown of your progress so you know exactly where to focus your upgrades.

## Season 2 — "of the Mist" (Mistcrests)

| Achievement            | Required iLvl | Unlocks                              |
|------------------------|---------------|--------------------------------------|
| Adventurer of the Mist | 282           | 50% off Adventurer crests for alts   |
| Veteran of the Mist    | 295           | 50% off Veteran crests for alts      |
| Champion of the Mist   | 308           | 50% off Champion crests for alts     |
| Hero of the Mist       | 321           | 50% off Hero crests for alts         |
| Myth of the Mist       | 331           | 50% off Myth crests for alts         |

## Season 1 — "of the Dawn" (Dawncrests)

| Achievement            | Required iLvl | Unlocks                              |
|------------------------|---------------|--------------------------------------|
| Adventurer of the Dawn | 237           | 50% off Adventurer crests for alts   |
| Veteran of the Dawn    | 250           | 50% off Veteran crests for alts      |
| Champion of the Dawn   | 263           | 50% off Champion crests for alts     |
| Hero of the Dawn       | 276           | 50% off Hero crests for alts         |
| Myth of the Dawn       | 285           | 50% off Myth crests for alts         |

High watermarks reset between seasons, so the addon tracks the season your client
ships by default. Past seasons stay selectable for checking completed runs.

## Features

- **Achievement overview** -- see all five achievements at a glance with slot completion counts
- **Detailed slot breakdown** -- click any achievement to see which slots are lagging behind, sorted worst-first
- **Color-coded progress** -- green for slots meeting the threshold, red for slots that need work
- **Auto-selects next goal** -- automatically highlights the first incomplete achievement on open
- **Minimap button** -- draggable button with addon compartment support
- **Lightweight** -- no external dependencies, minimal memory footprint

## Usage

- Click the **minimap button** to toggle the tracker window
- Or type `/outgrow` or `/crests` in chat
- `/crests season` cycles the tracked season, `/crests season 2` picks one directly

Click any achievement row to see the detailed per-slot breakdown for that tier, or
the season label under the title to switch seasons.

## Installation

1. Download and extract into your `Interface/AddOns/` folder
2. The folder should be named `OutgrowCrestsTracker`
3. Restart WoW or type `/reload` if the game is running

## Requirements

- World of Warcraft: Midnight (Patch 12.1.0+)
