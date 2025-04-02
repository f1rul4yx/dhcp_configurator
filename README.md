# DHCP Configurator

Este es un script que permite automatizar la instalación y configuración del servicio DHCP.

## Funciones

### verificar_root()

- Verifica si el script se está ejecutando con privilegios de superusuario (root). Si no, el script debe salir con un mensaje de error.

### verificar_dhcp_instalado()

- Comprueba si el paquete `isc-dhcp-server` está instalado. Si no lo está, lo instalará.

### instalar_dhcp()

- Si `verificar_dhcp_instalado()` detecta que no está instalado, esta función instalará el servidor DHCP.

### obtener_interfaz()

- Muestra un listado de las interfaces de red disponibles y permite al usuario seleccionar cuál utilizar para el servidor DHCP.

### establecer_interfaz()

- Configura la interfaz seleccionada en el archivo de configuración del servidor DHCP (`/etc/default/isc-dhcp-server` o similar).

### establecer_pool()

- Permite al usuario ingresar un rango de direcciones IP (inicio y fin), la máscara de red, y la duración del arrendamiento, luego configura esos valores en el archivo de configuración del servidor (probablemente `/etc/dhcp/dhcpd.conf`).

### establecer_pool_plus()

- Permite definir opciones adicionales del servidor DHCP como la puerta de enlace predeterminada, el servidor DNS, el dominio, etc.

### reiniciar_servicio()

- Reinicia el servicio del servidor DHCP después de realizar la configuración para aplicar los cambios.

### verificar_configuracion()

- Verifica que la configuración del servidor DHCP esté correcta antes de reiniciar el servicio, para evitar errores en la configuración.

### menu()

- Muestra un menú interactivo para que el usuario pueda elegir las opciones de configuración (por ejemplo, seleccionar la interfaz de red, definir el pool, opciones adicionales, etc.).

### main()

- Ejecuta todas las funciones en el orden adecuado. Primero verifica si es root, luego instala el servidor DHCP si es necesario, obtiene la interfaz de red, genera la configuración, y finalmente reinicia el servicio.

## Posibles funciones

### respaldo_configuracion()

- Antes de realizar cambios importantes en la configuración, realiza un respaldo de los archivos de configuración actuales.

### verificar_estado_dhcp()

- Verifica si el servicio de `isc-dhcp-server` está activo y corriendo correctamente.

### validar_ip()

- Verifica que las direcciones IP introducidas por el usuario sean válidas.
