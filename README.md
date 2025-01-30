# N3tMaN
Perform basic network scanning and web server enumeration on the IP ranges
What the Script Does
Nmap Scan:

Scans the specified IP ranges (<ip> and <ip>) for open ports (80, 443, 8080).

Saves the results in XML format.

Report Generation:

Converts the Nmap XML output to an HTML report using xsltproc.

Vulnerability Scans:

Runs Nikto, Dirb, and OWASP ZAP on each live host found by Nmap.

Saves the results in the scan_reports directory.

Output:

All reports (Nmap, Nikto, Dirb, OWASP ZAP) are saved in the scan_reports directory.
