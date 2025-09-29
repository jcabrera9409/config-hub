output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.id
}

output "public_ip_address" {
  description = "Public IP address of the VM"
  value       = var.enable_public_ip ? azurerm_public_ip.main[0].ip_address : null
}

output "private_ip_address" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.main.private_ip_address
}

output "ssh_connection_command" {
  description = "SSH command to connect to the VM"
  value = var.enable_public_ip ? (
    "ssh -i ssh_keys/${var.vm_name}_private_key.pem ${var.admin_username}@${azurerm_public_ip.main[0].ip_address}"
  ) : "Public IP not enabled - use private IP for connection"
}

output "network_security_group_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.main.id
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = azurerm_subnet.main.id
}

output "ssh_private_key" {
  description = "Generated SSH private key for VM access"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "ssh_public_key" {
  description = "Generated SSH public key for VM access"
  value       = tls_private_key.ssh_key.public_key_openssh
}

output "custom_script_status" {
  description = "Status of the custom script extension"
  value       = var.enable_custom_script ? "Enabled - Script will execute on VM creation" : "Disabled"
}

output "script_execution_command" {
  description = "Command executed by the custom script extension"
  value       = var.enable_custom_script ? var.script_command : null
}