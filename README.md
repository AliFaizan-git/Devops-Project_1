# sysmon: System Health Monitor

A lightweight, modular, and production-ready Bash utility designed to monitor critical Linux system metrics (CPU, Memory, and Disk usage). `sysmon` evaluates real-time system health against configurable thresholds, generates localized reports, and performs automated lifecycle maintenance on its own outputs to prevent disk exhaustion.

##  Features

* **Modular Architecture:** Core logic is decoupled into distinct libraries for logging, metric collection, alerting, and maintenance.
* **Defensive Engineering:** Implements strict mode (`set -euo pipefail`), dynamic path resolution, and lock-file mechanisms (`trap`) to ensure safe execution in automated environments.
* **Localized State Management:** All generated artifacts (logs, reports, alerts) are safely written to local directories, preventing system pollution.
* **Zero Dependencies:** Relies entirely on standard Linux kernel utilities (`df`, `free`, `top`) and text processing tools (`awk`, `grep`, `sed`, `find`, `xargs`).

## Retention Policy
To ensure efficient disk usage, the `maintenance.sh` script enforces the following data lifecycle:

| File Type | Retention Strategy | Policy Detail |
| :--- | :--- | :--- |
| **Reports** | Rolling Retention | Keeps only the **latest 7** generated report files. |
| **Alerts** | Time-based | Deletes log files older than **7 days**. |

## 📁 Repository Structure

```text
sysmon/
├── sysmon.sh              # Main orchestrator script
├── config/ds
│   └── sysmon.cron        # Example crontab configuration
├── lib/
│   ├── alerting.sh        # Threshold evaluation and alert generation
│   ├── logging.sh         # Standardized stdout/stderr and file logging
│   ├── maintenance.sh     # Automated artifact rotation and filesystem auditing
│   └── metrics.sh         # Data extraction via system binaries
├── alerts/                # (Generated) Localized alert files
├── logs/                  # (Generated) Execution logs
└── reports/               # (Generated) Point-in-time health reports