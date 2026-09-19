# OriginShuffle v0.3.1-rc1

**Release state:** PUBLIC CANDIDATE / NOT YET PUBLISHED

OriginShuffle is a client-side cosmetic addon for Windower 4. When a supported weapon family is enabled, the local player's real Weapon Skill can be rendered on that client with a different Weapon Skill animation from the **same weapon family**.

The server action remains the real Weapon Skill. OriginShuffle does not send a substitute Weapon Skill to the server.

## What changes

OriginShuffle changes only the incoming action's per-action `animation` field for the local player's completed Weapon Skill action.

Example with Sword enabled:

- real action: `Fast Blade`
- server action: `Fast Blade`
- damage / TP use / skillchain properties / action message: remain those of `Fast Blade`
- local visual: a different Sword Weapon Skill animation, such as `Red Lotus Blade`, `Savage Blade`, or `Vorpal Blade`

The original animation is excluded from the candidate pool. When alternatives exist, the same replacement visual is also avoided on consecutive substitutions for that weapon family.

## Safety boundary

The implementation is deliberately fail-closed. It requires all of the following before substituting an animation:

- the actor is the local player;
- the action is a Weapon Skill completion;
- the real Weapon Skill resolves through Windower Resources;
- the Weapon Skill maps to one of the supported weapon families;
- that family is enabled;
- the packet/action structure is valid; and
- another listener has not already changed the action identity or animation.

OriginShuffle does **not** intentionally modify:

- the real Weapon Skill ID;
- outgoing Weapon Skill commands;
- damage;
- TP consumption;
- skillchain properties or additional effects;
- action target;
- GearSwap state or equipment;
- inventory; or
- server state.

Because the modification is applied only to the local client's incoming action representation and is not sent back to the server, other clients should continue to receive the real server action. A second-client observer check remains part of the release gate for this release candidate.

## Installation

1. Create a folder named `OriginShuffle` under `Windower/addons/`.
2. Copy `OriginShuffle.lua` into that folder.
3. In FFXI, load it with:

```text
//lua load OriginShuffle
```

All weapon families start **OFF** after every addon load. OriginShuffle writes no persistent configuration.

## Commands

```text
//originshuffle status
//originshuffle help

//originshuffle sword on
//originshuffle sword off
//originshuffle sword status
//originshuffle sword pool

//originshuffle pool sword

//originshuffle all on
//originshuffle all off
```

Alias: `//oshuffle`

Legacy compatibility: bare `//originshuffle on` and `//originshuffle off` control **Scythe** only.

Supported family names and common aliases:

- Hand-to-Hand: `h2h`, `handtohand`, `hand-to-hand`, `hand_to_hand`
- Dagger: `dagger`
- Sword: `sword`
- Great Sword: `greatsword`, `gs`, `great-sword`, `great_sword`
- Axe: `axe`
- Great Axe: `greataxe`, `ga`, `great-axe`, `great_axe`
- Scythe: `scythe`
- Polearm: `polearm`, `spear`
- Katana: `katana`
- Great Katana: `greatkatana`, `gkt`, `gk`, `great-katana`, `great_katana`
- Club: `club`
- Staff: `staff`
- Archery: `archery`, `bow`
- Marksmanship: `marksmanship`, `gun`, `ranged`

## Supported visual families

The current candidate contains same-family replacement pools for 14 weapon families:

Hand-to-Hand, Dagger, Sword, Great Sword, Axe, Great Axe, Scythe, Polearm, Katana, Great Katana, Club, Staff, Archery, and Marksmanship.

Prime Weapon Skills can be real-action triggers when their Windower resource entry maps to the relevant weapon family. Replacement candidates come from the maintained same-family animation pools in the addon.

## Dependencies

OriginShuffle uses Windower's Lua addon environment and its `actions` and `resources` libraries. Those dependencies are referenced through their APIs; their source code is not bundled in this repository candidate.

## Release-candidate validation still required

Before a public release:

1. Test multiple real Weapon Skills in Sword.
2. Test Origin plus at least one other real Scythe Weapon Skill.
3. Test at least one additional melee weapon family.
4. Test Archery and/or Marksmanship separately.
5. Confirm family OFF immediately restores native animations.
6. Confirm family ON substitutes only within that family.
7. Confirm the real animation is never selected as its own replacement.
8. Confirm damage, TP use, action message, and skillchain behavior remain those of the real Weapon Skill.
9. Where practical, verify from a second client that another player still sees the real action.
10. Verify zone, addon reload, and unload behavior.
11. Run a GearSwap regression smoke test around Weapon Skill precast/midcast/aftercast.
12. Select an explicit public license before publication.

## License

**No public license has been selected for this release candidate.** This repository candidate must not be published as a release until the owner explicitly selects a license and a `LICENSE` file is added.

## Provenance

This public candidate was derived from the exact private canonical OriginShuffle v0.3.0 implementation. Private bundle contents, development governance, evidence, and unrelated source are not part of this public package.
