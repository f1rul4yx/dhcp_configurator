#!/usr/bin/env bash

#Author: Marina Gracia, Sergio Roales, Javier Begines, Diego Vargas
#Date created: 02 abr 2025
#Version: 1.0

#--------------------VARIABLES--------------------#

# COLORES

# Resetear todos los atributos
RESET="\e[0m"

# Estilos
NEGRITA="\e[1m"
ATENUADO="\e[2m"
CURSIVA="\e[3m"
SUBRAYADO="\e[4m"
PARPADEO="\e[5m"
PARPADEO_INTENSO="\e[6m"
INVERTIDO="\e[7m"
OCULTO="\e[8m"
TACHADO="\e[9m"

# Colores de texto
NEGRO="\e[30m"
ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
AZUL="\e[34m"
MORADO="\e[35m"
CIAN="\e[36m"
GRIS="\e[37m"
BLANCO="\e[38m"

# Colores de fondo
FONDO_NEGRO="\e[40m"
FONDO_ROJO="\e[41m"
FONDO_VERDE="\e[42m"
FONDO_AMARILLO="\e[43m"
FONDO_AZUL="\e[44m"
FONDO_MORADO="\e[45m"
FONDO_CIAN="\e[46m"
FONDO_GRIS="\e[47m"
FONDO_BLANCO="\e[48m"

#--------------------FUNCIONES--------------------#

# Verifica que el usuario ejecute el script como root
function verificar_root() {
  if [[ $UID -eq 0 ]]; then
    return 0
  else
    echo -e "${ROJO}Debes ejecutar el script como root!!!${RESET}"
    exit 0
  fi
}

# Verifica si está instalado el paquete y si no lo está se instala
function verificar_dhcp_instalado() {
  paquete=$(dpkg -l | grep isc-dhcp-server)
  if [[ -z $paquete ]]; then
    echo -e "${ROJO}El paquete isc-dhcp-server no está instalado, se instalará a continuación!!!${RESET}"
    echo -e "${SUBRAYADO}Pulsa una tecla para continuar...${RESET}"
    read
    apt install isc-dhcp-server -y
  else
    return 0
  fi
}

# Pide al usuario la interfaz en la que va a escuchar el servidor DHCP
function establecer_interfaz() {
  fichero_dhcp="/etc/default/isc-dhcp-server"
  read -p "Introduce interfaz: " interfaz
  ip link show "$interfaz" &>/dev/null
  if [[ $? -eq 0 ]]; then
    sed -i "s/INTERFACESv4=.*/INTERFACESv4=\"$interfaz\"/g" $fichero_dhcp
    return 0
  else
    echo -e "${ROJO}La interfaz introducida no existe!!!${RESET}"
    return 1
  fi
}

# Establece la configuración del DHCP
function establecer_pool() {
  read -p "Ingresa un rango de direcciones IP (inicio: XXX.XX.X.XXX fin: XXX.XX.X.XXX): " ip_ini ip_fin
  read -p "Ingresa la máscara de red: " mask
  conf_serv="/etc/dhcp/dhcpd.conf"
  gateway=ip route | grep default | awk {'print $3'}
  direccion_red=ip route | grep 0.0 | awk -F '/' {'print $1'}
  if ! [[ $ip_ini =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || ! [[ $ip_fin =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Las direcciones IP no son válidas."
    return 1
  fi
  if ! [[ $mask =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: La máscara de red no es válida."
    return 1
  fi
  {
    echo "subnet $direccion_red netmask $mask {"
    echo "    range $ip_ini $ip_fin;"
    echo "    option routers $gateway;"
    echo "}"
  } >> $conf_serv
  echo "La configuración del pool se ha guardado correctamente en $conf_serv"
  return 0
}

# Reinicia el servicio DHCP
function reiniciar_servicio() {
  systemctl restart isc-dhcp-server
}

### VERIFICAR ###
# Verifica que el archivo de configuración esté correctamente definido
function verificar_configuracion() {
  dhcpd -t -cf /etc/dhcp/dhcpd.conf
}

# Verifica el estado del servicio
function verificar_estado_dhcp() {
  systemctl status isc-dhcp-server
}

# Menu para el programa final
function menu() {
  echo "1. Establecer interfaz"
  echo "2. Establecer pool"
  echo "3. Verificar configuración"
  echo "4. Reiniciar servicio"
  echo "5. Verificar estado del servicio"
  echo "6. Salir"
  read -p "Elige una opción: " opcion
  case $opcion in
    1)
      establecer_interfaz
    ;;
    2)
      establecer_pool
    ;;
    3)
      verificar_configuracion
    ;;
    4)
      reiniciar_servicio
    ;;
    5)
      verificar_estado_dhcp
    ;;
    *)
      exit 0
    ;;
  esac
}

# Programa final estructurado
function main() {
  verificar_root
  verificar_dhcp_instalado
  menu
}