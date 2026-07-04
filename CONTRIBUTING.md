# Contributing to ServiceNow.API

Thank you for taking the time to contribute! This module wraps the
[ServiceNow REST API](https://www.servicenow.com/docs/) and is community maintained.

## Ways to contribute

- Report a bug or request a feature using the issue templates.
- Improve documentation.
- Submit a pull request with a fix or enhancement.

## Development setup

You need **PowerShell 7.2+** (the module also supports Windows PowerShell 5.1) and the following
modules, which the build script installs automatically if missing:

- [Pester](https://pester.dev/) 5.5+
- [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) 1.21+
- [platyPS](https://github.com/PowerShell/platyPS) 0.14.2+ (for help generation)

Clone the repository and run the full build (lint + test):

```powershell
./build.ps1 -Task Test
```

Run only the linter:

```powershell
./build.ps1 -Task Analyze
```

Regenerate the per-cmdlet Markdown help after editing any comment-based help, and commit the result
(CI fails if `docs/help/` is out of date):

```powershell
./build.ps1 -Task Docs
```

Import the module from source for manual testing:

```powershell
Import-Module ./src/ServiceNow.API/ServiceNow.API.psd1 -Force
```

## Coding conventions

- One public function per file under `src/ServiceNow.API/Public/`; private helpers go under
  `src/ServiceNow.API/Private/`.
- Every public function must use [approved verbs](https://learn.microsoft.com/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands),
  comment-based help, and `[CmdletBinding()]`.
- Functions that change state use `SupportsShouldProcess`.
- New cmdlets follow the `Verb-ServiceNowNoun` naming pattern and accept a `-Connection` override.
- Add or update Pester tests under `tests/` for every change. External calls
  (`Invoke-RestMethod`, `Invoke-WebRequest`) must be mocked — tests never hit a live instance.
- Code must pass PSScriptAnalyzer with the repository `PSScriptAnalyzerSettings.psd1`.

## Pull request process

1. Fork the repository and create a branch from `main`.
2. Make your change, including tests and documentation.
3. Ensure `./build.ps1 -Task Test` passes.
4. Update `CHANGELOG.md` under the `[Unreleased]` heading.
5. Open a pull request describing the change and linking any related issue.

## Releasing (maintainers)

Releases are automated through the **Release** GitHub Actions workflow:

1. Ensure `CHANGELOG.md` has the changes recorded under `[Unreleased]`.
2. Run the **Release** workflow (Actions tab) and choose `major`, `minor` or `patch`.
3. The workflow bumps the version (`./build.ps1 -Task Bump`), updates the changelog, runs the
   tests, publishes to the PowerShell Gallery, then commits, tags `vX.Y.Z` and creates a GitHub
   release.

The `PSGALLERY_API_KEY` repository secret must be set. A manually created GitHub release also
publishes, via the separate `publish.yml` workflow.

By contributing, you agree that your contributions will be licensed under the MIT License.
