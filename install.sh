#!/bin/bash

# Script de instalación personalizado para Pi-hole con Cloudflared
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

# Verificar si se ejecuta con privilegios
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Por favor ejecuta este script como root o con sudo${NC}"
    exit 1
fi

# Actualizar el sistema
echo -e "${YELLOW}[1/6] Actualizar el sistema${NC}"
if confirm_step "¿Deseas actualizar el sistema (apt update && upgrade)?"; then
    apt-get update -y
    apt-get upgrade -y
    echo -e "${GREEN}Sistema actualizado correctamente${NC}"
fi

# Instalar Docker
echo -e "\n${YELLOW}[2/6] Instalar Docker${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker no está instalado${NC}"
    if confirm_step "¿Deseas instalar Docker?"; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        systemctl enable docker
        systemctl start docker
        rm get-docker.sh
        echo -e "${GREEN}Docker instalado correctamente${NC}"
    else
        echo -e "${RED}Docker es necesario para continuar. Instalación cancelada.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Docker ya está instalado${NC}"
    docker --version
fi

# Instalar Docker Compose
echo -e "\n${YELLOW}[3/6] Instalar Docker Compose${NC}"
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}Docker Compose no está instalado${NC}"
    if confirm_step "¿Deseas instalar Docker Compose?"; then
        COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
        curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        echo -e "${GREEN}Docker Compose instalado correctamente${NC}"
    else
        echo -e "${RED}Docker Compose es necesario para continuar. Instalación cancelada.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Docker Compose ya está instalado${NC}"
    docker-compose --version
fi

# Configuración personalizada
echo -e "\n${YELLOW}[4/6] Configuración personalizada${NC}"
if ! confirm_step "¿Deseas continuar con la configuración?"; then
    echo -e "${RED}Configuración cancelada${NC}"
    exit 0
fi

# Solicitar IP
read -p "Ingresa la IP de tu servidor (ej: 192.168.1.174): " SERVER_IP
while [[ ! $SERVER_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; do
    echo -e "${RED}IP inválida. Por favor ingresa una IP válida${NC}"
    read -p "Ingresa la IP de tu servidor: " SERVER_IP
done

# Solicitar contraseña
read -sp "Ingresa la contraseña para la interfaz web de Pi-hole: " WEB_PASSWORD
echo
while [ -z "$WEB_PASSWORD" ]; do
    echo -e "${RED}La contraseña no puede estar vacía${NC}"
    read -sp "Ingresa la contraseña para la interfaz web de Pi-hole: " WEB_PASSWORD
    echo
done

# Solicitar zona horaria (opcional)
echo -e "\nZona horaria actual: ${GREEN}America/Santiago${NC}"
read -p "¿Deseas cambiarla? (s/N): " CHANGE_TZ
TIMEZONE="America/Santiago"
if [[ $CHANGE_TZ =~ ^[Ss]$ ]]; then
    read -p "Ingresa tu zona horaria (ej: America/Mexico_City): " TIMEZONE
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

case ${DNS_OPTION:-1} in
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
        read -p "Ingresa el servidor DNS primario (IP:Puerto, ej: 8.8.8.8#53): " DNS1
        read -p "Ingresa el servidor DNS secundario (IP:Puerto, ej: 8.8.4.4#53): " DNS2
        DNS_UPSTREAMS="${DNS1};${DNS2}"
        USE_CLOUDFLARED=false
        echo -e "${GREEN}Usando DNS personalizado${NC}"
        ;;
    *)
        DNS_UPSTREAMS="10.0.0.2#5054;8.8.8.8#53"
        USE_CLOUDFLARED=true
        echo -e "${GREEN}Usando opción por defecto: Cloudflared + Google DNS${NC}"
        ;;
esac

# Crear directorio de trabajo
INSTALL_DIR="/opt/pihole-dns"
echo -e "\n${YELLOW}[5/6] Crear directorios y archivos de configuración${NC}"
if ! confirm_step "¿Deseas crear los directorios en $INSTALL_DIR?"; then
    echo -e "${RED}Instalación cancelada${NC}"
    exit 0
fi

mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

# Crear estructura de carpetas
mkdir -p config/pihole
mkdir -p config/dnsmasq
echo -e "${GREEN}Directorios creados correctamente${NC}"

# Generar docker-compose.yaml
echo -e "${YELLOW}Generando archivo docker-compose.yaml...${NC}"

if [ "$USE_CLOUDFLARED" = true ]; then
cat > docker-compose.yaml <<EOF
version: "3"

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
    dns:
      - 1.1.1.1
      - 8.8.8.8
    cap_add:
      - NET_ADMIN

networks:
  internal_net:
    driver: bridge
    ipam:
      config:
        - subnet: 10.0.0.0/29
EOF
else
cat > docker-compose.yaml <<EOF
version: "3"

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
      - ServerIP=${SERVER_IP}
    dns:
      - 1.1.1.1
      - 8.8.8.8
    cap_add:
      - NET_ADMIN
EOF
fi

echo -e "${GREEN}Archivo docker-compose.yaml creado correctamente${NC}"

# Iniciar servicios
echo -e "\n${YELLOW}[6/6] Iniciar servicios con Docker Compose${NC}"
if confirm_step "¿Deseas iniciar los contenedores ahora?"; then
    docker-compose up -d
else
    echo -e "${YELLOW}Servicios no iniciados. Puedes iniciarlos manualmente con:${NC}"
    echo -e "${CYAN}cd $INSTALL_DIR && docker-compose up -d${NC}"
    exit 0
fi

# Verificar estado
echo -e "\n${YELLOW}Verificando estado de los contenedores...${NC}"
sleep 5
docker-compose ps

# Resumen
echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}   ¡Instalación completada!     ${NC}"
echo -e "${GREEN}================================${NC}"
echo -e "\nAccede a tu Pi-hole en: ${GREEN}http://${SERVER_IP}/admin${NC}"
echo -e "Contraseña: ${GREEN}(la que configuraste)${NC}"
echo -e "\nUbicación de archivos: ${GREEN}$INSTALL_DIR${NC}"
echo -e "\n${YELLOW}Comandos útiles:${NC}"
echo -e "  - Ver logs: ${GREEN}docker-compose logs -f${NC}"
echo -e "  - Detener: ${GREEN}docker-compose down${NC}"
echo -e "  - Reiniciar: ${GREEN}docker-compose restart${NC}"
echo -e "  - Actualizar: ${GREEN}docker-compose pull && docker-compose up -d${NC}"
echo -e "\n${YELLOW}No olvides configurar tu router o dispositivos para usar ${GREEN}${SERVER_IP}${YELLOW} como DNS${NC}\n"
