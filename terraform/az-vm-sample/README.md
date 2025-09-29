# Azure VM Sample - Terraform Configuration

This project creates a Linux virtual machine in Azure using Terraform with automated SSH key generation and comprehensive security configurations.

## 🚀 Features

- **Linux Virtual Machine**: Ubuntu 22.04 LTS by default
- **Automated SSH Key Generation**: Automatically generates and saves SSH keys locally
- **Custom Script Extension**: Automatically executes initialization scripts on VM creation
- **Virtual Network**: Configurable VNet and subnet with custom address spaces
- **Security**: Network Security Group with customizable firewall rules
- **Public IP**: Optional static or dynamic public IP allocation
- **Secure Authentication**: SSH-only authentication (password authentication disabled by default)
- **Flexible Storage**: Configurable OS disk with multiple storage account types
- **Resource Tagging**: Comprehensive tagging system for resource organization
- **Multi-Provider Support**: Includes Azure, AzAPI, and ModTM providers

## 📋 Prerequisites

1. **Azure CLI** installed and configured
2. **Terraform** >= 1.0 installed
3. **Azure Subscription** with appropriate permissions

### Azure CLI Installation and Configuration

```bash
# Install Azure CLI (macOS)
brew install azure-cli

# Install Azure CLI (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Azure CLI (Windows)
# Download from: https://aka.ms/installazurecliwindows

# Login to Azure
az login

# Verify active subscription
az account show

# Set specific subscription (if needed)
az account set --subscription "your-subscription-id"
```

### SSH Key Information

**No manual SSH key generation required!** This configuration automatically:
- Generates a 4096-bit RSA SSH key pair
- Saves the private key to `ssh_keys/{vm_name}_private_key.pem`
- Saves the public key to `ssh_keys/{vm_name}_public_key.pub`
- Configures the VM with the generated public key

### 🔧 Custom Script Extension

La configuración incluye **Custom Script Extension** que ejecuta automáticamente scripts de inicialización cuando se crea la VM:

#### Script Incluido:
- **`scripts/setup.sh`**: Script principal de inicialización que:
  - Actualiza los paquetes del sistema
  - Instala herramientas esenciales (curl, git, docker, etc.)
  - Configura zona horaria y firewall
  - Configura Docker y Docker Compose
  - Crea directorios para aplicaciones

#### Cómo usar Custom Scripts:

1. **Usar el script por defecto** - Funciona inmediatamente con configuración general del sistema
2. **Modificar el script existente** - Edita `scripts/setup.sh` según tus necesidades
3. **Crear tu propio script** - Crea nuevos scripts y actualiza `terraform.tfvars`:
   ```hcl
   script_file_path = "./scripts/mi-script-personalizado.sh"
   script_command = "bash mi-script-personalizado.sh"
   ```
4. **Deshabilitar scripts** - Configura `enable_custom_script = false` en `terraform.tfvars`

#### Ejecución del Script:
- Los scripts se ejecutan como usuario **root** automáticamente
- Timeout de ejecución: 10 minutos por defecto (configurable)
- La salida del script se registra en el portal de Azure bajo VM Extensions
- Los scripts se ejecutan después de que la VM esté completamente aprovisionada

## 🛠️ Usage

### 1. Clone and Navigate

```bash
cd terraform/az-vm-sample
```

### 2. Configure Variables

Create a `terraform.tfvars` file based on the provided example:

```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**Required configuration**:

```hcl
# Azure subscription ID (required)
subscription_id = "your-azure-subscription-id"

# Basic VM configuration
resource_group_name = "rg-my-project"
location           = "East US"
vm_name            = "my-ubuntu-vm"
vm_size            = "Standard_B2s"

# Administrator username
admin_username = "azureuser"
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply changes
terraform apply
```

### 4. Connect to VM

```bash
# Get the public IP address
terraform output public_ip_address

# Use the auto-generated SSH connection command
terraform output ssh_connection_command

# Or connect manually using the generated private key
ssh -i ssh_keys/my-ubuntu-vm_private_key.pem azureuser@<PUBLIC_IP>
```

**Important**: The private key file has restricted permissions (600) for security.

## 📝 Main Variables

| Variable | Description | Default Value | Required |
|----------|-------------|---------------|----------|
| `subscription_id` | Azure Subscription ID | - | ✅ Yes |
| `resource_group_name` | Resource group name | `rg-vm-azure` | No |
| `location` | Azure region | `East US` | No |
| `vm_name` | VM name | `vm-azure` | No |
| `vm_size` | VM size | `Standard_B1s` | No |
| `admin_username` | Administrator username | `azureuser` | No |
| `enable_public_ip` | Create public IP | `true` | No |
| `public_ip_allocation_method` | IP allocation method | `Static` | No |
| `os_disk_storage_account_type` | Storage account type | `Premium_LRS` | No |
| `enable_custom_script` | Enable automatic script execution | `true` | No |
| `script_file_path` | Path to initialization script | `./scripts/setup.sh` | No |
| `script_command` | Command to execute script | `bash setup.sh` | No |
| `script_timeout` | Script execution timeout (seconds) | `600` | No |

### Available VM Sizes

| Size | vCPUs | RAM | Storage | Use Case |
|------|-------|-----|---------|----------|
| `Standard_B1s` | 1 | 1 GB | Economy | Basic workloads |
| `Standard_B2s` | 2 | 4 GB | Economy | Small applications |
| `Standard_D2s_v3` | 2 | 8 GB | General purpose | Balanced workloads |
| `Standard_D4s_v3` | 4 | 16 GB | General purpose | Medium workloads |

## 🔧 Advanced Configurations

### Change Operating System

```hcl
# Red Hat Enterprise Linux 8
source_image_reference = {
  publisher = "RedHat"
  offer     = "RHEL"
  sku       = "8-LVM"
  version   = "latest"
}

# CentOS Stream 8
source_image_reference = {
  publisher = "OpenLogic"
  offer     = "CentOS"
  sku       = "8_5"
  version   = "latest"
}

# Ubuntu 20.04 LTS
source_image_reference = {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-focal"
  sku       = "20_04-lts-gen2"
  version   = "latest"
}
```

### Configure Custom Network Security Rules

```hcl
network_security_group_rules = [
  {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "Custom-Application"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "Database"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.0.0/16"  # Restrict to VNet only
    destination_address_prefix = "*"
  }
]
```

### Configure Network Address Spaces

```hcl
# Custom VNet and subnet configuration
vnet_address_space = ["10.1.0.0/16"]
subnet_address_prefixes = ["10.1.1.0/24"]
```

### Configure Storage Options

```hcl
# Premium SSD (fastest, most expensive)
os_disk_storage_account_type = "Premium_LRS"

# Standard SSD (balanced performance and cost)
os_disk_storage_account_type = "StandardSSD_LRS"

# Standard HDD (cheapest, slower)
os_disk_storage_account_type = "Standard_LRS"
```

### Configure Custom Script Extension

La Custom Script Extension permite configurar automáticamente tu VM durante el despliegue.

#### Configuración Básica (Por defecto)
```hcl
# Usa el script setup.sh incluido
enable_custom_script = true
script_file_path = "./scripts/setup.sh"
script_command = "bash setup.sh"
```

#### Configuración Personalizada
```hcl
# Usar tu propio script personalizado
enable_custom_script = true
script_file_path = "./scripts/mi-configuracion.sh"
script_command = "bash mi-configuracion.sh"
script_timeout = 1200  # 20 minutos para configuraciones complejas
```

#### Deshabilitar Ejecución de Scripts
```hcl
# Deshabilitar ejecución automática de scripts
enable_custom_script = false
```

#### Crear Scripts Personalizados

1. **Crea tu archivo de script** en el directorio `scripts/`:
```bash
#!/bin/bash
# Tus comandos de configuración personalizada aquí
apt-get update
apt-get install -y tu-paquete
# Configurar tu aplicación
```

2. **Actualiza terraform.tfvars**:
```hcl
script_file_path = "./scripts/tu-script.sh"
script_command = "bash tu-script.sh"
```

#### Buenas Prácticas para Scripts
- Siempre comenzar scripts con `#!/bin/bash`
- Usar `set -e` para salir en caso de errores
- Probar scripts manualmente antes de usarlos
- Mantener scripts idempotentes (pueden ejecutarse múltiples veces de forma segura)
- Registrar acciones importantes para resolución de problemas

## 📤 Outputs

After successful deployment, the following outputs are available:

### Basic Information
- `resource_group_name`: Name of the created resource group
- `vm_name`: Name of the virtual machine
- `vm_id`: Azure resource ID of the virtual machine

### Network Information
- `public_ip_address`: Public IP address of the VM (if enabled)
- `private_ip_address`: Private IP address within the VNet
- `network_security_group_id`: ID of the network security group
- `virtual_network_id`: ID of the virtual network
- `subnet_id`: ID of the subnet

### SSH Connection
- `ssh_connection_command`: Ready-to-use SSH command for connecting to the VM
- `ssh_private_key`: Generated SSH private key (marked as sensitive)
- `ssh_public_key`: Generated SSH public key

### Custom Script Extension
- `custom_script_status`: Shows if Custom Script Extension is enabled/disabled
- `script_execution_command`: The command executed by the script extension

### Example Output Usage

```bash
# Get all outputs
terraform output

# Get specific output
terraform output public_ip_address

# Get sensitive output (SSH private key)
terraform output -raw ssh_private_key > my_private_key.pem

# Connect to VM using the provided command
eval "$(terraform output -raw ssh_connection_command)"
```

## 🧹 Cleanup

To remove all created resources and clean up:

```bash
# Destroy all Terraform-managed resources
terraform destroy

# Confirm destruction when prompted
# Type 'yes' to confirm

# Clean up local SSH keys (optional)
rm -rf ssh_keys/
```

**Warning**: This will permanently delete all resources created by this configuration. Make sure you have backed up any important data from the VM before running destroy.

## 📁 Project Structure

```
az-vm-sample/
├── 00.variables.tf          # Variable definitions and validation
├── 01.versions.tf           # Provider requirements and configuration
├── 02.main.tf              # Main resource definitions
├── 99.outputs.tf           # Output value definitions
├── terraform.tfvars.example # Example configuration file
├── terraform.tfvars        # Your configuration (create from example)
├── README.md              # This documentation
└── ssh_keys/              # Auto-generated SSH keys (created during apply)
    ├── {vm_name}_private_key.pem
    └── {vm_name}_public_key.pub
```

## 💡 Examples

### Basic Development Environment

```hcl
# terraform.tfvars
subscription_id = "your-subscription-id"
resource_group_name = "rg-dev-environment"
location = "East US"
vm_name = "dev-ubuntu-vm"
vm_size = "Standard_B2s"
admin_username = "developer"

tags = {
  Environment = "Development"
  Project = "MyApp"
  Owner = "DevTeam"
}
```

### Production Environment with Restricted Access

```hcl
# terraform.tfvars
subscription_id = "your-subscription-id"
resource_group_name = "rg-prod-web-server"
location = "East US"
vm_name = "prod-web-01"
vm_size = "Standard_D4s_v3"
admin_username = "sysadmin"

# Restrict SSH to office IP
network_security_group_rules = [
  {
    name = "SSH-Restricted"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "203.0.113.0/24"  # Your office IP range
    destination_address_prefix = "*"
  }
]

tags = {
  Environment = "Production"
  Project = "WebApp"
  CriticalLevel = "High"
  BackupRequired = "Yes"
}
```

## 🚨 Troubleshooting

### Common Issues

**Error: Insufficient quota**
```bash
# Check your subscription's VM quota
az vm list-usage --location "East US" -o table
```

**Error: SSH connection failed**
```bash
# Check if VM is running
terraform output public_ip_address

# Verify NSG rules allow SSH
az network nsg rule list --resource-group <rg-name> --nsg-name <nsg-name>

# Test SSH key permissions
chmod 600 ssh_keys/*_private_key.pem
```

**Error: Resource group already exists**
```bash
# Use a different resource group name in terraform.tfvars
resource_group_name = "rg-my-unique-name"
```

## 🔐 Security Features

This configuration implements several security best practices:

### Authentication Security
- **SSH-only authentication**: Password authentication is disabled by default
- **Automatic SSH key generation**: 4096-bit RSA keys generated automatically
- **Secure key storage**: Private keys saved with restricted permissions (600)
- **No hardcoded secrets**: All sensitive values handled securely

### Network Security
- **Network Security Groups**: Configurable firewall rules
- **Minimal port exposure**: Only essential ports open by default (SSH: 22, HTTP: 80, HTTPS: 443)
- **Source address restrictions**: Can be configured for specific IP ranges
- **Private networking**: VM deployed in isolated subnet

### Resource Security
- **Resource tagging**: All resources tagged for tracking and management
- **Least privilege**: Only necessary permissions required
- **Secure storage**: Premium storage with encryption support
- **Resource isolation**: Resources deployed in dedicated resource group

### Default Security Rules
- SSH (port 22): Allow from anywhere
- HTTP (port 80): Allow from anywhere  
- HTTPS (port 443): Allow from anywhere

**Recommendation**: Restrict SSH access to specific IP addresses in production environments.

## 📚 Resources Created

This Terraform configuration creates the following Azure resources:

### Core Infrastructure
- **Resource Group**: Container for all resources with consistent tagging
- **Virtual Network (VNet)**: Isolated network environment with configurable address space
- **Subnet**: Network segment within the VNet for VM placement
- **Network Security Group**: Firewall rules for network traffic control

### Virtual Machine Resources
- **Linux Virtual Machine**: Ubuntu 22.04 LTS with configurable sizing
- **Network Interface**: VM's network connection with dynamic private IP
- **OS Disk**: Premium storage disk with configurable caching and type

### Security and Access
- **SSH Key Pair**: Automatically generated 4096-bit RSA keys
- **Public IP**: Optional static IP for internet access
- **Security Associations**: NSG-to-NIC associations for firewall enforcement

### Local Files
- **Private SSH Key**: Saved to `ssh_keys/{vm_name}_private_key.pem`
- **Public SSH Key**: Saved to `ssh_keys/{vm_name}_public_key.pub`

### Provider Dependencies
- **AzureRM Provider**: Main Azure resource management
- **TLS Provider**: SSH key generation
- **Local Provider**: File management for SSH keys
- **Random Provider**: For unique resource naming when needed

## 🤝 Contributing

1. Fork the project
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the license specified in the repository's LICENSE file.