"""Unpacks SLC's packed history (SLC_Data_Guide.md, section 1a). Python 3, standard library only.

A packed string is: base64 (URL-safe alphabet, '=' padding) -> raw Deflate (NOT zlib-wrapped)
-> CBOR. Lua strings arrive as CBOR byte strings, so decode them to text.
The two blobs below are real SLC 0.43.94 output; running this file checks them.
"""
import base64, struct, zlib

SEG = "xZM_b9NAGIfVsrGwsNABmYGNKPYl_pNbiovd2m0SAamgEmK43L2Jr73cmbPdtFUGdj4BbHRHQmLhK_BR2FhY6IKT1C2BqCpTb7P83t3vfd7nTn3-ce-BpoLiDU0ODkgtFoIzIrHlerY5WzXL_dTWkKVKZrALR3mnQ7jMUqD1LgDbzFShKQTTQwLB5cHe_oTK-FkTTyKewwgjEzmWg89Xy8TIaWDsYBu7Lc_CrYZnYsexEbaaLQ97ruNiCyOvLGu6sy2T5FUoWaG5HBqBBsJSQXJ4PUkmeoOza8QPIVU0WdtnPx6HhyqHbLXN-GDAaSHy4zi4E-R8BBGyygTYtIO-yrKXO-TkhGjyyMgTMCIQYqD0EFhUdp4TSWHvod8HrYtsXtFLCFNjYMYTXVDeF1CLQCtON8dcStDdxXgBKxsoL6ybbh052xXcOFjxk9P2NLtl2o2GVWt-XQtkmfg5SqmRc9DGmOdJeSPPwmHBBeuER2SUCjC2pl9-_2z92_vp-jC7YnvKvm56dRP5w7P17_NfOyCpKmQOOg7u3X57Zb9zNGYDN8v5WBEZE8168GYl1IWMWRUVtUrM3UumXTKCzTmABXOiypxIA1WalWB2EyLGx7Lml4O10U0ItMA7VGP5TypfX2C9nP_9q-cfD7Uq0h4_gbuLsrWrE3aP0_LVEM5iBoIfggb2szJ18O7LcnO2MsgyruTqn9JUHTRNVLM_Xw6pKr71tww3iXkWco658wJEIeGc8rXR_o-_yx761OYGRmgp91_n3BezLdH9QuwnikHw1O_1fgM="
SNAP = "fZDPTsJAEMYj3ky8iyceQJK20H97ISVboCDgv6iJ8bC0U7qwbsluK4H04N0n0KMXjVcTEx_BR_EZuFgQOXhwbvPNN_P7Mq-YUT6-HGU-946rKGvRBG6QpmiGaqB12QrSjApCBtKRaVsqsiuWggxD15BatS1kmYaJVKRZua1qrlay6MrlQSooH5awABJMGEngOosy4cIk9qP9UXj_1gHuxylPQHi4uHOHB7GUFx0ynxNBDkpJBKUWMBbGYgiBu3IWmhKkpDEvuPGUg-idRYRNZ7zs5BBda0wpX6p1QcZjUvYYowHhrki5FxyqpqWriq7ZSllt-4QH-SwB-fTH_YIDGoa7zmBR-3xY1iOm7JYVtz4csZEaMiFJKr0T9_So38MubguQk5hL8PCWM1zUvn58rV-51SWUywn43XNgKYd14GcsYsb27DXivbFs67NG_q4ZiP8ohVXM7Q2g2Q_D5f1v"


def _cbor(b, p=0):
    mt, ai = b[p] >> 5, b[p] & 31; p += 1
    if ai < 24: v = ai
    elif ai == 24: v = b[p]; p += 1
    elif ai == 25: v = struct.unpack(">H", b[p:p+2])[0]; p += 2
    elif ai == 26: v = struct.unpack(">I", b[p:p+4])[0]; p += 4
    elif ai == 27: v = struct.unpack(">Q", b[p:p+8])[0]; p += 8
    if mt == 0: return v, p
    if mt == 1: return -1 - v, p
    if mt in (2, 3): return b[p:p+v].decode("utf-8"), p + v      # Lua strings are byte strings
    if mt == 4:
        out = []
        for _ in range(v):
            x, p = _cbor(b, p); out.append(x)
        return out, p
    if mt == 5:
        out = {}
        for _ in range(v):
            k, p = _cbor(b, p); x, p = _cbor(b, p); out[k] = x
        return out, p
    if mt == 7 and ai in (20, 21, 22): return (False, True, None)[ai - 20], p
    if mt == 7 and ai == 26: return struct.unpack(">f", b[p-4:p])[0], p
    if mt == 7 and ai == 27: return struct.unpack(">d", b[p-8:p])[0], p
    raise ValueError("unsupported CBOR item")


def unpack(blob):
    """A packed string -> the table it holds, or None if it will not decode (skip it, no error)."""
    try:
        raw = base64.urlsafe_b64decode(blob + "=" * (-len(blob) % 4))
        return _cbor(zlib.decompress(raw, -15))[0]
    except Exception:
        return None


def all_rows(db):
    """Every SLC history row, live and archived, as {id: row}. `db` is the parsed saved table."""
    rows = {}
    for seg in (db.get("historyArchive") or {}).get("segs", {}).values():
        t = unpack(seg.get("blob", ""))
        if t:
            rows.update(t.get("h", {})); rows.update(t.get("i", {}))
    rows.update(db.get("history") or {}); rows.update(db.get("imported") or {})   # live copy wins
    return rows


def snapshot(value):
    """A historySnapshots value -> the snapshot table (a packed 'z<epoch>:<blob>' string or a table)."""
    return unpack(value.split(":", 1)[1]) if isinstance(value, str) else value


if __name__ == "__main__":
    seg = unpack(SEG)
    assert len(seg["h"]) == 2 and len(seg["i"]) == 1 and seg["h"]["1785105331-4"]["winner"] == "Brakka-Illidan"
    snap = unpack(SNAP)
    assert snap["winner"] == "Brakka-Illidan" and snap["candidates"]["Velune-Area52"]["roll"] == 57
    rows = all_rows({"historyArchive": {"segs": {"2026-08.1": {"blob": SEG}}}, "history": {}})
    assert len(rows) == 3
    print("ok:", len(rows), "rows from one archive segment,", len(snap["candidates"]), "snapshot candidates")
