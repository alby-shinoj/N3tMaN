#!/bin/bash

# Define IP ranges to scan
IP_RANGES=("192.169.2.0/24" "192.168.3.0/24")

# Output directory for reports
OUTPUT_DIR="scan_reports"
mkdir -p "$OUTPUT_DIR"

# Function to run Nmap scan
run_nmap() {
    local ip_range=$1
    local output_file="$OUTPUT_DIR/nmap_scan_$(echo $ip_range | tr '/' '-').xml"
    echo "[*] Scanning IP range: $ip_range"
    nmap -oX "$output_file" -p 80,443,8080 --open "$ip_range"
    echo "[+] Nmap scan completed for $ip_range. Results saved to $output_file"
}

# Function to generate HTML report from Nmap XML
generate_report() {
    local xml_file=$1
    local html_file="${xml_file%.xml}.html"
    xsltproc "$xml_file" -o "$html_file"
    echo "[+] Generated HTML report: $html_file"
}

# Function to run vulnerability scans on a target
run_vuln_scans() {
    local target=$1
    echo "[*] Running vulnerability scans on $target"

    # Nikto scan
    echo "[*] Running Nikto on $target"
    nikto -h "http://$target" -output "$OUTPUT_DIR/nikto_$target.txt"

    # Dirb scan
    echo "[*] Running Dirb on $target"
    dirb "http://$target" -o "$OUTPUT_DIR/dirb_$target.txt"

    # OWASP ZAP scan (basic spider and active scan)
    echo "[*] Running OWASP ZAP on $target"
    zaproxy -cmd -quickurl "http://$target" -quickout "$OUTPUT_DIR/zap_$target.html"
}

# Main script
for ip_range in "${IP_RANGES[@]}"; do
    run_nmap "$ip_range"
    xml_file="$OUTPUT_DIR/nmap_scan_$(echo $ip_range | tr '/' '-').xml"
    generate_report "$xml_file"

    # Extract live hosts from Nmap XML
    live_hosts=$(xmlstarlet sel -t -v "//address/@addr" "$xml_file")
    for host in $live_hosts; do
        echo "[*] Found live host: $host"
        run_vuln_scans "$host"
    done
done

echo "[+] All scans completed. Reports saved in $OUTPUT_DIR."
