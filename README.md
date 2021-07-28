# azure-vm-sandpit

Creates 2x Ubuntu 18.04 LTS VMs in a new Azure resource group
- VNET 10.0.0.0/8
- Subnet 10.0.2.0/24
- Standard_DS1_v2
- Standard LRS
- Public IPs
- NSGs allowing TCP 22, 80, 443
- autoshutdown at midnight AEST
