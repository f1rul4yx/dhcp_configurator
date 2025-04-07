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
    apt install isc-dhcp-server -y &>/dev/null
    if [[ $? -eq 0 ]]; then
      echo -e "${VERDE}Se instalo correctamente.${RESET}"
      return 0
    else
      echo -e "${ROJO}Hubo algún problema con la instalación!!!${RESET}"
      return 1
    fi
  else
    return 0
  fi
}

# Pide al usuario la interfaz en la que va a escuchar el servidor DHCP
function establecer_interfaz() {
  fichero_dhcp="/etc/default/isc-dhcp-server"
  read -p "Introduce la interfaz: " interfaz
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
  read -p "Ingresa la dirección de red: " direccion_red
  read -p "Ingresa la máscara de red: " mascara_red
  read -p "Ingresa el primer valor del rango de direcciones: " ip_inicio
  read -p "Ingresa el último valor del rando de direcciones: " ip_final
  read -p "Ingresa la puerta de enlace: " puerta_enlace
  fichero_conf="/etc/dhcp/dhcpd.conf"
  {
    echo "subnet $direccion_red netmask $mascara_red {"
    echo "  range $ip_inicio $ip_final;"
    echo "  option routers $puerta_enlace;"
    echo "}"
  } >> $fichero_conf
  if [[ $? -eq 0 ]]; then
    echo -e "${VERDE}La configuración del pool se ha guardado correctamente en $fichero_conf${RESET}"
    return 0
  else
    echo -e "${ROJO}Hubo algún problema!!!${RESET}"
    return 1
  fi
}

# Verifica que el archivo de configuración esté correctamente definido
function verificar_configuracion() {
  dhcpd -t -cf /etc/dhcp/dhcpd.conf &>/dev/null
  if [[ $? -eq 0 ]]; then
    echo -e "${VERDE}El archivo /etc/dhcp/dhcpd.conf está correctamente configurado.${RESET}"
    return 0
  else
    echo -e "${ROJO}Hay un problema en el archivo de configuración /etc/dhcp/dhcpd.conf!!!${RESET}"
    return 1
  fi
}

# Reinicia el servicio DHCP
function reiniciar_servicio() {
  systemctl restart isc-dhcp-server $>/dev/null
  if [[ $? -eq 0 ]]; then
    echo -e "${VERDE}El servicio se reinicio con exito.${RESET}"
    return 0
  else
    echo -e "${ROJO}Hubo algún problema al reiniciar el servicio!!!${RESET}"
    return 1
  fi
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
  echo "5. Ver estado del servicio"
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
  while [[ $opcion != 6 ]]; do
    menu
  done
}