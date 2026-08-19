# Extract disk usage percentage of the root partition
check_disk() {
    df / | awk 'NR==2 {print $5}' | sed 's/%//'
}

# Calculate used memory percentage
check_memory() {
    free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100}'
}

# Extract CPU usage percentage
check_cpu() {
    top -bn1 | grep "Cpu(s)" | awk '{printf("%.0f"), $2 + $4}'
}