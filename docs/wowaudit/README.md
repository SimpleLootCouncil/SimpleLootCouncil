# SimpleLootCouncil × wowaudit

Two things: where SimpleLootCouncil (SLC) keeps its loot history and what shape it has,
and the file SLC now provides for the wowaudit desktop client to write sim data into.
Written for SLC 0.43.48. [`SLC_History_Sample.lua`](SLC_History_Sample.lua), next to this file, is a complete
example of every table described here.

---

## 1. Loot history

### Where it is

```
World of Warcraft\_retail_\WTF\Account\<ACCOUNT>\SavedVariables\SimpleLootCouncil.lua
```

One global, `SimpleLootCouncilDB`, account-wide (not per character). The game writes the
file at logout and on `/reload` only, so a raid in progress is not on disk yet.

Three keys matter:

| Key | What it holds |
|---|---|
| `history` | SLC's own awards, one row per item awarded, keyed by the row's `id` |
| `imported` | history imported from RCLootCouncil, Loothing or a pasted CSV; same row shape plus `source`. Never mixed into `history` |
| `historySnapshots` | the whole council as it stood when each item was awarded (every candidate's answer, votes, item level), keyed `"<runId>:<session>"`. Kept 60 days |

The rest of `SimpleLootCouncilDB` is settings and can be ignored. `schemaVersion` is the
saved-data migration number (currently 9).

### Things to know before reading it

- **Deduplicate by `id`.** The loot master shares each history row with the group, so
  every raider who records history holds a copy with the same `id`. `recorder` and
  `guild` are stamped locally and differ between copies.
- **Player names are `Name-Realm`**, realm with spaces removed, apostrophes kept
  (`Morvessa-Zul'jin`, `Thalwyn-Area52`).
- **`epoch` is Unix seconds (server time) and is the field to sort and match on.**
  `date` (`YYYY/MM/DD`) and `time` (`HH:MM:SS`) are the same moment in **UTC**, kept
  for reading.
- **`link` is a full item link** for awards (`|cnIQ4:|Hitem:<itemID>:...|h[Name]|h|r`,
  bonus ids included). Coin rows can hold a bare item string (`item:<itemID>`). Take
  the item id with the pattern `item:(%d+)`.
- **A response is either button text or a code, never both.** `responseText` is the
  group's own button label at the time (`"Mainspec"`, `"Offspec"`, `"Transmog"` by
  default, but every guild names its own), with `responseID` its 1-based button
  position and `r`,`g`,`b` its colour (0-1). When there was no button answer,
  `responseText` is absent and `responseCode` holds one of the codes below.
- An imported RCLootCouncil row keeps RCLootCouncil's own `date` format and response text.

### Response codes

| `responseCode` | Meaning |
|---|---|
| `PASS` | the winner passed, or was awarded the item before they answered |
| `COIN` | a bonus-roll loot, reported by the roller (`coin = true`) |
| `UNKNOWN` | no answer known (mostly imported rows) |
| `RESPONDED` | answered with a button that no longer exists |

Snapshot candidates can also carry `ANNOUNCED` (still waiting), `NOTHING` (did not
answer), `NO_ADDON` (no SLC installed) and `AWARDED` as their `status`.

### A `history` row

Only `id`, `link`, `winner` and `epoch` are always present; everything else is
present when known.

| Field | Type | Meaning |
|---|---|---|
| `id` | string | unique row id, `"<epoch>-<counter>"` (imported: `"<source>:<winner>:<source id>"`) |
| `link` | string | the item awarded (see above) |
| `winner` | string | `Name-Realm` of who received it |
| `owner` | string | `Name-Realm` of who held the item and trades it (SLC votes on items in raiders' bags) |
| `responseText` | string | the winner's button label |
| `responseID` | number | that button's 1-based position |
| `responseCode` | string | a code from the table above, when there is no `responseText` |
| `r`, `g`, `b` | number | the response colour, 0-1 |
| `note` | string | the winner's note |
| `reason` | string | award-reason text (`"Disenchant"`, `"Guild bank"`, ...); present only when the item was given for a reason rather than a response |
| `votes` | number | council votes the winner had |
| `epoch` | number | Unix seconds, server time |
| `date`, `time` | string | `YYYY/MM/DD`, `HH:MM:SS`, UTC |
| `instance` | string | instance name, in the recorder's game language |
| `instanceType` | string | `"raid"`, `"party"`, `"none"`, ... |
| `difficultyID` | number | the game's difficulty id (14 Normal, 15 Heroic, 16 Mythic, 17 LFR) |
| `difficultyName` | string | in the recorder's game language |
| `boss` | string | boss name, in the recorder's game language |
| `encounterID` | number | the game's encounter id (`ENCOUNTER_START`'s); language-independent, prefer it to `boss` |
| `groupSize` | number | group size at award time |
| `delivered` | boolean | `true` once the item was traded to the winner; `false` if still owed |
| `coin` | boolean | `true` on a bonus-roll row |
| `quantity` | number | stack size on a bonus-roll row |
| `runId` | string | the loot run the award belongs to |
| `session` | number | the item's index in that run; with `runId` it finds the snapshot |
| `awardSeq` | number | award sequence number (internal; a re-award gets a higher one) |
| `guild` | string | the guild of the character that stored this copy |
| `recorder` | string | `Name-Realm` of the character that stored this copy |

`imported` rows add `source` (`"rclc"`, `"loothing"` or `"slc-csv"`), `name` (item
name), `isAwardReason` (boolean) and `mapID`; their `delivered` is absent (unknown).

### A `historySnapshots` entry

| Field | Type | Meaning |
|---|---|---|
| `runId`, `session` | string, number | as on the history row |
| `epoch` | number | when it was captured |
| `link`, `boss`, `encounterID`, `owner`, `winner` | | as on the history row |
| `count` | number | number of candidates |
| `candidates` | table | `Name-Realm` → candidate |

A candidate: `status` (code above), `response` / `responseID` / `r`,`g`,`b` (button
answer) or `responseCode`, `note`, `roll` (1-100) and `rollBy` (`"player"` rolled it,
`"leader"` generated it), `ilvl` (their average equipped item level), `diff` (item-level
gain over what they wear in that slot), `gear1`/`gear2` (their equipped item(s) in that
slot), `viaWhisper` (answered by whisper), `votes` (list of voter names).

### Alternative: CSV

`/slc csv` in game opens a copyable export of the same history with this header (`,` or
`;` separated, the user's choice):

```
id,date,time,source,winner,owner,item,itemLink,response,votes,instance,difficulty,boss,delivered,note,reason,coin,encounterID,guild,recorder
```

Pipes in `itemLink` are doubled. New columns are only ever appended.

---

## 2. `SLC_WoWAuditSimData.lua` — the file for the wowaudit client to write

### Where

```
World of Warcraft\_retail_\Interface\AddOns\SimpleLootCouncil_SimulationImport\SLC_WoWAuditSimData.lua
```

A folder of its own, beside SLC's. **The client creates the folder** and writes the one
file; SLC ships neither. Both editions of SLC (the standalone `SimpleLootCouncil` and
the EllesmereUI edition `EllesmereUISimpleLootCouncil`) load the file from there through
their `.toc`, so no companion addon (and no RCLootCouncil) is needed. The folder holds
no `.toc`, so it is not an addon: it never shows in the addon list, no addon manager
touches it, and an SLC or EllesmereUI update never erases it. Both editions have been
checked in game reading a test file from this folder (SLC 0.43.48).

### Format

Exactly what the client already writes into `RCLootCouncil_wowaudit\Data\db.lua`, but
as fields of ONE global table instead of six globals:

```lua
SLC_WoWAuditSimData = {
    wowauditTimestamp = 1792105000,   -- required: number, Unix seconds of the export
    teamID = 12345,
    difficulties = { ... },
    wishlistData = { ... },           -- required: table, same shape as db.lua's
    bonusRollTargets = { ... },
    trinketPriorities = { ... },
}
```

- `wowauditTimestamp` (number) and `wishlistData` (table) are required; without them SLC
  treats the file as empty. The other four are optional and read as in `db.lua`.
- `wishlistData` is read exactly as SLC already reads `db.lua`'s: character name →
  difficulty letter (`R`, `N`, `H`, `M`) → list of wishes `{ id, s, v, p, l }`.
- Plain Lua 5.1 table syntax. A syntax error makes the game skip the file (SLC keeps
  working, without wowaudit data).
- SLC removes the `SLC_WoWAuditSimData` global after reading it, so it never collides
  with anything.

### When SLC uses it

- If both this file and `RCLootCouncil_wowaudit\Data\db.lua` exist, SLC uses whichever
  has the newer `wowauditTimestamp` (this file on a tie). Writing both is harmless.
- If the RCLootCouncil - wowaudit addon is running and holds a dataset shared in the
  group, SLC uses that only when its timestamp is newer than this file's.
- The game reads the file at login and `/reload`, never while playing.

### Open points for the client

1. **When to write**: SLC is installed when either
   `Interface\AddOns\SimpleLootCouncil\SimpleLootCouncil.toc` (the standalone addon) or
   `Interface\AddOns\EllesmereUISimpleLootCouncil\EllesmereUISimpleLootCouncil.toc` (SLC's
   EllesmereUI edition) exists. Either way, write the one path above.
2. **Create `SimpleLootCouncil_SimulationImport`** when it is missing. Put nothing in it
   but `SLC_WoWAuditSimData.lua` — in particular no `.toc`.
