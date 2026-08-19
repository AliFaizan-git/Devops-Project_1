# --- FILESYSTEM AUTOMATION & MAINTENANCE ---

manage_filesystem() {
    log_info "Running filesystem maintenance tasks..."

    # 1. Rolling Artifact Retention (Keep 7 recent, delete 8th+)
    local max_files=7
    local ALERT_RETENTION_DAYS=7
    
    # Helper function to enforce count-based retention
    prune_files() {
        local target_dir=$1
        local file_pattern=$2
        local keep_count=$3
         log_info "Cleaning up old reports (keeping newest $max_files)"

        ls -1t "${target_dir}"/${file_pattern} 2>/dev/null | \
            tail -n +$((keep_count + 1)) | \
            xargs -r rm -f
    }

    # Apply the rule to our artifact directories
    prune_files "${WORKSPACE_DIR}/reports" "*.txt" "$max_files"

    # 2. Time-based Retention for Alerts: Delete files older than 7 days
        log_info "Cleaning up alerts older than ${ALERT_RETENTION_DAYS} days..."
        find "${WORKSPACE_DIR}/alerts" -type f -name "*.txt" -mtime +"$ALERT_RETENTION_DAYS" -delete

    log_info "Retention policy applied"

    # 2. Large Orphaned File Audit
    local large_files
    large_files=$(find /tmp -type f -size +500M -user "$USER" 2>/dev/null || true)
    
    if [ -n "$large_files" ]; then
        log_warn "Extremely large files (>500MB) detected in /tmp!"
        echo "$large_files" | while IFS= read -r file; do
            log_warn "Investigate large file: $file"
        done
    else
        log_info "No large orphaned files detected in /tmp."
    fi
}