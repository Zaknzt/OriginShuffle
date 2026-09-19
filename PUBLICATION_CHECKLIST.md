# Publication Checklist — v0.3.1

**Release decision:** READY FOR PUBLICATION

## Source and sanitation

- [x] Derived from exact canonical private `OriginShuffle.lua` v0.3.0.
- [x] v0.3.1-rc1 staged privately on GitHub and byte-verified.
- [x] Public author metadata sanitized to `Zaknzt`.
- [x] Private character-specific README wording removed.
- [x] Private Master/workstream/bundle material excluded.
- [x] No inventory, account, filesystem-path, credential, token, or private evidence content intentionally included.
- [x] Standalone installation and command documentation prepared.
- [x] Safety boundary documented.
- [x] Dependencies identified as Windower `actions` and `resources` API use.

## Validation

- [x] Syntax/static candidate validation passed.
- [x] Mocked action harness passed before release finalization.
- [x] Owner reports extended live use of private v0.3.0 across multiple weapon families with satisfactory behavior.
- [x] v0.3.1 gameplay logic confirmed unchanged from v0.3.0 except the explicit help-command branch and public metadata.
- [x] Owner explicitly accepted moving forward to publication.

## Additional verification not separately recorded

These were part of the original candidate matrix but were not individually documented in the owner's live report:

- [ ] Archery / Marksmanship presentation checked as a separately recorded test.
- [ ] Second-client observer check separately recorded.

They remain useful follow-up/community verification items. They are not represented as completed tests.

## Licensing

- [x] BSD 3-Clause selected for the public project.
- [x] `LICENSE` added with copyright holder `Zaknzt`, year 2026.

## Remaining publication actions

- [ ] Change repository visibility from Private to Public.
- [ ] Create tag `v0.3.1`.
- [ ] Create GitHub Release `OriginShuffle v0.3.1`.
- [ ] Attach clean install ZIP if desired.
- [ ] Perform one clean-download smoke test from the public release.

No private FFXI Development II Source or Master change is implied by publication.
