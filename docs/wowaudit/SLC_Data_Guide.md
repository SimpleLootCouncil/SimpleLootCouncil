# SLC Data Guide

Two things: where SimpleLootCouncil (SLC) keeps its loot history and what shape it has,
and the file SLC now provides for the wowaudit desktop client to write sim data into.
Written for SLC 0.43.94 (saved-data schema 10). [`SLC_History_Sample.lua`](SLC_History_Sample.lua), next to this file, is a complete
example of every table described here.

> **Read this first: SLC history is stored in two forms.** Unlike RCLootCouncil, which keeps
> everything as plain tables, SLC keeps the **last 30 days live** (`history`, `imported`) and
> moves **older rows into compressed strings** (`historyArchive`, section 1a). The full
> history is both. Reading only `history` loses everything older than 30 days, with no
> error. (`/slc csv` always exports every row.)

---

## 1. Loot history

### Where it is

SLC comes in two editions, and a player can have either or both. Each keeps its history
in its own file, one global per file, account-wide (not per character). The files are in
`World of Warcraft\_retail_\WTF\Account\<ACCOUNT>\SavedVariables\`:

| Edition | File | Global |
|---|---|---|
| Standalone addon (`SimpleLootCouncil`) | `SimpleLootCouncil.lua` | `SimpleLootCouncilDB` |
| EllesmereUI edition (`EllesmereUISimpleLootCouncil`) | `EllesmereUISimpleLootCouncil.lua` | `EllesmereUISimpleLootCouncilDB` |

Both hold the same table with the same shape, described below. Read **every file that
exists**: a player with one edition has one file, and a player who once ran the other
may have an older file for it. The game writes each file at logout and on `/reload`
only, so a raid in progress is not on disk yet.

When both editions are installed, SLC combines the two tables at login and writes the
same combined table into both files at the next logout, so either file then holds the
full history. A file the player stopped using can be older and incomplete, which is why
you read all of them rather than picking one. A file from before 0.43.49 can hold
both globals (the EllesmereUI file may also contain a stale `SimpleLootCouncilDB`), so
read every table in each file whose name starts with `SimpleLootCouncilDB` or
`EllesmereUISimpleLootCouncilDB`. To combine files:

1. Take the union of `history` (and `imported`) rows across the files, keyed by `id`,
   after unpacking each file's archive (section 1a). The same `id` is the same award. If two copies differ, prefer the file with the
   larger top-level `savedAt` (Unix seconds, written at logout). Files written before
   0.43.49 have no `savedAt`; treat them as older than any file that has one.
2. Drop any `id` listed in the `deleted` table. `deleted.history[<id>]` and
   `deleted.imported[<id>]` hold the time the player deleted that row, and an older
   file can still contain it. Rows deleted this way are already gone from the combined
   table SLC writes, so this only matters for an older file.
Keys that matter:

| Key | What it holds |
|---|---|
| `history` | SLC's own awards from the last 30 days, one row per item awarded, keyed by the row's `id`. Older rows are in `historyArchive` |
| `imported` | history imported from RCLootCouncil, Loothing or a pasted CSV, last 30 days; same row shape plus `source`. Never mixed into `history`. Older rows are in `historyArchive` |
| `historyArchive` | every `history` and `imported` row older than 30 days, packed by month (section 1a) |
| `historySnapshots` | the whole council as it stood when each item was awarded (every candidate's answer, roll, item level), keyed `"<runId>:<session>"`. Kept 60 days. Each value is a packed string (section 1a) or, from an older build, a plain table |

The rest of the table, apart from `savedAt` above, is settings and can be ignored. `schemaVersion` is the
saved-data migration number (currently 10).

### 1a. Packed data: the archive and snapshots

Rows older than 30 days live in `historyArchive.segs`, one segment per month
(`"2026-08.1"`), each with a `blob`. Nothing is dropped: every row is in the live table or
in a blob. Read both.

**Unpacking a blob** (checked against real game output on 12.1.5, SLC 0.43.94):
1. base64-decode, **URL-safe alphabet** (`-` and `_`), `=` padded;
2. inflate as **raw Deflate** (no zlib header: Python `zlib.decompress(data, -15)`);
3. CBOR-decode. **Lua strings come out as CBOR byte strings**: read them as UTF-8 text.

In game, `C_EncodingUtil` does all three (`DecodeBase64`, `DecompressString`,
`DeserializeCBOR`). [`SLC_Decode_Example.py`](SLC_Decode_Example.py) is a complete reader in
Python's standard library, with two real blobs that it checks; the same blobs are in
`SLC_History_Sample.lua`.

An unpacked blob is `{ h = { [id] = row }, i = { [id] = row } }`: `h` holds `history` rows and
`i` holds `imported` rows, each exactly as described below. Full history is `history` plus
every segment's `h`, and `imported` plus every segment's `i`. Ignore the other
`historyArchive` keys (`sum`, `token`, ...): they are SLC's own cache.

`historySnapshots` values are packed the same way: `"z<epoch>:<blob>"`, the blob being
everything after the first `:`. A value that is a plain table is a snapshot as it stands.

### 1b. Handling both forms in one place

Put the two forms behind one function so the rest of the tool never knows. For each saved
file:

1. Parse the file (the whole `SimpleLootCouncilDB` / `EllesmereUISimpleLootCouncilDB` table).
2. Start with every `historyArchive.segs[*].blob`, unpacked: add each segment's `h` rows
   (history) and `i` rows (imported) to a map keyed by `id`. A blob that fails to unpack is
   skipped.
3. Then add the live `history` and `imported` rows over it. A row is normally in only one
   form; if an `id` is in both, the live copy is the current one.
4. Carry on with that single map exactly as you would with RCLootCouncil's table. Joining a
   snapshot is `snapshot(db.historySnapshots[runId .. ":" .. session])`.

That is `all_rows(db)` in `SLC_Decode_Example.py`: about ten lines. Nothing else about the
rows differs between the forms, so once they are merged the rest of this guide applies
unchanged.

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
| `votes` | number | council votes the winner had. **No longer written since 0.43.53**; present only on older rows and imported rows |
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
slot) and `viaWhisper` (answered by whisper). Snapshots written before 0.43.53 can also
carry `votes` (a list of voter names); SLC no longer records or reads it.

### Alternative: CSV

`/slc csv` in game opens a copyable export of the same history, live and archived together, with this header (`,` or
`;` separated, the user's choice):

```
id,date,time,source,winner,owner,item,itemLink,response,votes,instance,difficulty,boss,delivered,note,reason,coin,encounterID,guild,recorder
```

Pipes in `itemLink` are doubled. New columns are only ever appended. The `votes` column
is kept so the header never changes; it is empty for awards made since 0.43.53.

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
