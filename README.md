# 🚐 Pi-hole + Cloudflared Installer

[![GitHub](https://img.shields.io/badge/github-kombicl%2Fpi-blue)](https://github.com/kombicl/pi)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Script de instalación automatizado para **Pi-hole** con **Cloudflared DNS over HTTPS** (DoH).

Creado por **Kombi** 🛠️

---

## 📋 Características

- ✅ **Instalación interactiva paso a paso** con confirmación en cada etapa
- ✅ **Instalación automática** de Docker y Docker Compose
- ✅ **Actualización del sistema** (apt update && upgrade)
- ✅ **Configuración personalizada**:
  - IP del servidor
  - Contraseña de interfaz web
  - Zona horaria
  - **6 opciones de servidores DNS upstream**
- ✅ **Validación de entradas** para evitar errores
- ✅ **Interfaz colorida** y fácil de usar
- ✅ **Modo demo** incluido para probar sin instalar

---

## 🚀 Instalación Rápida

### Opción 1: Clonar desde GitHub (Recomendado)

```bash
# Clonar el repositorio
git clone https://github.com/kombicl/pi.git

# Entrar al directorio
cd pi

# Dar permisos de ejecución
chmod +x install.sh

# Ejecutar con sudo
sudo ./install.sh
```

### Opción 2: Descarga directa

```bash
# Descargar el script
wget https://raw.githubusercontent.com/kombicl/pi/main/install.sh

# Dar permisos de ejecución
chmod +x install.sh

# Ejecutar con sudo
sudo ./install.sh
```

### Opción 3: Modo Demo (sin instalación real)

```bash
# Prueba el instalador sin hacer cambios reales
./demo.sh
```

---

## 📖 Uso

El script te guiará **paso a paso** con confirmaciones en cada etapa:

### **[1/6] Actualizar el sistema**
```
¿Deseas actualizar el sistema (apt update && upgrade)? (s/N):
```
- Actualiza todos los paquetes del sistema
- Opcional, puedes omitirlo si ya está actualizado

### **[2/6] Instalar Docker**
```
¿Deseas instalar Docker? (s/N):
```
- Instala Docker automáticamente
- **Requerido** para continuar

### **[3/6] Instalar Docker Compose**
```
¿Deseas instalar Docker Compose? (s/N):
```
- Instala la última versión de Docker Compose
- **Requerido** para continuar

### **[4/6] Configuración personalizada**
```
¿Deseas continuar con la configuración? (s/N):
```

Si aceptas, configurarás:

1. **IP del servidor**: Ingresa la IP local (ej: `192.168.1.174`)
2. **Contraseña**: Define la contraseña para Pi-hole web UI
3. **Zona horaria**: Cambia opcionalmente (default: `America/Santiago`)
4. **Servidores DNS upstream**: Selecciona entre 6 opciones:

| Opción | Descripción | Uso |
|--------|-------------|-----|
| **1** | Cloudflared (DoH) + Google DNS | ⭐ **Recomendado** - Privacidad + velocidad |
| **2** | Cloudflared (DoH) + Cloudflare DNS | Máxima privacidad |
| **3** | Solo Google DNS (8.8.8.8, 8.8.4.4) | Rápido y confiable |
| **4** | Solo Cloudflare DNS (1.1.1.1, 1.0.0.1) | Privacidad sin DoH |
| **5** | OpenDNS (208.67.222.222) | Control parental integrado |
| **6** | Personalizado | Define tus propios servidores |

### **[5/6] Crear directorios**
```
¿Deseas crear los directorios en /opt/pihole-dns? (s/N):
```
- Crea estructura de carpetas en `/opt/pihole-dns`
- Genera el archivo `docker-compose.yaml`

### **[6/6] Iniciar servicios**
```
¿Deseas iniciar los contenedores ahora? (s/N):
```
- Inicia Pi-hole y Cloudflared (si seleccionaste)
- Opcional, puedes iniciarlo manualmente después

---

## 🎯 Después de la instalación

### Acceder a Pi-hole

```
http://TU_IP/admin
```

Usa la contraseña que configuraste durante la instalación.

### Configurar tus dispositivos

**Opción A: Configurar el router (recomendado)**
- Configura el DNS primario de tu router a la IP del servidor
- Todos los dispositivos usarán automáticamente Pi-hole

**Opción B: Configurar dispositivo individual**
- Ve a configuración de red
- Cambia el DNS a la IP de tu servidor Pi-hole

---

## 🛠️ Comandos útiles

```bash
# Ir al directorio de instalación
cd /opt/pihole-dns

# Ver logs en tiempo real
docker-compose logs -f

# Ver logs de Pi-hole solamente
docker-compose logs -f pi-hole

# Detener servicios
docker-compose down

# Iniciar servicios
docker-compose up -d

# Reiniciar servicios
docker-compose restart

# Actualizar imágenes
docker-compose pull && docker-compose up -d

# Ver estado de contenedores
docker-compose ps
```

---

## 📁 Estructura del proyecto

```
pi/
├── install.sh                      # Script principal de instalación
├── demo.sh                         # Modo demo (sin cambios reales)
├── docker-compose.yaml.template    # Plantilla de referencia
├── README.md                       # Este archivo
└── CHANGELOG.md                    # Historial de cambios
```

---

## 🔧 Requisitos del sistema

- **Sistema operativo**: Linux (Debian/Ubuntu/Raspberry Pi OS)
- **Acceso**: root o sudo
- **Conexión**: Internet activa
- **Arquitectura**: x86_64, ARM, ARM64

---

## 🏗️ Lo que instala

### Con Cloudflared (Opciones 1 y 2):
- **Pi-hole** - Bloqueador de anuncios a nivel de red
- **Cloudflared** - DNS over HTTPS (DoH)
- **Red interna** Docker (10.0.0.0/29)
- **Volúmenes persistentes** para configuración

### Sin Cloudflared (Opciones 3-6):
- **Pi-hole** - Bloqueador de anuncios a nivel de red
- **DNS upstream directo** a los servidores elegidos
- **Volúmenes persistentes** para configuración

---

## 🐛 Solución de problemas

### El script dice "Docker es necesario para continuar"
- Debes aceptar instalar Docker para continuar
- Si ya lo tienes instalado, el script lo detectará automáticamente

### No puedo acceder a Pi-hole web
```bash
# Verificar que los contenedores estén corriendo
docker ps

# Ver logs de Pi-hole
docker logs pi-hole

# Reiniciar contenedor
docker restart pi-hole
```

### Los anuncios no se bloquean
1. Verifica que tu dispositivo esté usando la IP correcta como DNS
2. Puede tomar unos minutos hasta que los cambios surtan efecto
3. Limpia la caché DNS del dispositivo

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas! Si tienes ideas para mejorar este instalador:

1. Haz fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/mejora`)
3. Commit tus cambios (`git commit -m 'Añade nueva característica'`)
4. Push a la rama (`git push origin feature/mejora`)
5. Abre un Pull Request

---

## 📝 Licencia

Este proyecto está bajo la licencia MIT. Ver archivo [LICENSE](LICENSE) para más detalles.

---

## 👤 Autor

**Kombi** 🚐

- GitHub: [@kombicl](https://github.com/kombicl)
- Proyecto: [pi](https://github.com/kombicl/pi)

---

## ⭐ Agradecimientos

- [Pi-hole](https://pi-hole.net/) - Por el increíble bloqueador de anuncios
- [Cloudflare](https://www.cloudflare.com/) - Por cloudflared y DNS over HTTPS
- Comunidad de código abierto

---

## 📚 Recursos adicionales

- [Documentación oficial de Pi-hole](https://docs.pi-hole.net/)
- [Cloudflared GitHub](https://github.com/cloudflare/cloudflared)
- [Docker Documentation](https://docs.docker.com/)

---

<div align="center">

**¿Te gusta este proyecto? Dale una ⭐ en GitHub!**

[Reportar un Bug](https://github.com/kombicl/pi/issues) · [Solicitar Feature](https://github.com/kombicl/pi/issues) · [Ver Changelog](CHANGELOG.md)

</div>
