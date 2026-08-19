mkdir -p "${WORKSPACE_DIR}/logs"
MAIN_LOG_FILE="${WORKSPACE_DIR}/logs/sysmon.log"

# Dual-routing log functions: Output to terminal AND append to the log file
log_info()  { echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [INFO]  $*" | tee -a "$MAIN_LOG_FILE"; }
log_warn()  { echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [WARN]  $*" | tee -a "$MAIN_LOG_FILE"; }
log_error() { echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [ERROR] $*" | tee -a "$MAIN_LOG_FILE" >&2; }