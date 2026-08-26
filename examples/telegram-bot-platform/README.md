# Platform caller workflows (copy-paste set)

Ready-made `.github/workflows/*` files for **bagart/telegram-bot-platform**,
switching CI from the legacy in-repo pipelines to the central reusable
workflows (`BAGArt/telegram-platform-workflows`).

## Switch procedure

Automated: run `cmd/ops/central-ci-switch` from the platform root once both
GitHub repos exist — it pushes the checkouts, pins this repo's HEAD SHA into
the callers, installs them over the host pipeline bodies and yaml-lints.

Manual equivalent (devops3.md §1):

1. Push this repo to GitHub; grab its first commit SHA:
   `git -C misc/BAGArt/telegram-platform-workflows rev-parse HEAD`
2. Copy every `*.yml` here into the platform's `.github/workflows/`
   **except** `prod-install.yml` handling below, replacing the
   `<CENTRAL_SHA>` placeholder with that SHA:
   `sed -i 's|@<CENTRAL_SHA>|@<real-sha>|g' .github/workflows/*.yml`
3. Delete the superseded host-local pipeline bodies that these replace —
   keep `bootstrap.yml`, `maintenance.yml`, `pr-triage.yml` (host-only:
   they orchestrate repo tooling, no central counterpart).
4. `prod-install.yml` is platform-specific (dual-mode B P4): it stays a
   local job but is included here as the canonical template.
5. Commit on a branch, open PR, verify all pipelines green, then merge.

## Rules

- Pin by commit SHA, never tag/branch (central `controls/github-policy.php`
  enforces this in its own self-CI too).
- Propagation = one-line SHA bump per consumer.
- Triggers mirror the legacy host workflows exactly (branch set
  `develop/main/master/workos`, cron schedules unchanged), so switching is
  behavior-preserving.
