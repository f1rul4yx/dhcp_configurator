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
#verificar root.
function f_root(){
  if [[ $UID -eq 0  ]]; then
    return 0
  else
    echo "No eres administrador"
    exit 0
  fi
}


#verificar dhcp instalado
#si no está instalado devuelve error

function f_dhcp_instalado(){
  paquete=$(dpkg -l | grep isc-dhcp-server)
  if [[ -z $paquete ]]; then
	echo "No está instalado, se instalará"
	apt install isc-dhcp-server -y
  else
	echo "DHCP instalado"
	return 0
  fi
}

#modificar fihcero dhcp con la interfaz. Verifica si interfaz existe.
#si existe la mete en el archivo. sino devuelve error.
function interfaz (){
  fichero_dhcp="/etc/default/isc-dhcp-server"
  read -p "Introduce interfaz: " interfaz

#ver si interfaz existe:

    ip link show "$interfaz" &>/dev/null;
  if [[ $? -eq 0 ]] ; then
#si es valido modificamos archivo dhcp
        sed -i "s/INTERFACESv4=.*/INTERFACESv4=\"$interfaz\"/g" $fichero_dhcp
    return 0
  else
        echo "No existe la interfaz"
    return 1
  fi

}


# Funciones para reiniciar servicio, y verificar estado del servidor dhcp
reiniciar_servicio() {
  systemctl restart isc-dhcp-server
}

verificar_configuracion() {
  dhcpd -t -cf /etc/dhcp/dhcpd.conf
}

verificar_estado_dhcp(){
  systemctl status isc-dhcp-server
}


#menu
function menu(){
f_root
f_dhcp_instalado
interfaz
verificar_configuracion
reiniciar_servicio
verificar_estado_dhcp
        echo "1. Establece pool"
        echo "2. Establece opciones adicionales."
        echo "3. Reiniciar servicio."
        echo "4. Verificar configuracion."
        echo "5. Salir."
  read -p "Elige una opción: " opcion
  case $opcion in
        1)
        establecer_pool
        ;;
        2)
        establecer_pool_plus
        ;;
        3)
        reinciar_servicio
        ;;
        4)
        verificar_configuracion
        ;;
        *)
        exit 0
        ;;
  esac 
}
menu

# Función para establecer el pool del dhcp

establecer_pool(){

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
sudo systemctl restart isc-dhcp-server
return 0

establecer_pool

