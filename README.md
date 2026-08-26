# BAGArt/telegram-platform-workflows

Central reusable GitHub Actions workflows (`workflow_call`) for BAGArt
repositories. Job logic lives here; consumers own only trigger wiring and
secrets selection.

## Available workflows

| Workflow | Purpose | Inputs |
|---|---|---|
| `lint.yml` | pint / eslint / prettier | `php-version` |
| `tests.yml` | app + library suites, phpstan, artifact scan | `php-version` |
| `security.yml` | composer audit, semgrep (+SARIF), secret scans | `php-version`, `export-sarif` |
| `dependency-review.yml` | supply-chain gate on PRs | — |
| `nightly.yml` | full suite, audits, gitleaks history scan, coverage, mutation | `php-version` |
| `docker.yml` | build, Trivy scan, SBOM, policy gates, optional push | `php-version`, `push-image` |
| `baseline-drift.yml` | manifest drift gate | — |

## Consumer onboarding

```yaml
# .github/workflows/tests.yml in YOUR repo
name: Tests
on:
  push:
    branches: [develop, main]
  pull_request:

jobs:
  tests:
    uses: BAGArt/telegram-platform-workflows/.github/workflows/tests.yml@<COMMIT_SHA>  # pin!
    permissions:
      contents: read
    with:
      php-version: '8.5'
```

Rules (unchanged from host convention):
- Pin callers by **commit SHA**, never by tag/branch.
- Changes propagate by bumping the pinned SHA in consumers (one-line PR).
- Non-GitHub or special flows stay local per repo.

## Self-CI

This repo dogfoods `bagart/devops-baseline`: yaml-lint on every workflow,
SHA-pinning checks (`controls/github-policy.php`), shell-lint.
