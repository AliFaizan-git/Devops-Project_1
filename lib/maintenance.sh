# --- FILESYSTEM AUTOMATION & MAINTENANCE ---

manage_filesystem() {
    log_info "Running filesystem maintenance tasks..."

    # 1. Rolling Artifact Retention (Keep 7 recent, delete 8th+)
    local max_files=7

    # Helper function to enforce count-based retention
    prune_files() {
        local target_dir=$1
        local file_pattern=$2
        local keep_count=$3
        
        # Breakdown of this command:
        # 1. ls -1t: Lists files in a single column (-1), sorted by time newest first (-t)
        # 2. tail -n +X: Starts reading from line X (skipping the newest ones we want to keep)
        # 3. xargs -r rm -f: Takes the remaining older files and safely deletes them
        ls -1t "${target_dir}"/${file_pattern} 2>/dev/null | \
            tail -n +$((keep_count + 1)) | \
            xargs -r rm -f
    }

    # Apply the rule to our artifact directories
    prune_files "${WORKSPACE_DIR}/reports" "*.txt" "$max_files"
    prune_files "${WORKSPACE_DIR}/alerts" "*.txt" "$max_files"
    
    # Note: sysmon.log is a single continuous file, so it won't hit the 8-file limit. 
    # If you ever change logging to create a new file per day, this rule will catch it!
    prune_files "${WORKSPACE_DIR}/logs" "*.log" "$max_files"

    log_info "Retention policy applied: Retaining only the most recent ${max_files} artifacts."

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