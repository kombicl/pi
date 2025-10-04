#!/bin/bash

# Demo del instalador (sin ejecutar comandos reales)
# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${GREEN}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${YELLOW}Pi-hole + Cloudflared Installer${NC}          ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${CYAN}Script creado por Kombi${NC}                   ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════╝${NC}\n"

# Función para preguntar confirmación
confirm_step() {
    while true; do
        read -p "$1 (s/N): " yn
        case $yn in
            [Ss]* ) return 0;;
            [Nn]* | "" ) echo -e "${YELLOW}Paso omitido${NC}"; return 1;;
            * ) echo -e "${RED}Por favor responde s (sí) o n (no)${NC}";;
        esac
    done
}

echo -e "${BLUE}[MODO DEMO - No se ejecutarán comandos reales]${NC}\n"

# Simular actualización
echo -e "${YELLOW}[1/6] Actualizar el sistema${NC}"
if ! confirm_step "¿Deseas actualizar el sistema (apt update && upgrade)?"; then
    echo ""
else
    echo "Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease"
    echo "Get:2 http://security.ubuntu.com/ubuntu jammy-security InRelease [110 kB]"
    echo "Fetched 8,234 kB in 2s (4,117 kB/s)"
    echo "Reading package lists... Done"
    sleep 1
    echo -e "${GREEN}Sistema actualizado correctamente${NC}"
fi

# Simular instalación de Docker
echo -e "\n${YELLOW}[2/6] Instalar Docker${NC}"
if ! confirm_step "¿Deseas instalar Docker?"; then
    echo -e "${BLUE}[DEMO] Docker es necesario, continuando de todas formas...${NC}"
else
    echo -e "${YELLOW}Docker no está instalado${NC}"
    echo "# Executing docker install script..."
    echo "+ sh -c apt-get update -qq >/dev/null"
    echo "+ sh -c DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker-ce docker-ce-cli containerd.io"
    sleep 1
    echo -e "${GREEN}Docker instalado correctamente${NC}"
    echo "Docker version 24.0.7, build afdd53b"
fi

# Simular instalación de Docker Compose
echo -e "\n${YELLOW}[3/6] Instalar Docker Compose${NC}"
if ! confirm_step "¿Deseas instalar Docker Compose?"; then
    echo -e "${BLUE}[DEMO] Docker Compose es necesario, continuando de todas formas...${NC}"
else
    echo -e "${YELLOW}Docker Compose no está instalado${NC}"
    echo "Downloading Docker Compose v2.23.0..."
    sleep 1
    echo -e "${GREEN}Docker Compose instalado correctamente${NC}"
    echo "Docker Compose version v2.23.0"
fi

# Configuración personalizada
echo -e "\n${YELLOW}[4/6] Configuración personalizada${NC}"
if ! confirm_step "¿Deseas continuar con la configuración?"; then
    echo -e "${RED}Configuración cancelada${NC}"
    exit 0
fi

# Solicitar IP
read -p "Ingresa la IP de tu servidor (ej: 192.168.1.174): " SERVER_IP
if [ -z "$SERVER_IP" ]; then
    SERVER_IP="192.168.1.100"
    echo -e "${BLUE}[DEMO] Usando IP por defecto: $SERVER_IP${NC}"
fi

# Solicitar contraseña
read -sp "Ingresa la contraseña para la interfaz web de Pi-hole: " WEB_PASSWORD
echo
if [ -z "$WEB_PASSWORD" ]; then
    WEB_PASSWORD="MiPassword123"
    echo -e "${BLUE}[DEMO] Usando contraseña por defecto${NC}"
fi

# Solicitar zona horaria
echo -e "\nZona horaria actual: ${GREEN}America/Santiago${NC}"
read -p "¿Deseas cambiarla? (s/N): " CHANGE_TZ
TIMEZONE="America/Santiago"
if [[ $CHANGE_TZ =~ ^[Ss]$ ]]; then
    read -p "Ingresa tu zona horaria (ej: America/Mexico_City): " TIMEZONE
    if [ -z "$TIMEZONE" ]; then
        TIMEZONE="America/Santiago"
    fi
fi

# Configurar servidores DNS upstream
echo -e "\n${YELLOW}Configuración de servidores DNS upstream:${NC}"
echo -e "${CYAN}1)${NC} Cloudflared (DoH) + Google DNS ${GREEN}[Recomendado]${NC}"
echo -e "${CYAN}2)${NC} Cloudflared (DoH) + Cloudflare DNS"
echo -e "${CYAN}3)${NC} Solo Google DNS (8.8.8.8, 8.8.4.4)"
echo -e "${CYAN}4)${NC} Solo Cloudflare DNS (1.1.1.1, 1.0.0.1)"
echo -e "${CYAN}5)${NC} OpenDNS (208.67.222.222, 208.67.220.220)"
echo -e "${CYAN}6)${NC} Personalizado"
read -p "Selecciona una opción [1-6] (default: 1): " DNS_OPTION

if [ -z "$DNS_OPTION" ]; then
    DNS_OPTION=1
    echo -e "${BLUE}[DEMO] Usando opción por defecto: 1${NC}"
fi

case ${DNS_OPTION} in
    1)
        DNS_UPSTREAMS="10.0.0.2#5054;8.8.8.8#53"
        USE_CLOUDFLARED=true
        echo -e "${GREEN}Usando Cloudflared + Google DNS${NC}"
        ;;
    2)
        DNS_UPSTREAMS="10.0.0.2#5054;1.1.1.1#53"
        USE_CLOUDFLARED=true
        echo -e "${GREEN}Usando Cloudflared + Cloudflare DNS${NC}"
        ;;
    3)
        DNS_UPSTREAMS="8.8.8.8#53;8.8.4.4#53"
        USE_CLOUDFLARED=false
        echo -e "${GREEN}Usando Google DNS${NC}"
        ;;
    4)
        DNS_UPSTREAMS="1.1.1.1#53;1.0.0.1#53"
        USE_CLOUDFLARED=false
        echo -e "${GREEN}Usando Cloudflare DNS${NC}"
        ;;
    5)
        DNS_UPSTREAMS="208.67.222.222#53;208.67.220.220#53"
        USE_CLOUDFLARED=false
        echo -e "${GREEN}Usando OpenDNS${NC}"
        ;;
    6)
        DNS_UPSTREAMS="8.8.8.8#53;8.8.4.4#53"
        USE_CLOUDFLARED=false
        echo -e "${BLUE}[DEMO] Usando DNS personalizado de ejemplo${NC}"
        ;;
    *)
        DNS_UPSTREAMS="10.0.0.2#5054;8.8.8.8#53"
        USE_CLOUDFLARED=true
        echo -e "${GREEN}Usando opción por defecto: Cloudflared + Google DNS${NC}"
        ;;
esac

# Crear directorio
INSTALL_DIR="/opt/pihole-dns"
echo -e "\n${YELLOW}[5/6] Crear directorios y archivos de configuración${NC}"
if ! confirm_step "¿Deseas crear los directorios en $INSTALL_DIR?"; then
    echo -e "${RED}Instalación cancelada${NC}"
    exit 0
fi

echo -e "${BLUE}[DEMO] mkdir -p $INSTALL_DIR${NC}"
echo -e "${BLUE}[DEMO] mkdir -p $INSTALL_DIR/config/pihole${NC}"
echo -e "${BLUE}[DEMO] mkdir -p $INSTALL_DIR/config/dnsmasq${NC}"
echo -e "${GREEN}Directorios creados correctamente${NC}"

# Mostrar docker-compose generado
echo -e "${YELLOW}Generando archivo docker-compose.yaml...${NC}"
sleep 1
echo -e "${GREEN}Archivo docker-compose.yaml creado:${NC}\n"

if [ "$USE_CLOUDFLARED" = true ]; then
cat <<EOF
${BLUE}version: "3"

services:
  cloudflared:
    container_name: cloudflared
    image: visibilityspots/cloudflared
    restart: unless-stopped
    networks:
      internal_net:
        ipv4_address: 10.0.0.2

  pi-hole:
    container_name: pi-hole
    image: pihole/pihole:latest
    restart: unless-stopped
    hostname: pihole
    ports:
      - "${SERVER_IP}:53:53/tcp"
      - "${SERVER_IP}:53:53/udp"
      - "${SERVER_IP}:80:80/tcp"
    volumes:
      - "./config/pihole:/etc/pihole"
      - "./config/dnsmasq:/etc/dnsmasq.d"
    environment:
      - FTLCONF_dns_upstreams=${DNS_UPSTREAMS}
      - FTLCONF_dns_listeningMode=all
      - IPv6=false
      - TZ=${TIMEZONE}
      - WEBPASSWORD=${WEB_PASSWORD}
      - ServerIP=${SERVER_IP}
    extra_hosts:
      - "cloudflared:10.0.0.2"
    networks:
      internal_net:
        ipv4_address: 10.0.0.3

networks:
  internal_net:
    driver: bridge
    ipam:
      config:
        - subnet: 10.0.0.0/29${NC}
EOF
else
cat <<EOF
${BLUE}version: "3"

services:
  pi-hole:
    container_name: pi-hole
    image: pihole/pihole:latest
    restart: unless-stopped
    hostname: pihole
    ports:
      - "${SERVER_IP}:53:53/tcp"
      - "${SERVER_IP}:53:53/udp"
      - "${SERVER_IP}:80:80/tcp"
    volumes:
      - "./config/pihole:/etc/pihole"
      - "./config/dnsmasq:/etc/dnsmasq.d"
    environment:
      - FTLCONF_dns_upstreams=${DNS_UPSTREAMS}
      - FTLCONF_dns_listeningMode=all
      - IPv6=false
      - TZ=${TIMEZONE}
      - WEBPASSWORD=${WEB_PASSWORD}
      - ServerIP=${SERVER_IP}${NC}
EOF
fi

# Iniciar servicios
echo -e "\n${YELLOW}[6/6] Iniciar servicios con Docker Compose${NC}"
if ! confirm_step "¿Deseas iniciar los contenedores ahora?"; then
    echo -e "${YELLOW}Servicios no iniciados. Puedes iniciarlos manualmente con:${NC}"
    echo -e "${CYAN}cd $INSTALL_DIR && docker-compose up -d${NC}"
    exit 0
fi

echo -e "${BLUE}[DEMO] docker-compose up -d${NC}"
echo "Creating network \"pihole-dns_internal_net\" with driver \"bridge\""
echo "Pulling cloudflared (visibilityspots/cloudflared:)..."
echo "Pulling pi-hole (pihole/pihole:latest)..."
sleep 1
echo "Creating cloudflared ... done"
echo "Creating pi-hole ... done"

# Verificar estado
echo -e "\n${YELLOW}Verificando estado de los contenedores...${NC}"
sleep 1
echo -e "${GREEN}    Name                  Command               State                    Ports${NC}"
echo "-----------------------------------------------------------------------------------------"
echo "cloudflared      cloudflared proxy-dns ...   Up"
echo "pi-hole          /s6-init                    Up      0.0.0.0:53->53/tcp, 0.0.0.0:53->53/udp, 0.0.0.0:80->80/tcp"

# Resumen
echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}   ¡Instalación completada!     ${NC}"
echo -e "${GREEN}================================${NC}"
echo -e "\nAccede a tu Pi-hole en: ${GREEN}http://${SERVER_IP}/admin${NC}"
echo -e "Contraseña: ${GREEN}${WEB_PASSWORD}${NC}"
echo -e "\nUbicación de archivos: ${GREEN}$INSTALL_DIR${NC}"
echo -e "\n${YELLOW}Comandos útiles:${NC}"
echo -e "  - Ver logs: ${GREEN}docker-compose logs -f${NC}"
echo -e "  - Detener: ${GREEN}docker-compose down${NC}"
echo -e "  - Reiniciar: ${GREEN}docker-compose restart${NC}"
echo -e "  - Actualizar: ${GREEN}docker-compose pull && docker-compose up -d${NC}"
echo -e "\n${YELLOW}No olvides configurar tu router o dispositivos para usar ${GREEN}${SERVER_IP}${YELLOW} como DNS${NC}\n"
