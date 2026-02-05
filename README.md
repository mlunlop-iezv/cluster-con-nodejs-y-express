# Práctica: Despliegue de Aplicaciones en "Cluster" con NodeJS y Express

> Mario Luna López 2ºDAW_B

**Repositorio:** *[github.com/mlunlop-iezv/cluster-con-nodejs-y-express](https://github.com/mlunlop-iezv/cluster-con-nodejs-y-express)*

---

## 1. Introducción y Preparación del Entorno

El objetivo principal es abordar una de las características fundamentales de Node.js: su arquitectura Single-Threaded (un solo hilo). Por defecto, una instancia de Node.js se ejecuta en un solo núcleo de la CPU. En servidores modernos multinúcleo, esto supone un desperdicio de recursos y un cuello de botella, ya que una tarea pesada puede bloquear el servidor para todos los usuarios.

Para solucionar esto, implementaremos técnicas de Clustering (agrupación de procesos) para distribuir la carga de trabajo entre todos los núcleos disponibles

* ### Adaptación de la Infraestructura como Código

  Para automatizar el despliegue de este nuevo stack tecnológico, he modificado los archivos de configuración de Vagrant respecto a la práctica anterior.

  * ###  A. Modificación del Vagrantfile
    La aplicación Express que vamos a desarrollar escucha por defecto en el puerto 3000. Hemos actualizado la configuración de red de la máquina virtual para exponer este puerto en lugar del 5000 (Flask).

    ```bash
     # Redirección de puertos para Node.js
     config.vm.network "forwarded_port", guest: 3000, host: 3000
    ```

  * ### B. Reescritura del bootstrap.sh

    El script de aprovisionamiento ha sido reescrito totalmente.

    Las herramientas clave instaladas son:

    * Node.js (v18.x LTS): Entorno de ejecución para JavaScript en el servidor.
    * PM2 (Process Manager 2): Un gestor de procesos de producción que utilizaremos en la segunda parte de la práctica. PM2 incluye un balanceador de carga integrado que nos permitirá gestionar el clúster automáticamente sin modificar el código de la aplicación.
    * Loadtest: Herramienta para realizar pruebas de estrés y carga HTTP. La usaremos para medir la latencia y las peticiones por segundo (RPS) y comparar el rendimiento "Con Cluster" vs "Sin Cluster".

    ```bash
    # Fragmento del nuevo bootstrap.sh
    echo "Instalando herramientas globales de Node..."
    # pm2: Para gestión de clusters en producción
    # loadtest: Para pruebas de estrés
    npm install -g pm2 loadtest express-generator
    ```

    Además, el script prepara automáticamente el directorio /var/www/node_app, asignando los permisos al usuario vagrant e inicializando un proyecto npm básico si no existe, para que al entrar por SSH todo esté listo para trabajar.