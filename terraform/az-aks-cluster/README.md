# Azure AKS Cluster - Terraform Configuration

Este directorio contiene la configuración de Terraform para desplegar un clúster de Azure Kubernetes Service (AKS) básico y económico, optimizado para ambientes de desarrollo y pruebas.

## 🚀 Estado Actual del Proyecto

✅ **CLÚSTER DESPLEGADO Y FUNCIONAL**

### Información del Clúster Actual:
- **Nombre**: `aks-dev-cluster`
- **Resource Group**: `rg-aks-dev-cluster`
- **Ubicación**: `East US`
- **Kubernetes Version**: `1.30.14`
- **FQDN**: `aks-dev-cluster-2522-r69x1dxk.hcp.eastus.azmk8s.io`
- **Nodos**: 1 nodo `Standard_B2s` (2 vCPUs, 4GB RAM)
- **Estado**: **ACTIVO** ✅

## 🏗️ Arquitectura

La configuración despliega los siguientes recursos:

- **Resource Group**: Contenedor lógico para todos los recursos
- **Virtual Network**: Red virtual `10.2.0.0/16` con subnet dedicada `10.2.1.0/24`
- **AKS Cluster**: Clúster de Kubernetes con configuración básica
- **Log Analytics Workspace**: Para monitoreo (opcional - actualmente deshabilitado)
- **Role Assignments**: Permisos necesarios para el funcionamiento del clúster

## 💰 Optimización de Costos

Esta configuración está optimizada para **minimizar costos**:

- **VM Size**: `Standard_B2s` (2 vCPUs, 4GB RAM) - ~$35/mes por nodo
- **Node Count**: 1 nodo inicial (escalable según necesidades)
- **Network Plugin**: `kubenet` (más económico que Azure CNI)
- **Monitoring**: Deshabilitado por defecto (reduce costos)
- **Auto-scaling**: Deshabilitado por defecto
- **Tier**: Free (sin costo adicional por el plano de control)

**Costo estimado mensual actual**: ~$40-50 USD (puede variar según la región)

## 🚀 Gestión del Clúster

### Inicio Rápido (Clúster ya desplegado)

El clúster ya está operativo. Para conectarte:

1. **Configurar kubectl** (si no está configurado):
   ```bash
   az aks get-credentials --resource-group rg-aks-dev-cluster --name aks-dev-cluster
   ```

2. **Verificar conexión**:
   ```bash
   kubectl get nodes
   kubectl get pods --all-namespaces
   ```

### Desplegar desde Cero (si es necesario)

Si necesitas recrear el clúster:

### Prerrequisitos

1. **Azure CLI** instalado y configurado
2. **Terraform** >= 1.0 instalado
3. **kubectl** instalado para gestionar el clúster
4. Subscription de Azure activa

### Pasos de Despliegue

1. **Clonar y navegar al directorio**:
   ```bash
   cd terraform/az-aks-cluster
   ```

2. **Configurar variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Editar terraform.tfvars con tus valores específicos
   ```

3. **Autenticarse en Azure**:
   ```bash
   az login
   az account set --subscription "<your-subscription-id>"
   ```

4. **Inicializar Terraform**:
   ```bash
   terraform init
   ```

5. **Planificar el despliegue**:
   ```bash
   terraform plan
   ```

6. **Aplicar la configuración**:
   ```bash
   terraform apply
   ```

7. **Configurar kubectl**:
   ```bash
   az aks get-credentials --resource-group <resource-group-name> --name <cluster-name>
   ```

8. **Verificar el clúster**:
   ```bash
   kubectl get nodes
   kubectl get pods --all-namespaces
   ```

## 📁 Estructura de Archivos

```
az-aks-cluster/
├── 00.variables.tf          # Definición de variables
├── 01.versions.tf           # Versiones de Terraform y providers
├── 02.main.tf              # Recursos principales
├── 99.outputs.tf           # Outputs del despliegue
├── terraform.tfvars        # Configuración actual del proyecto
├── terraform.tfvars.example # Ejemplo de configuración
├── config_nogit/           # 📂 Configuraciones extraídas (no versionadas)
│   └── kubeconfig.yaml     # Configuración de kubectl
└── README.md               # Este archivo
```

## 📤 Outputs y Configuración del Clúster

### Ver Todos los Outputs
```bash
terraform output
```

### Extraer Configuración de kubectl
```bash
# Método 1: Usando terraform output (recomendado)
terraform output -raw kube_config > config_nogit/kubeconfig.yaml

# Método 2: Usando Azure CLI
az aks get-credentials --resource-group rg-aks-dev-cluster --name aks-dev-cluster --file config_nogit/kubeconfig-az.yaml

# Método 3: Configurar kubectl directamente (configuración actual)
az aks get-credentials --resource-group rg-aks-dev-cluster --name aks-dev-cluster --overwrite-existing
```

### Outputs Principales Disponibles
- **cluster_fqdn**: FQDN del clúster AKS
- **cluster_id**: ID completo del clúster
- **kubectl_connection_command**: Comando para configurar kubectl
- **kube_config**: Configuración completa de kubectl (sensible)
- **kubernetes_version**: Versión de Kubernetes desplegada
- **network_profile**: Configuración de red del clúster
- **node_resource_group**: Grupo de recursos de los nodos

### Verificar Estado del Clúster
```bash
# Configurar kubectl (si no está configurado)
az aks get-credentials --resource-group rg-aks-dev-cluster --name aks-dev-cluster

# Verificar nodos
kubectl get nodes

# Verificar pods del sistema
kubectl get pods --all-namespaces

# Información del clúster
kubectl cluster-info

# Ver recursos del clúster
kubectl get all --all-namespaces
```

## ⚙️ Variables Principales

| Variable | Descripción | Valor por Defecto | Requerida |
|----------|-------------|-------------------|-----------|
| `subscription_id` | ID de subscription de Azure | - | ✅ |
| `resource_group_name` | Nombre del resource group | `rg-aks-cluster` | ❌ |
| `location` | Región de Azure | `East US` | ❌ |
| `cluster_name` | Nombre del clúster AKS | `aks-cluster` | ❌ |
| `node_count` | Número inicial de nodos | `1` | ❌ |
| `node_vm_size` | Tamaño de VM para nodos | `Standard_B2s` | ❌ |
| `enable_auto_scaling` | Habilitar auto-escalado | `false` | ❌ |

## 📤 Outputs Importantes

Después del despliegue, obtienes:

- **kubectl_connection_command**: Comando para configurar kubectl
- **cluster_fqdn**: FQDN del clúster
- **cluster_id**: ID del clúster AKS
- **kube_config**: Configuración de kubectl (sensible)

## 🔧 Gestión de Configuraciones

### Extraer y Guardar Configuraciones

```bash
# Crear directorio para configuraciones (si no existe)
mkdir -p config_nogit

# Extraer kubeconfig usando terraform
terraform output -raw kube_config > config_nogit/kubeconfig.yaml

# Extraer kubeconfig usando Azure CLI
az aks get-credentials --resource-group rg-aks-dev-cluster --name aks-dev-cluster --file config_nogit/kubeconfig-az.yaml

# Extraer todos los outputs a un archivo
terraform output > config_nogit/terraform-outputs.txt

# Usar kubeconfig específico
export KUBECONFIG=$(pwd)/config_nogit/kubeconfig.yaml
kubectl get nodes
```

### Backup de la Configuración del Clúster

```bash
# Exportar configuración completa del clúster
kubectl get all --all-namespaces -o yaml > config_nogit/cluster-backup.yaml

# Exportar solo configuraciones importantes
kubectl get configmaps --all-namespaces -o yaml > config_nogit/configmaps-backup.yaml
kubectl get secrets --all-namespaces -o yaml > config_nogit/secrets-backup.yaml

# Información del clúster en formato JSON
az aks show --resource-group rg-aks-dev-cluster --name aks-dev-cluster > config_nogit/cluster-info.json
```

## 🔧 Personalización

### Escalar el Clúster

```bash
# Escalar nodos usando Azure CLI
az aks scale --resource-group rg-aks-dev-cluster --name aks-dev-cluster --node-count 2

# O modificar terraform.tfvars y aplicar
# node_count = 2
terraform plan
terraform apply
```

### Habilitar Monitoreo

```hcl
# En terraform.tfvars
enable_oms_agent = true
```

### Habilitar Auto-escalado

```hcl
# En terraform.tfvars
enable_auto_scaling = true
min_count = 1
max_count = 5
```

### Cambiar Tamaño de Nodos

⚠️ **Nota**: Cambiar el tamaño de VM requiere recrear el pool de nodos

```hcl
# En terraform.tfvars
node_vm_size = "Standard_D2s_v3"  # Más potente pero más caro
```

## 🧹 Gestión del Ciclo de Vida

### Detener el Clúster (para ahorrar costos)
```bash
# AKS no se puede "pausar", pero puedes escalar a 0 nodos
az aks scale --resource-group rg-aks-dev-cluster --name aks-dev-cluster --node-count 0

# O usar terraform
# Cambiar node_count = 0 en terraform.tfvars
terraform apply
```

### Reiniciar el Clúster
```bash
# Escalar de vuelta a 1 nodo
az aks scale --resource-group rg-aks-dev-cluster --name aks-dev-cluster --node-count 1
```

### Destruir Completamente
```bash
# ⚠️ CUIDADO: Esto eliminará todo el clúster y datos
terraform destroy
```

### Actualizar Kubernetes
```bash
# Ver versiones disponibles
az aks get-upgrades --resource-group rg-aks-dev-cluster --name aks-dev-cluster

# Actualizar (ejemplo a versión 1.31.1)
az aks upgrade --resource-group rg-aks-dev-cluster --name aks-dev-cluster --kubernetes-version 1.31.1
```

## 🔍 Solución de Problemas

### Error de Permisos
```bash
# Verificar permisos de subscription
az account show
az role assignment list --assignee $(az account show --query user.name -o tsv)
```

### Error de Conexión kubectl
```bash
# Reconfigurar credenciales
az aks get-credentials --resource-group <rg-name> --name <cluster-name> --overwrite-existing
```

### Verificar Estado del Clúster
```bash
# Ver estado de nodos
kubectl get nodes -o wide

# Ver pods del sistema
kubectl get pods -n kube-system

# Ver eventos del clúster
kubectl get events --sort-by=.metadata.creationTimestamp
```

## 📚 Recursos Adicionales

- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 🏷️ Tags

Los recursos se etiquetan automáticamente con:
- Environment: Development
- Project: AKS-Cluster
- Owner: DevOps

Puedes personalizar estos tags en el archivo `terraform.tfvars`.