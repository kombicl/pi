# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

---

## [1.0.0] - 2025-10-03

### 🎉 Lanzamiento Inicial

Primer release público del instalador Pi-hole + Cloudflared.

### ✨ Añadido

- **Script de instalación interactivo** (`install.sh`)
  - Instalación automática de Docker
  - Instalación automática de Docker Compose
  - Actualización del sistema (apt update && upgrade)
  - Confirmación paso a paso antes de cada etapa
  - Validación de entradas (IP, contraseña, etc.)

- **Configuración personalizable**
  - IP del servidor (con validación de formato)
  - Contraseña para interfaz web de Pi-hole
  - Zona horaria configurable
  - **6 opciones de servidores DNS upstream**:
    1. Cloudflared (DoH) + Google DNS [Recomendado]
    2. Cloudflared (DoH) + Cloudflare DNS
    3. Solo Google DNS (8.8.8.8, 8.8.4.4)
    4. Solo Cloudflare DNS (1.1.1.1, 1.0.0.1)
    5. OpenDNS (208.67.222.222, 208.67.220.220)
    6. DNS personalizado

- **Generación automática de docker-compose.yaml**
  - Configuración dinámica según opciones elegidas
  - Con o sin Cloudflared según selección de DNS
  - Red interna Docker para comunicación entre contenedores (cuando usa Cloudflared)
  - Volúmenes persistentes para configuración

- **Script de demostración** (`demo.sh`)
  - Prueba el instalador sin hacer cambios reales
  - Muestra el flujo completo de instalación
  - Simula todas las etapas

- **Interfaz de usuario mejorada**
  - Colores para mejor visibilidad
  - Header personalizado "Script creado por Kombi"
  - Mensajes claros y concisos
  - Indicadores de progreso [1/6], [2/6], etc.

- **Documentación completa**
  - README.md detallado con instrucciones
  - Ejemplos de uso
  - Solución de problemas
  - Comandos útiles

- **Plantilla de referencia**
  - `docker-compose.yaml.template` como ejemplo

### 🔧 Características técnicas

- Detección automática de Docker y Docker Compose instalados
- Instalación de última versión de Docker Compose desde GitHub
- Creación automática de directorios de configuración
- Soporte para múltiples arquitecturas (x86_64, ARM, ARM64)
- Compatible con Debian, Ubuntu y Raspberry Pi OS

### 🛡️ Seguridad

- Validación de inputs del usuario
- Contraseña requerida para Pi-hole (no permite vacías)
- Ejecución con privilegios root requerida (verificación)
- Sin contraseñas hardcoded

### 📦 Archivos incluidos

```
pi/
├── install.sh                      # Script principal
├── demo.sh                         # Modo demo
├── docker-compose.yaml.template    # Plantilla
├── README.md                       # Documentación
└── CHANGELOG.md                    # Este archivo
```

### 🎯 Casos de uso soportados

- ✅ Instalación en Raspberry Pi
- ✅ Instalación en servidores Linux (Debian/Ubuntu)
- ✅ Instalación en VPS
- ✅ Configuración con DNS over HTTPS (DoH)
- ✅ Configuración sin Cloudflared (DNS directo)
- ✅ Configuración con DNS personalizados

---

## [Unreleased]

### Planeado para futuras versiones

- [ ] Soporte para IPv6
- [ ] Opción de instalación desatendida (modo silent)
- [ ] Backup y restore de configuración
- [ ] Script de actualización automática
- [ ] Soporte para múltiples upstream DNS personalizados
- [ ] Integración con otros servicios (Unbound, etc.)
- [ ] Instalador para otras distribuciones (CentOS, Fedora, Arch)
- [ ] Configuración de listas de bloqueo personalizadas
- [ ] Dashboard de estadísticas

---

## Tipos de cambios

- **Añadido** - Para nuevas características
- **Cambiado** - Para cambios en funcionalidad existente
- **Deprecado** - Para características que serán removidas
- **Removido** - Para características removidas
- **Arreglado** - Para corrección de bugs
- **Seguridad** - Para vulnerabilidades

---

[1.0.0]: https://github.com/kombicl/pi/releases/tag/v1.0.0
[Unreleased]: https://github.com/kombicl/pi/compare/v1.0.0...HEAD
