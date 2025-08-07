[ Languages: [English](README.md) ]

<h1 align="center">
  <br>
  <a href="https://github.com/callmezatiel"><img src="https://i.postimg.cc/qB5YcSWX/Protocol-Icon.png" width=160 height=150 alt="Protocol"></a>
  <br>
  Protocol
  <br>
</h1>

<h4 align="center">Personal Spoofing</h4>


### What's Protocol?

Protocol is a easy network scanner.

### Some Features

- [x] Multiple clients.

### Call for Contributions⚠️

Hey, before you go to gallery you need to know that the Protocol is a open project, so, if you finds this tool useful and wants to add some functionality, improve the code performance or improve something in the Protocol, the best way to get it added is to submit a pull request <3

Dependencies

* "Kali Linux Distro"
* "Parrot Security OS"
* "Black Arch Distro" (TEST ONLY)

| Dependencies| Description |
| ------ | ------ |
| arp-scan |  Networking Scanner / Advanced IP Scanner (Non-optional) |
| git |  The fast distributed version control system (Non-optional) |
| nmap | Network Mapper |
| figlet | Banner ASCII |
| lolcat | Colors |
| net-tools | Utility Programs |
| sudo/root | root Access |

And some commands in automatic way to do its job i hope you like my tool.

IMPROVED SCRIPT GOAL
Professional header and authorship

Root privilege check

ARP network discovery with arp-scan

Advanced scanning with nmap

OS and service detection

Port scanning

NSE scripting

Result export

Interactive menu

Extra: Advanced arp-scan usage



## Preview
[![personal-spoofing.png](https://i.postimg.cc/ZnFTNjnd/personal-spoofing.png)](https://postimg.cc/sGxddYpj)


### Features

| Function                | Tool            | Purpose               |
| ----------------------- | --------------- | --------------------- |
| Root privilege check    | Bash            | Prevent misuse        |
| ARP network discovery   | `arp-scan`      | Local LAN detection   |
| Host live detection     | `nmap -sn`      | Ping sweep            |
| Port and service scan   | `nmap -sS -sV`  | Fingerprinting        |
| OS detection            | `nmap -O`       | OS-level intel        |
| NSE scripting           | `nmap --script` | Vulnerability testing |
| Export to file          | `-oN`, `-oG`    | Store results         |
| Filter by MAC Vendor    | `grep 'Cisco'`  | Vendor-specific scan  |
| Detect duplicate IPs    | `uniq -d`       | Spoofing detection    |
| Timestamped output file | Bash `date`     | Logs & audit          |


* and more, comming soon...

## Here is how to make the script works

# Install

* Open The Terminal .
* Type the following commands :

```
    git clone https://github.com/callmezatiel/protocol
    cd protocol
    chmod +x protocol.sh
    sudo ./protocol.sh 
```

# NOTE: Run with a root privilege

PROFESSIONAL RECOMMENDATIONS
Always run this in an authorized environment (lab or pentesting engagement).

You can add Masscan for large-scale scanning with speed.

Consider converting output to HTML reports using xsltproc or nmap-bootstrap.xsl for better visibility.

Add CLI flags (getopts) for non-interactive automation.

###  💙 Thanks and credits
N.E.S.T.S. Project 

### Author 
Zatiel ([callmezatiel](https://github.com/callmezatiel))

# Issues will be fixed asap. Pull Request Welcomed
https://github.com/callmezatiel/protocol/issues

## Buy me a coffee
<a href="https://www.paypal.me/zatiel"><img src="https://img.shields.io/badge/don-paypal-blue"></a> <a href="https://www.patreon.com/zatiel"><img src="https://img.shields.io/badge/don-patreon-ff69b4">
