#!/usr/bin/env bash
set -euo pipefail

# 1. Dynamic Path Resolution
# This guarantees the script knows exactly where it lives, no matter how it is executed
WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2. Configurable Thresholds 
DISK_THRESHOLD="${1:-80}"
MEM_THRESHOLD="${2:-80}"
CPU_THRESHOLD="${3:-80}"

# 3. Load Modules
source "${WORKSPACE_DIR}/lib/logging.sh"
source "${WORKSPACE_DIR}/lib/metrics.sh"
source "${WORKSPACE_DIR}/lib/alerting.sh"

# 4. Defensive Lock File & Trap 
LOCK_FILE="${WORKSPACE_DIR}/sysmon.lock"

if [ -f "$LOCK_FILE" ]; then
    # If the lock file exists, another instance is running. Abort!
    log_error "sysmon is already running. Exiting to prevent overlap."
    exit 1
fi
touch "$LOCK_FILE" # Create the lock

# Cleanup function to remove the lock file when the script exits
cleanup() {
    rm -f "$LOCK_FILE"
    log_info "sysmon execution finished. Lock file removed."
    log_edit ""
}
trap cleanup EXIT

# 5. Main Execution Logic
log_info "Starting system monitor..."

CURRENT_DISK=$(check_disk)
CURRENT_MEM=$(check_memory)
CURRENT_CPU=$(check_cpu)

# Setup local report file
REPORT_FILE="${WORKSPACE_DIR}/reports/health_report_$(date +%Y%m%d_%H%M%S).txt"

echo "=== SYSTEM HEALTH REPORT ===" > "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "----------------------------" >> "$REPORT_FILE"

# Evaluate everything using our modular function
evaluate_metric "Disk" "$CURRENT_DISK" "$DISK_THRESHOLD" "$REPORT_FILE"
evaluate_metric "Memory" "$CURRENT_MEM" "$MEM_THRESHOLD" "$REPORT_FILE"
evaluate_metric "CPU" "$CURRENT_CPU" "$CPU_THRESHOLD" "$REPORT_FILE"

echo "----------------------------" >> "$REPORT_FILE"

log_info "Report successfully generated at: $REPORT_FILE"
