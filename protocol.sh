#!/bin/bash
# protocol | Coded by Zatiel
# run with a root privilege 

echo "██████╗ ██████╗  ██████╗ ████████╗ ██████╗  ██████╗ ██████╗ ██╗"     
echo "██╔══██╗██╔══██╗██╔═══██╗╚══██╔══╝██╔═══██╗██╔════╝██╔═══██╗██║"    
echo "██████╔╝██████╔╝██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║"    
echo "██╔═══╝ ██╔══██╗██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║ "    
echo "██║     ██║  ██║╚██████╔╝   ██║   ╚██████╔╝╚██████╗╚██████╔╝███████╗"
echo "╚═╝     ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝  ╚═════╝ ╚═════╝ ╚══════╝"
echo "My ip is" ; hostname -i
echo "My Domain is" ; hostname -d 
echo "My working is mapped as" ; arp-scan -l
