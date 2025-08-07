#!/bin/bash
# Net Recon Tool | Coded by Zatiel 
# Requirements: arp-scan, nmap, figlet, lolcat, net-tools, sudo/root

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

# Root privilege check
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[!] This script must be run as root.${NC}"
   exit 1
fi

# Banner
clear
figlet -c "Network Recon" | lolcat
echo -e "${GREEN}Author: Zatiel | Toolkit for ethical hacking labs${NC}"
echo ""

# Basic host info
echo -e "${YELLOW}[+] System Info:${NC}"
echo -e "Local IP: $(hostname -I | awk '{print $1}')"
echo -e "Domain: $(hostname -d 2>/dev/null || echo 'None')"
echo -e "Active Interface: $(ip route | grep default | awk '{print $5}')"
echo ""

# ARP-Scan network discovery
read -p "Do you want to run ARP scan on local network? (y/n): " arp_choice
if [[ "$arp_choice" == "y" || "$arp_choice" == "Y" ]]; then
    echo -e "${GREEN}[*] Running arp-scan...${NC}"
    interface=$(ip route | grep default | awk '{print $5}')
    arp-scan --interface=$interface --localnet
    echo ""

    # Advanced arp-scan options
    echo -e "${YELLOW}[+] Running advanced arp-scan features...${NC}"

    # 1. Scan with custom MAC vendor filtering (example: Cisco)
    echo -e "${GREEN}[Advanced] Devices by Cisco (if present):${NC}"
    arp-scan --interface=$interface --localnet | grep -i 'Cisco' || echo "No Cisco devices found."
    echo ""

    # 2. Identify duplicate IPs (potential spoofing)
    echo -e "${GREEN}[Advanced] Checking for duplicate IPs on LAN...${NC}"
    arp-scan --interface=$interface --localnet | awk '{print $1}' | sort | uniq -d
    echo ""

    # 3. Output scan to file with timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    outfile="arp_scan_$timestamp.txt"
    echo -e "${GREEN}[Advanced] Saving ARP scan to $outfile...${NC}"
    arp-scan --interface=$interface --localnet > "$outfile"
    echo ""
fi

# Advanced Nmap scan
read -p "Do you want to run an advanced scan with Nmap? (y/n): " nmap_choice
if [[ "$nmap_choice" == "y" || "$nmap_choice" == "Y" ]]; then
    read -p "Enter IP or range to scan (e.g., 192.168.1.0/24): " target

    echo -e "${GREEN}[*] Scanning for live hosts...${NC}"
    nmap -sn $target -oG hosts.txt
    echo -e "${YELLOW}[*] Detected hosts:${NC}"
    grep Up hosts.txt | cut -d ' ' -f2
    echo ""

    read -p "Scan open ports on these hosts? (y/n): " port_choice
    if [[ "$port_choice" == "y" || "$port_choice" == "Y" ]]; then
        echo -e "${GREEN}[*] Scanning top 1000 ports and services...${NC}"
        for ip in $(grep Up hosts.txt | cut -d ' ' -f2); do
            echo -e "${YELLOW}--- Scanning $ip ---${NC}"
            nmap -sS -sV -O -T4 --top-ports 1000 $ip -oN "scan_$ip.txt"
        done
        echo -e "${GREEN}[+] Scan complete. Results saved in scan_*.txt${NC}"
    fi
fi

# Nmap NSE scripts
read -p "Do you want to run common NSE scripts (vuln, smb, http)? (y/n): " nse_choice
if [[ "$nse_choice" == "y" || "$nse_choice" == "Y" ]]; then
    read -p "Enter target IP for NSE scripts: " nse_target
    echo -e "${GREEN}[*] Running NSE scripts on $nse_target...${NC}"
    nmap -sV --script=vuln,smb-os-discovery,http-title $nse_target -oN "nse_$nse_target.txt"
    echo -e "${GREEN}[+] Results saved in nse_$nse_target.txt${NC}"
fi

# Done
echo -e "${GREEN}[✓] Execution complete. Use this data responsibly.${NC}"

