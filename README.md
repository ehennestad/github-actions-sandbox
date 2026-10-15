# Segmented code issues badge demo

| Badge | Source |
| --- | --- |
| ![code issues, segmented](.github/badges/code_issues.svg) | Segmented badge from [ehennestad/matbox-actions#26](https://github.com/ehennestad/matbox-actions/pull/26) |
| ![code issues, single](.github/badges/code_issues_single.svg) | Current single badge, rendered from the same JSON |

The workflow in [`.github/workflows/segmented-badge-demo.yml`](.github/workflows/segmented-badge-demo.yml) runs on every push to this branch. It puts MatBox from [ehennestad/MatBox#72](https://github.com/ehennestad/MatBox/pull/72) on the MATLAB path, runs the `check-code` action from [ehennestad/matbox-actions#26](https://github.com/ehennestad/matbox-actions/pull/26) with `segmented_code_issues_badge: 'true'`, and commits both badges to `.github/badges`.

The files in `src` contain planted code issues:

- `brokenSyntax.m`: one error (a parse error)
- `legacyLookup.m`: two warnings (an unused variable and a call to `eval`)
- `summarizeValues.m`: three info issues (a growing array, `length(x) == 0`, a missing semicolon)

Edit them and push to see the badge change. For example, delete `brokenSyntax.m` and the error segment turns grey with a count of 0.
