# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
   address_space = ["10.0.0.0/16"]
}

#Subnet
resource "azurerm_subnet" "subnet" {
    name = var.subnet_name
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.1.0/24"]
}

#public IP
resource "azurerm_public_ip" "publicip" {
    name = "${var.vm_name}-publicip"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Static"
}

#Network Interface
resource "azurerm_network_interface" "nic" {
    name = "${var.vm_name}-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name = "${var.vm_name}-ipconfig"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.publicip.id
    }
}
#Network Security Group
resource "azurerm_network_security_group" "nsg" {
    name = "${var.vm_name}-nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    security_rule {
        name = "SSH"
        priority = 1001
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
    network_interface_id = azurerm_network_interface.nic.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" { 
    name = var.vm_name
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    size = "Standard_D2alds_v6"
    admin_username = var.admin_username
    # admin_password = var.admin_password
    admin_ssh_key {
  username   = var.admin_username
  public_key = file(var.ssh_public_key)
}
    network_interface_ids = [azurerm_network_interface.nic.id]
    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-jammy"
        sku = "22_04-lts-gen2"
        version = "latest"
    }
}