#!/bin/bash

# Script para crear estructura de carpetas para despliegue multi-entorno con Terraform + Helmfile

create_structure() {
  # Directorio raíz
  local BASE_DIR="${1:-.}"

  # Crear estructura principal
  mkdir -p "${BASE_DIR}/infra"
  mkdir -p "${BASE_DIR}/apps/environments/dev"
  mkdir -p "${BASE_DIR}/apps/environments/stage"
  mkdir -p "${BASE_DIR}/apps/charts/hello-app/templates"
  mkdir -p "${BASE_DIR}/docker"

  # Crear archivos base vacíos
  touch "${BASE_DIR}/infra/main.tf"
  touch "${BASE_DIR}/infra/variables.tf"
  touch "${BASE_DIR}/infra/outputs.tf"
  
  # Crear archivos de configuración de Helm
  touch "${BASE_DIR}/apps/helmfile.yaml"
  touch "${BASE_DIR}/apps/environments/dev/values.yaml"
  touch "${BASE_DIR}/apps/environments/dev/secrets.yaml.enc"
  touch "${BASE_DIR}/apps/environments/stage/values.yaml"
  touch "${BASE_DIR}/apps/environments/stage/secrets.yaml.enc"
  
  # Crear estructura del chart
  touch "${BASE_DIR}/apps/charts/hello-app/Chart.yaml"
  touch "${BASE_DIR}/apps/charts/hello-app/values.yaml"
  touch "${BASE_DIR}/apps/charts/hello-app/templates/deployment.yaml"
  touch "${BASE_DIR}/apps/charts/hello-app/templates/secret.yaml"
  
  # Docker
  touch "${BASE_DIR}/docker/Dockerfile"
  touch "${BASE_DIR}/docker/index.html"

  echo "Estructura creada en: ${BASE_DIR}"
}

# Ejecutar creación
create_structure "$@"

# Dar permisos de ejecución al script (solo si lo guardas como archivo)
#chmod +x creae.sh
