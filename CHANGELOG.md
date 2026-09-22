# Changelog

## 0.4.1 — Cross-family routing and optional visual announcement

Release state: **STABLE**

- add explicit session-local trigger-family -> visual-family routing;
- retain same-family routing as the default for every supported family;
- add `//originshuffle <weapon> visual <visual-weapon>` and `visual same`;
- setting a visual route enables that trigger family;
- add optional local visual announcement with `announce on|off|status` and `echo` alias;
- report real WS -> selected local visual when announcement is enabled;
- retain default-OFF families and default-OFF announcement state on every load;
- preserve the existing fail-closed local-client-only action mutation boundary.

### Acceptance

- owner live test: cross-family Great Sword -> Great Katana routing passed;
- owner live test: optional visual announcement passed;
- owner explicitly approved the v0.4.1 addon feature set for publication on 2026-09-22;
- public runtime differs from the accepted private v0.4.1 runtime only in public author/release metadata.

## 0.3.1 — Initial public release

Release state: **STABLE**

Derived from the exact private canonical OriginShuffle v0.3.0 implementation and the reviewed v0.3.1-rc1 public candidate.

Changes from private v0.3.0:

- sanitize public author metadata to `Zaknzt`;
- replace private pilot-state header text with public-release wording;
- make `//originshuffle help` an explicit command instead of depending on unknown-command fallthrough;
- replace private/project-oriented documentation with a standalone public README;
- document installation, command aliases, safety boundaries, dependencies, validation, and provenance;
- add BSD-3-Clause licensing;
- add repository hygiene and publication documentation.

No Weapon Skill family, animation pool, action-filtering rule, mutation field, packet path, or persistent-settings behavior was intentionally changed from private v0.3.0.

### Validation basis

- private v0.3.0 used live for an extended session across multiple weapon families and accepted by the owner;
- v0.3.1-rc1 syntax/static validation passed;
- mocked action harness passed before release finalization;
- exact rc1 GitHub staging was byte-verified before stable finalization.

Ranged-family presentation and a separate second-client observer test were not individually recorded in the live acceptance evidence.

## 0.3.1-rc1 — Public candidate

Private GitHub staging candidate used to validate public packaging, sanitation, documentation, and final release metadata.

## 0.3.0 — Private canonical predecessor

Private project candidate that generalized local same-family visual substitution across 14 supported weapon families. Not itself published by this repository.
