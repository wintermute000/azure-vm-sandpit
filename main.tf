# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "ubuntu" {
  name     = "loj-vm-sandpit"
  location = "australiasoutheast"
  tags = {
    Name = "Johann Lo"
    username= "loj"
    ExpectedUseThrough= "2023-04" 
    VMState= "ShutdownAtNight"
    CostCenter= "790-5300"
    role = "vm-sandpit"
  }

}

resource "azurerm_virtual_network" "ubuntu" {
  name                = "ubuntu-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.ubuntu.location
  resource_group_name = azurerm_resource_group.ubuntu.name

  tags = {
    Name = "Johann Lo"
    username= "loj"
    ExpectedUseThrough= "2023-04" 
    VMState= "ShutdownAtNight"
    CostCenter= "790-5300"
    role = "vm-sandpit"
  }

}

resource "azurerm_subnet" "ubuntu" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.ubuntu.name
  virtual_network_name = azurerm_virtual_network.ubuntu.name
  address_prefixes     = ["10.0.2.0/24"]

}

resource "azurerm_network_interface" "ubuntu" {
  count               = 2
  name                = "UBUNTU-NIC-${count.index}"
  location            = azurerm_resource_group.ubuntu.location
  resource_group_name = azurerm_resource_group.ubuntu.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ubuntu.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.ubuntu.*.id, count.index)

  }

  tags = {
    Name = "Johann Lo"
    username= "loj"
    ExpectedUseThrough= "2023-04" 
    VMState= "ShutdownAtNight"
    CostCenter= "790-5300"
    role = "vm-sandpit"
  }

}

resource "azurerm_linux_virtual_machine" "ubuntu" {
  name                = "UBUNTU-VM-${count.index}"
  count               = 2
  resource_group_name = azurerm_resource_group.ubuntu.name
  location            = azurerm_resource_group.ubuntu.location
  size                = "Standard_DS1_v2"
  admin_username      = "johannlo"
  network_interface_ids = [
    element(azurerm_network_interface.ubuntu.*.id, count.index)
,
  ]
  admin_ssh_key {
    username   = "johannlo"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Name = "Johann Lo"
    username= "loj"
    ExpectedUseThrough= "2023-04" 
    VMState= "ShutdownAtNight"
    CostCenter= "790-5300"
    role = "vm-sandpit"
  }

}

resource "azurerm_public_ip" "ubuntu" {
  count               = 2
  name                = "UBUNTU-VM-NIC-0${count.index}"
  resource_group_name = azurerm_resource_group.ubuntu.name
  location            = azurerm_resource_group.ubuntu.location
  allocation_method   = "Dynamic"

  tags = {
    Name = "Johann Lo"
    username= "loj"
    ExpectedUseThrough= "2023-04" 
    VMState= "ShutdownAtNight"
    CostCenter= "790-5300"
    role = "vm-sandpit"
  }
}

resource "azurerm_network_security_group" "ubuntu" {
  name                = "ubuntu-security-group1"
  location            = azurerm_resource_group.ubuntu.location
  resource_group_name = azurerm_resource_group.ubuntu.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "https"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name = "Johann Lo"
    username= "loj"
    ExpectedUseThrough= "2023-04" 
    VMState= "ShutdownAtNight"
    CostCenter= "790-5300"
    role = "vm-sandpit"
  }
}
resource "azurerm_network_interface_security_group_association" "ubuntu" {
    count = 2
    network_interface_id      = element(azurerm_network_interface.ubuntu.*.id, count.index)
    network_security_group_id = azurerm_network_security_group.ubuntu.id
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "ubuntu" {
  count = 2
  virtual_machine_id = element(azurerm_linux_virtual_machine.ubuntu.*.id, count.index)
  location           = azurerm_resource_group.ubuntu.location
  enabled            = true

  daily_recurrence_time = "0000"
  timezone              = "E. Australia Standard Time"

   notification_settings {
   enabled         = false
   
  }

}