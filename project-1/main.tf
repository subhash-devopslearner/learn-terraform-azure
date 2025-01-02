# List the Terraform providers
# Here, we are using azurerm provider

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the AzureRM Terraform provider

provider "azurerm" {
  features {}
}

# Create a Resource Group
# This will create a resource group under your Azure Cloud subcription

resource "azurerm_resource_group" "my-test-rg" {
  name     = "my-test-resource-group"
  location = "Central India"
  tags = {
    environments = "dev"
  }
}

# Create a Virtual Network
# This will create a vitual network under your resource group in Azure Cloud

resource "azurerm_virtual_network" "my-test-vn" {
  name                = "my-test-virtual-network"
  resource_group_name = azurerm_resource_group.my-test-rg.name
  location            = azurerm_resource_group.my-test-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environments = "dev"
  }
}

# Create a Subnet
# This will create a subnet in your vitual network under your resource group in Azure Cloud

resource "azurerm_subnet" "my-test-subnet1" {
  name                 = "my-test-subnet-1"
  resource_group_name  = azurerm_resource_group.my-test-rg.name
  virtual_network_name = azurerm_virtual_network.my-test-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

# Create a Network Security Group
# This will create a network security group for your resource group in Azure Cloud

resource "azurerm_network_security_group" "my-test-nsg1" {
  name                = "my-test-nsg-1"
  location            = azurerm_resource_group.my-test-rg.location
  resource_group_name = azurerm_resource_group.my-test-rg.name

  tags = {
    environments = "dev"
  }
}

# Create a Network Security Rule
# This will create an inbound security rule under your security group in Azure Cloud

resource "azurerm_network_security_rule" "my-test-nsr1" {
  name                        = "my-test-nsr-1"
  resource_group_name         = azurerm_resource_group.my-test-rg.name
  network_security_group_name = azurerm_network_security_group.my-test-nsg1.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

# Create a Subnet Network Security Group Association
# This will associate the network security group with your the subnet in Azure Cloud

resource "azurerm_subnet_network_security_group_association" "my-test-subnet1-nsg1-assn1" {
  network_security_group_id = azurerm_network_security_group.my-test-nsg1.id
  subnet_id                 = azurerm_subnet.my-test-subnet1.id
}

# Create a Public IP Address
# This will create an Public IP to access resources over internet in Azure Cloud

resource "azurerm_public_ip" "my-test-pip1" {
  name                = "my-test-public-ip-1"
  resource_group_name = azurerm_resource_group.my-test-rg.name
  location            = azurerm_resource_group.my-test-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environments = "dev"
  }
}

# Create a Network Interface
# This will create a network interface to be used for your virtual machine in Azure Cloud

resource "azurerm_network_interface" "my-test-ni1" {
  name                = "my-test-network-interface-1"
  location            = azurerm_resource_group.my-test-rg.location
  resource_group_name = azurerm_resource_group.my-test-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my-test-subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my-test-pip1.id
  }

  tags = {
    environments = "dev"
  }
}

# Create a Linux Virtual Machine
# This will create a Linux virtual machine in Azure Cloud

resource "azurerm_linux_virtual_machine" "my-test-lvm1" {
  name                = "my-test-linux-vm-1"
  resource_group_name = azurerm_resource_group.my-test-rg.name
  location            = azurerm_resource_group.my-test-rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.my-test-ni1.id,
  ]

  

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/my-test-lvm1.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    environments = "dev"
  }
}