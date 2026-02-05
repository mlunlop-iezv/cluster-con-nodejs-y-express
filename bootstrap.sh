#!/bin/bash

# --- 1. Instalación de paquetes y dependencias ---
echo "Actualizando e instalando Python, Pip y Nginx -------------------------------------------"
apt-get update
apt-get install -y python3-pip python3-dev nginx git

echo "Instalando Pipenv y Dotenv -------------------------------------------"
pip3 install pipenv python-dotenv

# --- 2. Preparación del Directorio de la App ---
echo "Configurando directorio /var/www/app -------------------------------------------"
# Es vital crear la carpeta antes de cambiar permisos
mkdir -p /var/www/app

# Asignamos el dueño 'vagrant' (para que puedas editar) y grupo 'www-data' (para Nginx)
chown -R vagrant:www-data /var/www/app
chmod -R 775 /var/www/app

# --- 3. Creación de Archivos de la Aplicación (PoC) ---
echo "Generando archivos de código Python (PoC) -------------------------------------------"

# Creamos application.py
cat <<EOF > /var/www/app/application.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def index():
    return '<h1>App desplegada</h1>'
EOF

# Creamos wsgi.py (Punto de entrada)
cat <<EOF > /var/www/app/wsgi.py
from application import app

if __name__ == '__main__':
   app.run(debug=False)
EOF

# Creamos el archivo de variables de entorno .env
echo "FLASK_APP=wsgi.py" > /var/www/app/.env
echo "FLASK_ENV=production" >> /var/www/app/.env

# --- 4. Instalación del Entorno Virtual ---
echo "Instalando Flask y Gunicorn en entorno virtual -------------------------------------------"
# Ejecutamos como usuario 'vagrant' para que el entorno virtual le pertenezca a él
su - vagrant -c "cd /var/www/app && pipenv install flask gunicorn"

# --- 5. Configuración del Servicio Systemd (Gunicorn) ---
echo "Creando servicio systemd para Gunicorn -------------------------------------------"
# Creamos el archivo de servicio que conecta el socket
cat <<EOF > /etc/systemd/system/flask_app.service
[Unit]
Description=flask app service - App con flask y Gunicorn
After=network.target

[Service]
User=vagrant
Group=www-data
WorkingDirectory=/var/www/app
Environment="PATH=/usr/local/bin"
# Usamos 'pipenv run' para usar las librerías del entorno virtual automáticamente
ExecStart=/usr/local/bin/pipenv run gunicorn --workers 3 --bind unix:/var/www/app/app.sock wsgi:app

[Install]
WantedBy=multi-user.target
EOF

# Recargamos demonios y arrancamos el servicio
systemctl daemon-reload
systemctl start flask_app
systemctl enable flask_app

# --- 6. Configuración de Nginx ---
echo "Configurando Proxy Inverso Nginx -------------------------------------------"
cat <<EOF > /etc/nginx/sites-available/app.conf
server {
  listen 80;
  server_name app.izv www.app.izv 192.168.56.8;

  access_log /var/log/nginx/app.access.log;
  error_log /var/log/nginx/app.error.log;

  location / {
    include proxy_params;
    # Redirigimos al socket creado por Gunicorn
    proxy_pass http://unix:/var/www/app/app.sock;
  }
}
EOF

# Enlace simbólico y limpieza de default
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/
systemctl restart nginx