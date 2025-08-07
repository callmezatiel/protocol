#!/bin/bash
# Protocol
# Author: Zatiel 
# Requirements: arp-scan, nmap, figlet, lolcat, net-tools, sudo/root

# Colors
RED="\033[0;31m"; GREEN="\033[0;32m"; YELLOW="\033[1;33m"; NC="\033[0m"

# Root check
[[ $EUID -ne 0 ]] && { echo -e "${RED}[!] Run as root.${NC}"; exit 1; }

# Banner
clear; figlet -c "Net Recon Pro" | lolcat
echo -e "${GREEN}Author: Zatiel | Red Team Toolkit${NC}\n"

# Get system info
local_ip=$(hostname -I | awk '{print $1}')
domain=$(hostname -d 2>/dev/null || echo 'None')
interface=$(ip route | grep default | awk '{print $5}')
gateway=$(ip route | grep default | awk '{print $3}')

echo -e "${YELLOW}[+] System Info:${NC}"
echo -e "Interface: $interface\nLocal IP: $local_ip\nGateway: $gateway\nDomain: $domain\n"

# Create output directory
timestamp=$(date +"%Y%m%d_%H%M%S")
mkdir -p "recon_$timestamp"
cd "recon_$timestamp" || exit

# ARP-SCAN
read -p "Run ARP scan on local network? (y/n): " arp_choice
if [[ "$arp_choice" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}[*] Running ARP Scan on $interface...${NC}"
    arp-scan --interface=$interface --localnet > arp_scan.txt
    cat arp_scan.txt

    # Filter by vendor
    echo -e "\n${YELLOW}[+] Cisco Devices:${NC}"
    grep -i 'Cisco' arp_scan.txt || echo "None found."

    # Detect duplicate IPs
    echo -e "\n${YELLOW}[+] Duplicate IPs (Potential ARP spoofing):${NC}"
    awk '{print $1}' arp_scan.txt | sort | uniq -d

    echo -e "${GREEN}[✓] ARP scan results saved in arp_scan.txt${NC}\n"
fi

# NMAP SCAN OPTIONS
read -p "Run advanced Nmap scan? (y/n): " nmap_choice
if [[ "$nmap_choice" =~ ^[Yy]$ ]]; then
    read -p "Target IP or CIDR range (e.g., 192.168.1.0/24): " target

    echo -e "${GREEN}[*] Discovering live hosts on $target...${NC}"
    nmap -sn "$target" -oG hosts.gnmap > /dev/null
    grep Up hosts.gnmap | awk '{print $2}' > live_hosts.txt
    echo -e "${YELLOW}[+] Live Hosts:${NC}"; cat live_hosts.txt

    read -p "Scan open ports and services on live hosts? (y/n): " port_choice
    if [[ "$port_choice" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}[*] Scanning top 1000 ports (SYN, service/version detection, OS)...${NC}"
        while IFS= read -r ip; do
            echo -e "${YELLOW}--- Scanning $ip ---${NC}"
            nmap -sS -sV -O --top-ports 1000 -T4 "$ip" -oN "nmap_$ip.txt"
        done < live_hosts.txt
    fi

    read -p "Custom port scan? (e.g., 21,22,80,443): " custom_ports
    if [[ ! -z "$custom_ports" ]]; then
        for ip in $(cat live_hosts.txt); do
            echo -e "${GREEN}[*] Scanning custom ports on $ip...${NC}"
            nmap -p "$custom_ports" -sV "$ip" -oN "custom_ports_$ip.txt"
        done
    fi
fi

# NSE SCRIPT SCAN
read -p "Run NSE scans (vuln, smb, http)? (y/n): " nse_choice
if [[ "$nse_choice" =~ ^[Yy]$ ]]; then
    read -p "Target IP for NSE scripts: " nse_target
    echo -e "${GREEN}[*] Running common NSE scripts on $nse_target...${NC}"
    nmap -sV -p 80,443,139,445,22,21 \
        --script=vuln,smb-os-discovery,http-title,ftp-anon \
        "$nse_target" -oN "nse_$nse_target.txt"
    echo -e "${GREEN}[✓] NSE results saved in nse_$nse_target.txt${NC}"
fi

# BONUS: Save summary
echo -e "\n${YELLOW}[+] Summary saved to recon_summary.txt${NC}"
{
    echo "Scan Timestamp: $(date)"
    echo "Local IP: $local_ip"
    echo "Gateway: $gateway"
    echo "Interface: $interface"
    echo "Domain: $domain"
    echo "Targets Scanned: $(cat live_hosts.txt 2>/dev/null | wc -l)"
} > recon_summary.txt

echo -e "${GREEN}[✓] Recon complete. Output saved in recon_$timestamp/${NC}"
