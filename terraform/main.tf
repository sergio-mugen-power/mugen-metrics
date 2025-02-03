provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "TFM-ResourceGroup"
  location = "Sweden Central"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "TFM-VNet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "TFM-Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "TFM-PublicIP"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "TFM-NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "TFM-IPConfig"
    subnet_id                     = azurerm_subnet.subnet.id
    public_ip_address_id          = azurerm_public_ip.public_ip.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "TFM-VM-Docker"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "sergio"
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "sergio"
    public_key = file("~/.ssh/id_rsa.pub") # Reemplaza con la ruta correcta si es diferente
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker sergio
    mkdir -p /home/TFM
  EOF
  )
}

# Comando local para copiar el directorio TFM a la nueva VM
resource "null_resource" "copy_files" {
  depends_on = [azurerm_linux_virtual_machine.vm]

  provisioner "local-exec" {
    command = <<EOT
      sleep 30  # Espera que la VM esté lista
      scp -r -o StrictHostKeyChecking=no /home/sergio/TFM sergio@${azurerm_public_ip.public_ip.ip_address}:/home/TFM
    EOT
  }
}
