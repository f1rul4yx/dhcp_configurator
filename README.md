# DHCP Configurator

Este es un script que permite automatizar la instalación y configuración del servicio DHCP.

## Funciones

### verificar_root()

- Verifica si el script se está ejecutando con privilegios de superusuario (root). Si no, el script debe salir con un mensaje de error.

### verificar_dhcp_instalado()

- Comprueba si el paquete `isc-dhcp-server` está instalado. Si no lo está, lo instalará.

### establecer_interfaz()

- Configura la interfaz seleccionada en el archivo de configuración del servidor DHCP (`/etc/default/isc-dhcp-server` o similar).

### validar_ip()

- Verifica que las direcciones IP introducidas por el usuario sean válidas.

### establecer_pool()

- Permite al usuario ingresar la dirección de red, la máscara de red, un rango de direcciones IP (inicio y fin), la gateway, y luego configura esos valores en el archivo de configuración del servidor (probablemente `/etc/dhcp/dhcpd.conf`).

### reiniciar_servicio()

- Reinicia el servicio del servidor DHCP después de realizar la configuración para aplicar los cambios.

### verificar_configuracion()

- Verifica que la configuración del servidor DHCP esté correcta antes de reiniciar el servicio, para evitar errores en la configuración.

### verificar_estado_dhcp()

- Verifica si el servicio de `isc-dhcp-server` está activo y corriendo correctamente.

### menu()

- Muestra un menú interactivo para que el usuario pueda elegir las opciones de configuración (por ejemplo, seleccionar la interfaz de red, definir el pool, opciones adicionales, etc.).

### main()

- Ejecuta todas las funciones en el orden adecuado. Primero verifica si es root, luego instala el servidor DHCP si es necesario, obtiene la interfaz de red, genera la configuración, y finalmente reinicia el servicio.
