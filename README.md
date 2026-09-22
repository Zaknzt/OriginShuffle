# OriginShuffle v0.4.1

**Release state:** STABLE / PUBLIC RELEASE

OriginShuffle is a client-side cosmetic addon for Windower 4. It can replace the local animation shown for your real Weapon Skill while leaving the server action unchanged.

By default, each enabled weapon family uses its own visual pool. v0.4.1 also supports explicit **cross-family visual routing**, so a real Great Sword WS can, for example, be rendered locally with a Great Katana WS animation.

## What changes

OriginShuffle changes only the incoming action's per-action `animation` field for the local player's completed Weapon Skill action.

Example:

```text
//originshuffle greatsword visual greatkatana
```

A real `Torcleaver` remains Torcleaver for the server, damage, TP consumption, skillchain properties/messages, target, and GearSwap behavior, while your local client may render a Great Katana visual such as `Tachi: Fudo`.

Cross-family routes are explicit and session-local. All trigger families start **OFF** after every addon load, and every visual route defaults to **same-family**.

## Optional animation announcement

The local visual-name echo is **OFF by default**.

```text
//originshuffle announce on
//originshuffle announce off
//originshuffle announce status
```

`echo` is an alias for `announce`.

When enabled, a successful substitution prints one local line such as:

```text
[OriginShuffle] Torcleaver -> Tachi: Fudo [Great Katana visual]
```

The left side is the real Weapon Skill. The right side is the animation selected for local display.

## Installation

1. Create `Windower/addons/OriginShuffle/`.
2. Copy `OriginShuffle.lua` into that folder.
3. Load it in FFXI:

```text
//lua load OriginShuffle
```

## Commands

```text
//originshuffle status
//originshuffle help

//originshuffle <weapon> on
//originshuffle <weapon> off
//originshuffle <weapon> status
//originshuffle <weapon> pool

//originshuffle <weapon> visual <visual-weapon>
//originshuffle <weapon> visual same

//originshuffle announce on
//originshuffle announce off
//originshuffle announce status

//originshuffle echo on
//originshuffle echo off
//originshuffle echo status

//originshuffle pool <weapon>
//originshuffle all on
//originshuffle all off
```

Alias: `//oshuffle`

Setting an explicit visual route also turns that trigger family ON. `visual same` restores same-family routing.

Legacy compatibility: bare `//originshuffle on` and `//originshuffle off` control **Scythe** only.

Supported weapon families: Hand-to-Hand, Dagger, Sword, Great Sword, Axe, Great Axe, Scythe, Polearm, Katana, Great Katana, Club, Staff, Archery, and Marksmanship.

## Safety boundary

The implementation is deliberately fail-closed. OriginShuffle acts only on the local player's completed Weapon Skill action after validating actor, category, real WS identity, packet/action shape, enabled trigger family, and selected visual family.

OriginShuffle does **not** intentionally modify:

- the real Weapon Skill ID;
- outgoing Weapon Skill commands or packets;
- damage;
- TP consumption;
- skillchain properties, messages, or additional effects;
- target;
- GearSwap state or equipment;
- inventory;
- server state; or
- other clients' action state.

The optional announcement uses only the existing local chat path after a successful visual substitution.

## Validation

v0.4.1 was promoted after owner live testing and approval of the addon feature set. The cross-family Great Sword -> Great Katana route was confirmed live, and the optional announcement layer was approved with the selected visual reported locally while normal WS mechanics remained unchanged.

The public runtime is derived from the accepted private v0.4.1 implementation. Public differences are release metadata/sanitation only (`Zaknzt` author identity and public-release header wording).

## Dependencies

OriginShuffle uses Windower's Lua addon environment and its `actions` and `resources` libraries. Those dependencies are referenced through their APIs; their source code is not bundled here.

## License

OriginShuffle is released under the **BSD 3-Clause License**. See [LICENSE](LICENSE).

## Provenance

This public v0.4.1 release is derived from the owner-tested private v0.4.1 implementation. Private project governance, bundles, evidence, and unrelated source are not part of this repository.
