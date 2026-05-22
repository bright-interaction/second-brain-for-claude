# Scheduled Jobs

Optional add-on. Five recurring jobs that keep an eye on your stack without you having to remember to run anything. Installed by step 10 of `SETUP.md` if you opt in.

## The five jobs

| Name | Cadence | Type | What it does |
|---|---|---|---|
| `cert-expiry` | daily 09:00 | pure bash | TLS cert sweep across a domain list. Notifies if any cert expires in under 14 days. |
| `test-gaps` | nightly 03:30 | pure bash, Go-only | `go test -cover` across the monorepo. Writes a markdown report of packages under 50%. |
| `claude-spend` | daily 23:55 | Python | Sums tokens across `~/.claude/projects/*/*.jsonl`. Writes a 14-day rolling spend report. |
| `security-audit` | weekly Mon 03:00 | headless Claude | EXAMPLE. Runs your audit tool, diffs against last week, logs regressions to the wiki. |
| `seo-drift` | weekly Mon 04:00 | headless Claude | EXAMPLE. Runs an SEO audit on your site, diffs against last week, logs regressions. |

The first three are cheap (free, in fact) and safe to run daily. The last two cost real tokens - they run weekly for that reason.

## Files

```
{{PROJECT_PATH}}/ops/scripts/scheduled-cert-expiry.sh
{{PROJECT_PATH}}/ops/scripts/scheduled-test-gaps.sh
{{PROJECT_PATH}}/ops/scripts/scheduled-claude-spend.py
{{PROJECT_PATH}}/ops/scripts/scheduled-security-audit.sh
{{PROJECT_PATH}}/ops/scripts/scheduled-seo-drift.sh
```

Reports written into `{{PROJECT_PATH}}/ops/`:
- `claude-spend.md` (rewritten daily, 14-day window)
- `test-gaps.md` (rewritten nightly)
- `last-security-posture.json` (snapshot, weekly)
- `last-seo-snapshot.json` (snapshot, weekly)

## macOS: launchd

Each job has a plist at `~/Library/LaunchAgents/<prefix>.<job>.plist`. Load with:

```bash
launchctl load   ~/Library/LaunchAgents/<prefix>.cert-expiry.plist
launchctl unload ~/Library/LaunchAgents/<prefix>.cert-expiry.plist   # to disable
launchctl start  <prefix>.cert-expiry                                 # trigger manually
launchctl list   | grep <prefix>                                      # see what's loaded
```

`<prefix>` is whatever you pick during setup (`com.yourorg.<project>` works).

Standard out and standard error go to `~/Library/Logs/<job>.out.log` and `.err.log`. Watch with `tail -f`.

Reload after editing a plist:

```bash
launchctl unload ~/Library/LaunchAgents/<prefix>.<job>.plist
launchctl load   ~/Library/LaunchAgents/<prefix>.<job>.plist
```

## Linux: cron

A ready-to-paste crontab is at `templates/cron/scheduled-jobs.crontab.template`. Substitute `{{PROJECT_PATH}}`, then:

```bash
crontab -e
# paste the lines you want active, save, quit
crontab -l   # confirm what's loaded
```

Logs default to `$HOME/.local/share/<job>.out.log`. The scripts handle the macOS/Linux split themselves (different log paths, notify-send instead of osascript).

## Per-job notes

### cert-expiry
- **Edit `DOMAINS=( ... )`** in `scheduled-cert-expiry.sh` to list your domains. Empty list = no work.
- Threshold is 14 days. Edit `THRESHOLD_DAYS` to taste.
- macOS notifies via `osascript`. Linux uses `notify-send` if a display is available, otherwise falls back to `logger`.

### test-gaps
- Skip this job if your project is not Go.
- Walks `find -maxdepth 2 -name go.mod`. Adjust if your repo nests Go modules deeper.
- Threshold is 50%. Edit `THRESHOLD` to taste.

### claude-spend
- No edits required.
- Rates are at the top of the file. Update them if Anthropic changes pricing.
- The report sums **API-rate** cost. If you're on a Pro/Max/Team subscription, your actual bill is the flat fee - this number is for relative comparison across projects and for spotting anomalies.

### security-audit (example, edit before using)
- The script's `PROMPT` block is a placeholder. **You must edit it** to point at your actual audit tool (an MCP server's audit tool, a Claude skill, a CLI scanner you wrap with `claude -p`).
- Reference implementation in our internal repo calls the Dockyard MCP server's `run_security_audit` + `get_security_posture` tools.
- Snapshot lives at `{{PROJECT_PATH}}/ops/last-security-posture.json`. Delete it to reset the diff.

### seo-drift (example, edit before using)
- Set `TARGET_URL` to your site.
- The PROMPT assumes you have an `seo-audit` skill installed. If you have something else (`lighthouse`, `pagespeed-insights`, raw curl + heuristics), edit the prompt.
- Snapshot lives at `{{PROJECT_PATH}}/ops/last-seo-snapshot.json`.

## Cost note

The two headless-Claude jobs use the `claude` CLI in `-p` (one-shot) mode. Each run is a fresh session with its own token cost. Weekly cadence is the sweet spot. Daily is expensive without much new information. Monthly misses regressions for too long.

The non-Claude jobs (cert-expiry, test-gaps, claude-spend) are free to run daily. They do not call any API.

## Inspecting + debugging

```bash
# what's loaded (macOS):
launchctl list | grep <prefix>

# what's loaded (Linux):
crontab -l

# trigger a job by hand:
launchctl start <prefix>.<job>              # macOS
{{PROJECT_PATH}}/ops/scripts/scheduled-*.sh # Linux (run directly)

# tail the logs:
tail -f ~/Library/Logs/<job>.{out,err}.log         # macOS
tail -f $HOME/.local/share/<job>.out.log           # Linux

# check a script's exit code:
{{PROJECT_PATH}}/ops/scripts/scheduled-cert-expiry.sh; echo "exit=$?"
```

## Removing a job

```bash
# macOS:
launchctl unload ~/Library/LaunchAgents/<prefix>.<job>.plist
rm ~/Library/LaunchAgents/<prefix>.<job>.plist

# Linux:
crontab -e   # delete the line

# either OS:
rm {{PROJECT_PATH}}/ops/scripts/scheduled-<job>.sh
```

The scripts are independent. Removing one does not affect the others.
