#!/usr/bin/env python3
"""
Daily Claude Code cost tracker.

Walks ~/.claude/projects/*/*.jsonl, sums token usage per day per project
(input + output + cache read + cache write), applies per-model rates, and
writes a markdown report.

To configure:
  1. Edit REPORT to point to where you want the markdown written. The default
     is ./ops/claude-spend.md relative to the script directory's parent.
  2. Edit RATES if Anthropic prices change (console.anthropic.com/settings/plans).

Trigger via launchd (macOS) or cron (Linux). See docs/scheduled-jobs.md.
"""
from __future__ import annotations

import json
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from pathlib import Path

# === Configure these two paths if you want a non-default location ===
PROJECTS_DIR = Path.home() / ".claude" / "projects"
# Default: write to <script-parent>/claude-spend.md so it lives next to other ops reports.
# Override with an absolute path if you want it elsewhere.
REPORT = Path(__file__).resolve().parent.parent / "claude-spend.md"

DAYS = 14

# Per-million-token USD rates. Update from console.anthropic.com/settings/plans
# when Anthropic changes prices. Cache write uses the 5-minute TTL rate.
RATES = {
    "opus":   {"in": 15.00, "out": 75.00, "cache_read": 1.50,  "cache_write": 18.75},
    "sonnet": {"in":  3.00, "out": 15.00, "cache_read": 0.30,  "cache_write":  3.75},
    "haiku":  {"in":  0.80, "out":  4.00, "cache_read": 0.08,  "cache_write":  1.00},
}


def family(model: str) -> str | None:
    if not model or model.startswith("<"):
        return None
    m = model.lower()
    if "opus" in m:
        return "opus"
    if "sonnet" in m:
        return "sonnet"
    if "haiku" in m:
        return "haiku"
    return None


def project_label(cwd: str | None, dir_name: str) -> str:
    if cwd:
        return Path(cwd).name
    return dir_name.lstrip("-").replace("-", "/")


def main() -> None:
    cutoff = datetime.now(timezone.utc) - timedelta(days=DAYS)

    rows: dict[tuple[str, str, str], dict[str, int]] = defaultdict(
        lambda: {"in": 0, "out": 0, "cache_read": 0, "cache_write": 0}
    )

    for project_dir in sorted(PROJECTS_DIR.glob("*")):
        if not project_dir.is_dir():
            continue
        for jsonl in project_dir.glob("*.jsonl"):
            try:
                with jsonl.open() as f:
                    for line in f:
                        try:
                            d = json.loads(line)
                        except json.JSONDecodeError:
                            continue
                        if d.get("type") != "assistant":
                            continue
                        ts = d.get("timestamp")
                        if not ts:
                            continue
                        try:
                            t = datetime.fromisoformat(ts.replace("Z", "+00:00"))
                        except ValueError:
                            continue
                        if t < cutoff:
                            continue
                        msg = d.get("message", {})
                        usage = msg.get("usage", {})
                        fam = family(msg.get("model", ""))
                        if not fam:
                            continue
                        day = t.strftime("%Y-%m-%d")
                        proj = project_label(d.get("cwd"), project_dir.name)
                        key = (day, proj, fam)
                        rows[key]["in"] += usage.get("input_tokens", 0) or 0
                        rows[key]["out"] += usage.get("output_tokens", 0) or 0
                        rows[key]["cache_read"] += usage.get("cache_read_input_tokens", 0) or 0
                        rows[key]["cache_write"] += usage.get("cache_creation_input_tokens", 0) or 0
            except OSError:
                continue

    per_day_project: dict[tuple[str, str], float] = defaultdict(float)
    per_day: dict[str, float] = defaultdict(float)
    per_project: dict[str, float] = defaultdict(float)
    grand_total = 0.0

    for (day, proj, fam), tok in sorted(rows.items()):
        r = RATES[fam]
        cost = (
            tok["in"] * r["in"]
            + tok["out"] * r["out"]
            + tok["cache_read"] * r["cache_read"]
            + tok["cache_write"] * r["cache_write"]
        ) / 1_000_000
        per_day_project[(day, proj)] += cost
        per_day[day] += cost
        per_project[proj] += cost
        grand_total += cost

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    with REPORT.open("w") as out:
        out.write("# Claude Code spend\n\n")
        out.write(f"_Generated {datetime.now(timezone.utc).isoformat(timespec='seconds')} - last {DAYS} days_\n\n")
        out.write(f"**API-rate total (last {DAYS} days): ${grand_total:,.2f}**\n\n")
        out.write("> This number is the per-token cost at public API rates. If you're on a Pro / Max / Team subscription, your actual bill is the flat subscription fee, not this number. Use this report to see relative spend per project + spot anomalies, not as your real invoice.\n\n")
        out.write("Rates per million tokens (edit the script if Anthropic changes them):\n\n")
        out.write("| family | input | output | cache_read | cache_write |\n")
        out.write("|---|---|---|---|---|\n")
        for fam, r in RATES.items():
            out.write(f"| {fam} | ${r['in']:.2f} | ${r['out']:.2f} | ${r['cache_read']:.2f} | ${r['cache_write']:.2f} |\n")
        out.write("\n## Daily totals\n\n")
        out.write("| day | $ |\n|---|---|\n")
        for day in sorted(per_day):
            out.write(f"| {day} | ${per_day[day]:,.2f} |\n")
        out.write("\n## Per project (whole window)\n\n")
        out.write("| project | $ |\n|---|---|\n")
        for proj, cost in sorted(per_project.items(), key=lambda x: -x[1]):
            out.write(f"| {proj} | ${cost:,.2f} |\n")
        out.write("\n## Breakdown (day x project, top 50 by $)\n\n")
        out.write("| day | project | $ |\n|---|---|---|\n")
        top = sorted(per_day_project.items(), key=lambda x: -x[1])[:50]
        for (day, proj), cost in top:
            out.write(f"| {day} | {proj} | ${cost:,.2f} |\n")
    print(f"wrote {REPORT} (total ${grand_total:,.2f})")


if __name__ == "__main__":
    main()
