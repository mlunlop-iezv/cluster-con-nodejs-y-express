#!/bin/bash

# --- 1. Instalación de paquetes básicos y Node.js ---
echo "Actualizando e instalando dependencias -------------------------------------------"
apt-get update
apt-get install -y curl git build-essential

echo "Instalando Node.js (Versión 18.x LTS) -------------------------------------------"
# Usamos el script oficial de NodeSource
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# --- 2. Instalación de Herramientas Globales ---
echo "Instalando PM2 y Loadtest globalmente -------------------------------------------"
npm install -g pm2 loadtest express-generator

# --- 3. Preparación del Directorio de la App ---
echo "Configurando directorio /var/www/node_app -------------------------------------------"
mkdir -p /var/www/node_app

# Asignamos permisos al usuario 'vagrant'
chown -R vagrant:vagrant /var/www/node_app
chmod -R 775 /var/www/node_app

# Iniciamos el proyecto NPM si no existe
cd /var/www/node_app
if [ ! -f package.json ]; then
    echo "Inicializando proyecto Node..."
    npm init -y
    echo "Instalando Express..."
    npm install express
fi

echo "¡Entorno Node.js listo! -----------------------------------------------------------"