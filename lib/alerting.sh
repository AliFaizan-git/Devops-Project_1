mkdir -p "${WORKSPACE_DIR}/alerts" "${WORKSPACE_DIR}/reports"

# A reusable function to evaluate ANY metric
# Arguments: $1=Metric Name, $2=Current Value, $3=Threshold, $4=Report File Path
evaluate_metric() {
    local metric_name=$1
    local current_val=$2
    local threshold_val=$3
    local report_file=$4

    if [ "$current_val" -ge "$threshold_val" ]; then
        log_warn "${metric_name} Usage Critical: ${current_val}% (Threshold: ${threshold_val}%)"
        echo "🚨 ${metric_name}: ${current_val}% (CRITICAL)" >> "$report_file"
        
        # Generate an isolated alert file locally
        local alert_file="${WORKSPACE_DIR}/alerts/${metric_name}_alert_$(date +%Y%m%d_%H%M%S).txt"
        echo "CRITICAL: ${metric_name} usage at ${current_val}%" > "$alert_file"
        echo "-------------------------------------------------" >> "$alert_file"
    else
        echo "✅ ${metric_name}: ${current_val}% (Healthy)" >> "$report_file"
    fi
}