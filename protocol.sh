#!/bin/bash
# Network Recon Toolkit - Protocol Professional Edition
# Author: Zatiel 
# Requirements: arp-scan, nmap, figlet, net-tools, sudo/root

# ====== Colors ======
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

# ====== Root Check ======
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[!] This script must be run as root.${NC}"
   exit 1
fi

# ====== Banner ======
clear
if command -v figlet >/dev/null 2>&1; then
    figlet "Net Recon"
else
    echo -e "${YELLOW}*** Net Recon Toolkit ***${NC}"
fi
echo -e "${GREEN}Author: Zatiel | Red Team Network Recon Toolkit${NC}\n"

# ====== System Info ======
local_ip=$(hostname -I | awk '{print $1}')
domain=$(hostname -d 2>/dev/null || echo 'N/A')
interface=$(ip route | grep default | awk '{print $5}')
gateway=$(ip route | grep default | awk '{print $3}')

echo -e "${YELLOW}[+] System Info:${NC}"
echo -e "  ➤ Local IP     : $local_ip"
echo -e "  ➤ Gateway      : $gateway"
echo -e "  ➤ Interface    : $interface"
echo -e "  ➤ Domain       : $domain\n"

# ====== Output Folder ======
timestamp=$(date +"%Y%m%d_%H%M%S")
output_dir="recon_$timestamp"
mkdir -p "$output_dir"

# ====== ARP-Scan ======
read -rp "Do you want to run ARP scan on the local network? (y/n): " arp_choice
if [[ "$arp_choice" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}[*] Running arp-scan on $interface...${NC}"
    arp-scan --interface="$interface" --localnet > "$output_dir/arp_scan.txt" 2>/dev/null

    if [[ -s "$output_dir/arp_scan.txt" ]]; then
        cat "$output_dir/arp_scan.txt"

        echo -e "\n${YELLOW}[+] Cisco Devices Found:${NC}"
        grep -i 'Cisco' "$output_dir/arp_scan.txt" || echo "  ➤ None found."

        echo -e "\n${YELLOW}[+] Duplicate IPs (Potential ARP Spoofing):${NC}"
        awk '{print $1}' "$output_dir/arp_scan.txt" | sort | uniq -d || echo "  ➤ None detected."
    else
        echo -e "${RED}[!] arp-scan failed or found no active devices.${NC}"
    fi
    echo ""
fi

# ====== Nmap Discovery ======
read -rp "Do you want to run an advanced Nmap scan? (y/n): " nmap_choice
if [[ "$nmap_choice" =~ ^[Yy]$ ]]; then
    read -rp "Enter the target IP range (e.g., 192.168.1.0/24): " target_range

    echo -e "${GREEN}[*] Discovering live hosts on $target_range...${NC}"
    nmap -sn "$target_range" -oG "$output_dir/hosts.gnmap" >/dev/null
    grep Up "$output_dir/hosts.gnmap" | awk '{print $2}' > "$output_dir/live_hosts.txt"

    if [[ -s "$output_dir/live_hosts.txt" ]]; then
        echo -e "${YELLOW}[+] Live Hosts Detected:${NC}"
        cat "$output_dir/live_hosts.txt"
    else
        echo -e "${RED}[!] No live hosts detected.${NC}"
        exit 1
    fi
    echo ""

    # Standard Port Scan
    read -rp "Scan open ports and services on live hosts? (y/n): " port_choice
    if [[ "$port_choice" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}[*] Scanning top 1000 ports and service versions...${NC}"
        while IFS= read -r ip; do
            echo -e "${YELLOW}--- Scanning $ip ---${NC}"
            nmap -sS -sV -O --top-ports 1000 -T4 "$ip" -oN "$output_dir/nmap_$ip.txt"
        done < "$output_dir/live_hosts.txt"
        echo -e "${GREEN}[✓] Nmap scans completed.${NC}\n"
    fi

    # Custom Port Scan
    read -rp "Custom port scan? (e.g., 21,22,80): " custom_ports
    if [[ -n "$custom_ports" ]]; then
        while IFS= read -r ip; do
            echo -e "${YELLOW}--- Custom scan on $ip ---${NC}"
            nmap -p "$custom_ports" -sV "$ip" -oN "$output_dir/custom_ports_$ip.txt"
        done < "$output_dir/live_hosts.txt"
    fi
fi

# ====== NSE Scripts ======
read -rp "Run common NSE scripts (vuln, smb, http)? (y/n): " nse_choice
if [[ "$nse_choice" =~ ^[Yy]$ ]]; then
    read -rp "Enter target IP for NSE scripts: " nse_target
    echo -e "${GREEN}[*] Running NSE scripts on $nse_target...${NC}"
    nmap -sV -p 21,22,80,139,443,445 \
        --script=vuln,smb-os-discovery,http-title \
        "$nse_target" -oN "$output_dir/nse_$nse_target.txt"
    echo -e "${GREEN}[✓] NSE script results saved in nse_$nse_target.txt${NC}\n"
fi

# ====== Summary ======
summary_file="$output_dir/recon_summary.txt"
{
    echo "=== RECON SUMMARY ==="
    echo "Date: $(date)"
    echo "Local IP: $local_ip"
    echo "Gateway: $gateway"
    echo "Interface: $interface"
    echo "Domain: $domain"
    echo "Live Hosts Detected: $(wc -l < "$output_dir/live_hosts.txt" 2>/dev/null || echo 0)"
} > "$summary_file"

echo -e "${GREEN}[✓] Recon complete. All results are saved in: $output_dir/${NC}"

