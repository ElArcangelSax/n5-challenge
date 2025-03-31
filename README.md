# n5-challenge
# Despliegue de Aplicación en AKS con Terraform, Helmfile y GitHub Actions

## 📌 Descripción
Este proyecto automatiza el despliegue de una aplicación en Azure Kubernetes Service (AKS) usando:
- Terraform para infraestructura (AKS, ACR, Key Vault)
- Helmfile para gestionar releases de Helm (dev/stage)
- GitHub Actions para CI/CD
- SOPS + Azure Key Vault para gestión segura de secrets

## 🚀 Requisitos Previos
- Cuenta de Azure con suscripción activa
- Azure CLI instalado (`az login`)
- Terraform v1.5+
- Helm y Helmfile instalados
- GitHub Repository con secrets configurados

## 🛠 Estructura del Proyecto
.
├── n5-infrastructure/ # Infraestructura como código 
│ ├── main.tf # Recursos de Azure (AKS, ACR, Key Vault)
│ └── variables.tf
├── n5-docker/ # Dockerización
│ ├── Dockerfile # Imagen personalizada
│ └── index.html # Contenido estático
├── n5-apps/ # Configuración de Helm
│ ├── helmfile.yaml # Entornos multi-stage
│ ├── charts/ # Helm charts
│ └── environments/ # Values y secrets por entorno
└── .github/workflows/ # Automatización CI/CD
└── deploy.yml


## 🔐 Configuración Inicial

### 1. Azure Service Principal para GitHub Actions
```bash
az ad sp create-for-rbac \
  --name "github-actions-sp" \
  --role contributor \
  --scopes /subscriptions/<AZURE_SUBSCRIPTION_ID> \
  --sdk-auth > azure-creds.json

```
### 2. Clave SOPS en Azure Key Vault
```bash
az keyvault key create \
  --name "sops-key" \
  --vault-name "helloapp-secrets" \
  --kty RSA \
  --size 2048 \
  --ops encrypt decrypt
```

⚙️ Despliegue Manual
### 1. Infraestructura con Terraform
``` bash
cd terraform
terraform init
terraform apply -auto-approve
```

### 2. Construir y Publicar Imagen
``` bash 
az acr build \
  --registry helloappacr \
  --image hello-app:latest \
  --file ../docker/Dockerfile ../docker
```


### 3. Desplegar con Helmfile
``` bash
cd ../n5-apps
helmfile -e dev apply  # Ambiente DEV
helmfile -e stage apply  # Ambiente STAGE
```

🔄 Automatización con GitHub Actions

El workflow .github/workflows/deploy.yml ejecuta:

1. Build de la imagen en ACR.

2. Despliegue en AKS usando Helmfile.

3. Gestión de secrets con SOPS + Key Vault.


## 🔐 Secrets Requeridos en GitHub

| Secret                | Descripción                             | 
|-----------------------|-----------------------------------------|
| `AZURE_CREDENTIALS`   | Credenciales del Service Principal      |
| `AZURE_CLIENT_ID`     | Client ID para autenticación con Azure  |
| `AZURE_CLIENT_SECRET` | Client Secret para SOPS/Key Vault       |

## 🚀 Despliegue Automatizado
1. **Infraestructura**:
   ```bash
   cd n5-infrastructure && terraform apply
```

🌐 Acceso a la Aplicación

kubectl port-forward svc/hello-app-dev 8080:80 -n dev

Abrir: http://localhost:8080 (para poder probar)

