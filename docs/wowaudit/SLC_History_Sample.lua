-- SimpleLootCouncil 0.43.94 - sample of WTF\Account\<ACCOUNT>\SavedVariables\SimpleLootCouncil.lua
-- Only the history tables are shown; the real file holds many other settings keys.
-- Names, items and times are illustrative; the shape and value types are exact.
-- Every field is described in SLC_Data_Guide.md next to this file.
-- HISTORY HAS TWO FORMS: `history` and `imported` below hold only the last 30 days as plain
-- tables; everything older is in `historyArchive` as packed strings, and `historySnapshots`
-- values are packed strings too. The full history is live + archived (guide, section 1a).
-- The archive blob and the packed snapshot below are REAL game output (SLC 0.43.94) of the rows
-- shown in the decoded form; SLC_Decode_Example.py unpacks them.
SimpleLootCouncilDB = {
    ["schemaVersion"] = 10,

    -- Unix seconds of the last logout that wrote this file; the larger one is newer.
    ["savedAt"] = 1792180800,

    -- Rows the player deleted, by id and when. Skip these ids if an older file still has them.
    ["deleted"] = {
        ["history"] = { ["1792100000-2"] = 1792170000 },
        ["imported"] = {},
    },

    -- Native history: one row per award, keyed by the row's id.
    ["history"] = {
        -- An item awarded by the council to a raider who answered with a response button.
        ["1792105331-4"] = {
            ["id"] = "1792105331-4",
            ["link"] = "|cnIQ4:|Hitem:202616::::::::90:263::6:5:7981:9380:6652:1498:8767:1:28:2647:::::|h[Enduring Dreadplate]|h|r",
            ["winner"] = "Brakka-Illidan",
            ["owner"] = "Thalwyn-Area52",
            ["responseText"] = "Mainspec",
            ["responseID"] = 1,
            ["r"] = 0.2,
            ["g"] = 0.8,
            ["b"] = 0.2,
            ["note"] = "2pc tier with this",
            ["date"] = "2026/10/15",
            ["time"] = "03:42:11",
            ["epoch"] = 1792105331,
            ["instance"] = "Aberrus, the Shadowed Crucible",
            ["instanceType"] = "raid",
            ["difficultyID"] = 15,
            ["difficultyName"] = "Heroic",
            ["boss"] = "Kazzara, the Hellforged",
            ["encounterID"] = 2688,
            ["groupSize"] = 20,
            ["delivered"] = true,
            ["runId"] = "1792105290-1",
            ["session"] = 2,
            ["awardSeq"] = 1,
            ["guild"] = "Example Guild",
            ["recorder"] = "Thalwyn-Area52",
        },
        -- Awarded before the winner answered: no response button, the code PASS.
        ["1792105402-5"] = {
            ["id"] = "1792105402-5",
            ["link"] = "|cnIQ4:|Hitem:202599::::::::90:263::6:5:7981:9380:6652:1498:8767:1:28:2647:::::|h[Sarkareth's Abyssal Embrace]|h|r",
            ["winner"] = "Velune-Area52",
            ["owner"] = "Velune-Area52",
            ["responseCode"] = "PASS",
            ["date"] = "2026/10/15",
            ["time"] = "03:43:22",
            ["epoch"] = 1792105402,
            ["instance"] = "Aberrus, the Shadowed Crucible",
            ["instanceType"] = "raid",
            ["difficultyID"] = 15,
            ["difficultyName"] = "Heroic",
            ["boss"] = "Kazzara, the Hellforged",
            ["encounterID"] = 2688,
            ["groupSize"] = 20,
            ["delivered"] = true,
            ["runId"] = "1792105290-1",
            ["session"] = 3,
            ["awardSeq"] = 1,
            ["guild"] = "Example Guild",
            ["recorder"] = "Thalwyn-Area52",
        },
        -- Awarded for an award reason (Disenchant, Guild bank, ...): `reason` is set.
        ["1792105460-6"] = {
            ["id"] = "1792105460-6",
            ["link"] = "|cnIQ4:|Hitem:202612::::::::90:263::6:5:7981:9380:6652:1498:8767:1:28:2647:::::|h[Screaming Black Dragonscale]|h|r",
            ["winner"] = "Thalwyn-Area52",
            ["owner"] = "Morvessa-Zul'jin",
            ["responseCode"] = "PASS",
            ["reason"] = "Disenchant",
            ["date"] = "2026/10/15",
            ["time"] = "03:44:20",
            ["epoch"] = 1792105460,
            ["instance"] = "Aberrus, the Shadowed Crucible",
            ["instanceType"] = "raid",
            ["difficultyID"] = 15,
            ["difficultyName"] = "Heroic",
            ["boss"] = "Kazzara, the Hellforged",
            ["encounterID"] = 2688,
            ["groupSize"] = 20,
            ["delivered"] = false,
            ["runId"] = "1792105290-1",
            ["session"] = 4,
            ["awardSeq"] = 1,
            ["guild"] = "Example Guild",
            ["recorder"] = "Thalwyn-Area52",
        },
        -- A bonus-roll (coin) loot, reported by the roller: `coin` true, code COIN.
        ["1792105512-7"] = {
            ["id"] = "1792105512-7",
            ["link"] = "item:202616",
            ["winner"] = "Brakka-Illidan",
            ["coin"] = true,
            ["responseCode"] = "COIN",
            ["quantity"] = 1,
            ["date"] = "2026/10/15",
            ["time"] = "03:45:12",
            ["epoch"] = 1792105512,
            ["instance"] = "Aberrus, the Shadowed Crucible",
            ["difficultyID"] = 15,
            ["boss"] = "Kazzara, the Hellforged",
            ["encounterID"] = 2688,
            ["delivered"] = true,
            ["guild"] = "Example Guild",
            ["recorder"] = "Thalwyn-Area52",
        },
    },

    -- Imported history (RCLootCouncil, Loothing or a pasted CSV): never mixed with
    -- `history`; `source` says where it came from.
    ["imported"] = {
        ["rclc:Brakka-Illidan:1785000000-17"] = {
            ["id"] = "rclc:Brakka-Illidan:1785000000-17",
            ["source"] = "rclc",
            ["link"] = "|cnIQ4:|Hitem:202616::::::::90:263::6:5:7981:9380:6652:1498:8767:1:28:2647:::::|h[Enduring Dreadplate]|h|r",
            ["winner"] = "Brakka-Illidan",
            ["responseText"] = "Mainspec/Need",
            ["responseID"] = 1,
            ["isAwardReason"] = false,
            ["r"] = 0.1,
            ["g"] = 1,
            ["b"] = 0.1,
            ["date"] = "21/07/26",
            ["time"] = "21:14:05",
            ["epoch"] = 1785000000,
            ["instance"] = "Aberrus, the Shadowed Crucible-Heroic",
            ["difficultyID"] = 15,
            ["boss"] = "Kazzara, the Hellforged",
            ["votes"] = 2,
        },
    },

    -- History older than 30 days, moved out of `history` and `imported`: one segment per UTC
    -- month and part ("<YYYY-MM>.<part>", at most 1000 rows). A blob unpacks to
    --   { h = { [id] = <a history row> }, i = { [id] = <an imported row> } }
    -- with the rows exactly as above. `sum`, `sumV` and `token` are SLC's own cache: ignore them.
    ["historyArchive"] = {
        ["segs"] = {
            ["2026-08.1"] = {
                ["n"] = 3, ["nh"] = 2, ["ni"] = 1,
                ["oldest"] = 1785000000, ["newest"] = 1785105402,
                ["oh"] = 1785105331,
                -- unpacks to { h = {2 history rows}, i = {1 imported row} }
                ["blob"] = "xZM_b9NAGIfVsrGwsNABmYGNKPYl_pNbiovd2m0SAamgEmK43L2Jr73cmbPdtFUGdj4BbHRHQmLhK_BR2FhY6IKT1C2BqCpTb7P83t3vfd7nTn3-ce-BpoLiDU0ODkgtFoIzIrHlerY5WzXL_dTWkKVKZrALR3mnQ7jMUqD1LgDbzFShKQTTQwLB5cHe_oTK-FkTTyKewwgjEzmWg89Xy8TIaWDsYBu7Lc_CrYZnYsexEbaaLQ97ruNiCyOvLGu6sy2T5FUoWaG5HBqBBsJSQXJ4PUkmeoOza8QPIVU0WdtnPx6HhyqHbLXN-GDAaSHy4zi4E-R8BBGyygTYtIO-yrKXO-TkhGjyyMgTMCIQYqD0EFhUdp4TSWHvod8HrYtsXtFLCFNjYMYTXVDeF1CLQCtON8dcStDdxXgBKxsoL6ybbh052xXcOFjxk9P2NLtl2o2GVWt-XQtkmfg5SqmRc9DGmOdJeSPPwmHBBeuER2SUCjC2pl9-_2z92_vp-jC7YnvKvm56dRP5w7P17_NfOyCpKmQOOg7u3X57Zb9zNGYDN8v5WBEZE8168GYl1IWMWRUVtUrM3UumXTKCzTmABXOiypxIA1WalWB2EyLGx7Lml4O10U0ItMA7VGP5TypfX2C9nP_9q-cfD7Uq0h4_gbuLsrWrE3aP0_LVEM5iBoIfggb2szJ18O7LcnO2MsgyruTqn9JUHTRNVLM_Xw6pKr71tww3iXkWco658wJEIeGc8rXR_o-_yx761OYGRmgp91_n3BezLdH9QuwnikHw1O_1fgM=",
            },
        },
        ["sum"] = {},
        ["sumV"] = 1,
        ["token"] = "...",
        ["sweptAt"] = 1792180000,
    },

    -- The council as it stood when each item was awarded, keyed "<runId>:<session>",
    -- joined to a history row by that pair. Kept 60 days. Normally each value is a packed string
    -- "z<capture epoch>:<blob>"; the blob unpacks to the snapshot table shown in the second entry.
    ["historySnapshots"] = {
        ["1785105290-1:2"] = "z1785105331:fZDPTsJAEMYj3ky8iyceQJK20H97ISVboCDgv6iJ8bC0U7qwbsluK4H04N0n0KMXjVcTEx_BR_EZuFgQOXhwbvPNN_P7Mq-YUT6-HGU-946rKGvRBG6QpmiGaqB12QrSjApCBtKRaVsqsiuWggxD15BatS1kmYaJVKRZua1qrlay6MrlQSooH5awABJMGEngOosy4cIk9qP9UXj_1gHuxylPQHi4uHOHB7GUFx0ynxNBDkpJBKUWMBbGYgiBu3IWmhKkpDEvuPGUg-idRYRNZ7zs5BBda0wpX6p1QcZjUvYYowHhrki5FxyqpqWriq7ZSllt-4QH-SwB-fTH_YIDGoa7zmBR-3xY1iOm7JYVtz4csZEaMiFJKr0T9_So38MubguQk5hL8PCWM1zUvn58rV-51SWUywn43XNgKYd14GcsYsb27DXivbFs67NG_q4ZiP8ohVXM7Q2g2Q_D5f1v",
        -- The same shape as a table: what a build before 0.43.84 wrote (a blob unpacks to this shape).
        ["1792105290-1:2"] = {
            ["runId"] = "1792105290-1",
            ["session"] = 2,
            ["epoch"] = 1792105331,
            ["link"] = "|cnIQ4:|Hitem:202616::::::::90:263::6:5:7981:9380:6652:1498:8767:1:28:2647:::::|h[Enduring Dreadplate]|h|r",
            ["boss"] = "Kazzara, the Hellforged",
            ["encounterID"] = 2688,
            ["owner"] = "Thalwyn-Area52",
            ["winner"] = "Brakka-Illidan",
            ["count"] = 3,
            ["candidates"] = {
                ["Brakka-Illidan"] = {
                    ["status"] = "RESPONDED",
                    ["response"] = "Mainspec",
                    ["responseID"] = 1,
                    ["r"] = 0.2, ["g"] = 0.8, ["b"] = 0.2,
                    ["note"] = "2pc tier with this",
                    ["ilvl"] = 441,
                    ["diff"] = 13,
                    ["gear1"] = "item:202465::::::::90:263::6:4:7981:9380:6652:1498:::::",
                },
                ["Velune-Area52"] = {
                    ["status"] = "RESPONDED",
                    ["response"] = "Offspec",
                    ["responseID"] = 2,
                    ["r"] = 1, ["g"] = 0.82, ["b"] = 0,
                    ["ilvl"] = 438,
                    ["diff"] = 3,
                    ["roll"] = 57,
                    ["rollBy"] = "player",
                },
                ["Morvessa-Zul'jin"] = {
                    ["status"] = "PASS",
                    ["responseCode"] = "PASS",
                },
            },
        },
    },
}
