terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.18.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "ta-resources"
    storage_account_name = "tastorageaccount"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "256c47d7-6c5f-4e92-b116-d234771e3690"
}

resource "azurerm_resource_group" "ta-rg" {
  name     = "ta-resources"
  location = "West Europe"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_storage_account" "ta_storage" {
  name                     = "tastorageaccount"
  resource_group_name      = azurerm_resource_group.ta-rg.name
  location                 = azurerm_resource_group.ta-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.ta_storage.name
  container_access_type = "private"
}

resource "azurerm_virtual_network" "ta-vnet" {
  name                = "ta-vnet"
  resource_group_name = azurerm_resource_group.ta-rg.name
  location            = azurerm_resource_group.ta-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "ta-subnet" {
  name                 = "ta-subnet"
  resource_group_name  = azurerm_resource_group.ta-rg.name
  virtual_network_name = azurerm_virtual_network.ta-vnet.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "ta-nsg" {
  name                = "ta-nsg"
  location            = azurerm_resource_group.ta-rg.location
  resource_group_name = azurerm_resource_group.ta-rg.name

  tags = {
    environment = "dev"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "ta-pip" {
  name                = "ta-pip"
  location            = azurerm_resource_group.ta-rg.location
  resource_group_name = azurerm_resource_group.ta-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "ta-nic" {
  name                = "ta-nic"
  location            = azurerm_resource_group.ta-rg.location
  resource_group_name = azurerm_resource_group.ta-rg.name

  ip_configuration {
    name                          = "ta-nic-ipconfig"
    subnet_id                     = azurerm_subnet.ta-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ta-pip.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_machine" "ta-vm" {
  name                  = "ta-vm"
  location              = azurerm_resource_group.ta-rg.location
  resource_group_name   = azurerm_resource_group.ta-rg.name
  network_interface_ids = [azurerm_network_interface.ta-nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.18.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "ta-resources"
    storage_account_name = "tastorageaccount"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "ta-rg" {
  name     = "ta-resources"
  location = "West Europe"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_storage_account" "ta_storage" {
  name                     = "tastorageaccount"
  resource_group_name      = azurerm_resource_group.ta-rg.name
  location                 = azurerm_resource_group.ta-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.ta_storage.name
  container_access_type = "private"
}
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "ta-vm"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "dev"
  }
}