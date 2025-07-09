[![1.jpg](https://i.postimg.cc/1Xy1KV2p/1.jpg)](https://postimg.cc/tZvcqJXT)

# 🛡️ Hz_FysoBlockVPN

**Sistema Avanzado de Detección y Bloqueo de VPN/Proxy para FiveM**

*Desarrollado por: **HZ - CodigosParaJuegos - FiveMSoluciones***

---

## 📋 Tabla de Contenidos

- [🌟 Características](#-características)
- [📦 Instalación](#-instalación)
- [⚙️ Configuración](#️-configuración)
- [🔧 APIs Soportadas](#-apis-soportadas)
- [🎨 Personalización](#-personalización)
- [📊 Comandos de Administración](#-comandos-de-administración)
- [🔍 Solución de Problemas](#-solución-de-problemas)
- [📈 Rendimiento](#-rendimiento)
- [🤝 Soporte](#-soporte)
- [📄 Licencia](#-licencia)

---

## 🌟 Características

### 🔒 **Detección Avanzada**
- ✅ **Múltiples APIs**: Soporte para ip-api.com, vpnapi.io, proxycheck.io y más
- ✅ **Detección de VPN/Proxy**: Identificación precisa de conexiones proxy
- ✅ **Detección de Hosting**: Bloqueo de servicios de datacenter y hosting
- ✅ **Detección de Tor**: Identificación de conexiones de la red Tor
- ✅ **Verificación Geográfica**: Control por países con whitelist/blacklist

### 🚀 **Rendimiento Optimizado**
- ✅ **Sistema de Cache**: Cache inteligente para reducir consultas API
- ✅ **Rate Limiting**: Control automático de límites de API
- ✅ **Fallback Automático**: Cambio automático entre APIs en caso de fallo
- ✅ **Verificaciones Concurrentes**: Control de carga del servidor
- ✅ **Timeouts Configurables**: Evita bloqueos del servidor

### 🎨 **Interfaz Moderna**
- ✅ **Adaptive Cards**: Tarjetas interactivas modernas
- ✅ **Mensajes Personalizables**: Textos completamente configurables
- ✅ **Botones Personalizados**: Enlaces a Discord, web, soporte
- ✅ **Colores Configurables**: Esquema de colores personalizable
- ✅ **Responsive Design**: Adaptable a diferentes resoluciones

### 🛠️ **Administración Avanzada**
- ✅ **Whitelist Inteligente**: Por IP, rangos CIDR, Steam ID
- ✅ **Sistema de Logs**: Registro detallado de eventos
- ✅ **Estadísticas en Tiempo Real**: Monitoreo de rendimiento
- ✅ **Comandos de Consola**: Control total desde la consola
- ✅ **Webhooks Discord**: Notificaciones automáticas

---

## 📦 Instalación

### 📋 **Requisitos**
- FiveM Server (Artifact 2802 o superior)
- Lua 5.4 habilitado
- Acceso a internet para consultas API

### 🔽 **Pasos de Instalación**

1. **Descargar el recurso**
   ```bash
   git clone https://github.com/HZ-CodigosParaJuegos/Hz_FysoBlockVPN.git
   ```

2. **Colocar en la carpeta de recursos**
   ```
   server-data/
   └── resources/
       └── Hz_FysoBlockVPN/
   ```

3. **Agregar al server.cfg**
   ```cfg
   ensure Hz_FysoBlockVPN
   ```

4. **Configurar el recurso**
   - Edita `config.lua` según tus necesidades
   - Configura las APIs que deseas usar
   - Personaliza mensajes y botones

5. **Reiniciar el servidor**
   ```
   restart Hz_FysoBlockVPN
   ```

---

## ⚙️ Configuración

### 🔧 **Configuración Básica**

```lua
Config.ServerName = 'Mi Servidor FiveM'  -- Nombre de tu servidor
Config.Debug = false                      -- Activar logs detallados
Config.VersionCheck = true                -- Verificar actualizaciones
```

### 🌐 **Configuración de APIs**

```lua
Config.APIs = {
    {
        name = 'ip-api',
        url = 'http://ip-api.com/json/%s?fields=66846719',
        enabled = true,
        timeout = 5000,
        ratelimit = 45  -- Requests por minuto
    },
    -- Más APIs...
}
```

### 🔍 **Configuración de Detección**

```lua
Config.Detection = {
    vpn_enabled = true,           -- Detectar VPNs
    proxy_enabled = true,         -- Detectar Proxies
    hosting_enabled = true,       -- Detectar hosting/datacenter
    tor_enabled = true,           -- Detectar red Tor
    
    cache_enabled = true,         -- Activar cache
    cache_duration = 3600,        -- Duración del cache (segundos)
    max_retries = 3,              -- Reintentos por API
}
```

### 🌍 **Configuración de Países**

```lua
Config.CountryCheck = {
    enabled = false,              -- Activar verificación
    mode = 'whitelist',           -- 'whitelist' o 'blacklist'
    countries = {
        'US', 'CA', 'GB', 'DE', 'FR', 'ES', 'MX'
    }
}
```

### 📝 **Configuración de Whitelist**

```lua
Config.Whitelist = {
    enabled = true,
    ips = {
        '127.0.0.1',             -- Localhost
        '192.168.1.0/24',        -- Red local
    },
    steam_ids = {
        '76561198000000000',     -- Steam64 ID
    }
}
```

---

## 🔧 APIs Soportadas

### 🆓 **APIs Gratuitas**

#### **ip-api.com**
- ✅ **Gratis**: 1000 requests/mes
- ✅ **Sin API Key**: No requiere registro
- ✅ **Detección**: VPN, Proxy, Hosting, Geolocalización
- ⚠️ **Límite**: 45 requests/minuto

```lua
{
    name = 'ip-api',
    url = 'http://ip-api.com/json/%s?fields=66846719',
    enabled = true,
    timeout = 5000,
    ratelimit = 45
}
```

### 💰 **APIs Premium**

#### **vpnapi.io**
- 💰 **Premium**: Desde $10/mes
- 🔑 **API Key**: Requerida
- ✅ **Detección**: VPN, Proxy, Tor, Geolocalización avanzada
- 🚀 **Límite**: Según plan

```lua
{
    name = 'vpnapi',
    url = 'https://vpnapi.io/api/%s?key=TU_API_KEY',
    enabled = false,
    timeout = 5000,
    apikey_required = true
}
```

#### **proxycheck.io**
- 💰 **Premium**: Desde $5/mes
- 🔑 **API Key**: Requerida para mejores límites
- ✅ **Detección**: Proxy, VPN, Geolocalización
- 🚀 **Límite**: 1000/día gratis, más con API key

```lua
{
    name = 'proxycheck',
    url = 'https://proxycheck.io/v2/%s?key=TU_API_KEY&vpn=1&asn=1',
    enabled = false,
    timeout = 5000,
    apikey_required = true
}
```

---

## 🎨 Personalización

### 🎭 **Adaptive Cards**

Las Adaptive Cards proporcionan una experiencia visual moderna y profesional:

```lua
Config.UI = {
    adaptive_card = true,         -- Activar Adaptive Cards
    show_reason = true,           -- Mostrar razón del bloqueo
    colors = {
        primary = '#FF6B6B',      -- Color principal
        secondary = '#4ECDC4',    -- Color secundario
        warning = '#FFE66D',      -- Color de advertencia
        danger = '#FF6B6B'        -- Color de peligro
    }
}
```

### 📝 **Mensajes Personalizados**

```lua
Config.Locales = {
    vpn_detected = {
        title = '🚫 VPN Detectada',
        message = 'Mensaje personalizado aquí...'
    },
    country_blocked = {
        title = '🌍 País No Permitido',
        message = 'Mensaje personalizado aquí...'
    }
}
```

### 🔘 **Botones Personalizados**

```lua
Config.Buttons = {
    {
        title = '💬 Discord',
        url = 'https://discord.gg/tu-servidor',
        style = 'positive'
    },
    {
        title = '🌐 Sitio Web',
        url = 'https://tu-servidor.com',
        style = 'default'
    }
}
```

**Estilos disponibles:**
- `positive` - Verde (recomendado para Discord)
- `destructive` - Rojo (para acciones importantes)
- `default` - Azul (para enlaces generales)

---

## 📊 Comandos de Administración

### 🖥️ **Comandos Principales**

#### **Estadísticas Generales**
```
hzblockvpn stats
```
Muestra estadísticas completas del sistema:
- Tiempo de actividad
- Conexiones verificadas/bloqueadas
- Errores de API
- Cache hits

#### **Estadísticas de APIs**
```
hzapi stats
```
Muestra estadísticas detalladas de cada API:
- Requests totales por API
- Tasa de éxito
- Tiempo promedio de respuesta
- Último uso

#### **Probar APIs**
```
hzapi test [ip]
```
Prueba todas las APIs con una IP específica (por defecto 8.8.8.8)

#### **Limpiar Cache**
```
hzblockvpn clearcache
```
Limpia completamente el cache de IPs

#### **Reiniciar Estadísticas**
```
hzapi reset
```
Reinicia todas las estadísticas de APIs

### 📈 **Ejemplo de Salida**

```
═══════════════════════════════════════
        Hz_FysoBlockVPN - Estadísticas
═══════════════════════════════════════
Tiempo activo: 3600 segundos
Verificaciones totales: 150
Conexiones bloqueadas: 12
Conexiones permitidas: 138
Errores de API: 2
Cache hits: 45
Verificaciones activas: 0
═══════════════════════════════════════
```

---

## 🔍 Solución de Problemas

### ❌ **Problemas Comunes**

#### **"API Error" constante**
**Causa**: Problemas de conectividad o límites de API
**Solución**:
1. Verificar conexión a internet del servidor
2. Comprobar límites de rate limiting
3. Probar con `hzapi test`
4. Revisar logs con `Config.Debug = true`

#### **Falsos positivos**
**Causa**: Algunos ISPs o servicios legítimos detectados como VPN
**Solución**:
1. Agregar IPs específicas a la whitelist
2. Ajustar configuración de detección
3. Usar múltiples APIs para mayor precisión

#### **Rendimiento lento**
**Causa**: Demasiadas verificaciones concurrentes
**Solución**:
1. Ajustar `max_concurrent_checks`
2. Reducir `timeout` de APIs
3. Activar cache si está deshabilitado

### 🔧 **Configuración de Debug**

```lua
Config.Debug = true  -- Activar logs detallados
```

Con debug activado verás:
- Detalles de cada consulta API
- Tiempos de respuesta
- Errores específicos
- Información de cache

### 📋 **Logs Importantes**

```
[INFO] Verificando conexión: PlayerName (192.168.1.100)
[DEBUG] Cache hit para IP: 192.168.1.100
[WARN] Rate limit alcanzado para ip-api (45/45)
[ERROR] Error HTTP en vpnapi: 429
```

---

## 📈 Rendimiento

### ⚡ **Optimizaciones Implementadas**

- **Cache Inteligente**: Reduce consultas API en 60-80%
- **Rate Limiting**: Evita bloqueos por exceso de requests
- **Fallback Automático**: Garantiza disponibilidad del servicio
- **Timeouts Configurables**: Evita bloqueos del servidor
- **Limpieza Automática**: Gestión eficiente de memoria

### 📊 **Métricas de Rendimiento**

| Métrica | Valor Típico | Óptimo |
|---------|--------------|--------|
| Tiempo de verificación | 500-2000ms | <1000ms |
| Cache hit rate | 60-80% | >70% |
| Tasa de éxito API | 95-99% | >98% |
| Memoria utilizada | 10-30MB | <50MB |

### 🔧 **Configuración Recomendada**

```lua
Config.Advanced = {
    performance = {
        max_concurrent_checks = 10,  -- Ajustar según CPU
        cleanup_interval = 300,      -- 5 minutos
        memory_limit = 50            -- 50MB
    }
}
```

---

## 🤝 Soporte

### 📞 **Canales de Soporte**

- **🌐 GitHub**: [Issues y Pull Requests](https://github.com/HZ-CodigosParaJuegos/Hz_FysoBlockVPN)
- **💬 Discord**: [Servidor de Soporte](https://discord.gg/hz-codigosparajuegos)
- **📧 Email**: soporte@hz-codigosparajuegos.com
- **📱 Telegram**: @HZ_CodigosParaJuegos

### 🐛 **Reportar Bugs**

Al reportar un bug, incluye:
1. Versión del script
2. Versión de FiveM
3. Configuración utilizada
4. Logs con debug activado
5. Pasos para reproducir

### 💡 **Solicitar Características**

¿Tienes una idea para mejorar el script? ¡Nos encantaría escucharla!

---

## 🔄 Actualizaciones

### 📋 **Changelog**

#### **v2.0.0** - *Versión Actual*
- ✅ Reescritura completa del código
- ✅ Soporte para múltiples APIs
- ✅ Sistema de cache avanzado
- ✅ Adaptive Cards mejoradas
- ✅ Comandos de administración
- ✅ Sistema de logs completo
- ✅ Optimizaciones de rendimiento

#### **v1.1.0** - *Versión Original*
- ✅ Detección básica de VPN
- ✅ Soporte para ip-api.com
- ✅ Adaptive Cards básicas
- ✅ Verificación por países

### 🔔 **Notificaciones de Actualización**

El script verifica automáticamente nuevas versiones. Para desactivar:

```lua
Config.VersionCheck = false
```

---

## 📄 Licencia

```
MIT License

Copyright (c) 2024 HZ - CodigosParaJuegos - FiveMSoluciones

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHOR OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Créditos

**Desarrollado con ❤️ por:**
- **HZ - CodigosParaJuegos - FiveMSoluciones**
- GitHub: [@HZ-CodigosParaJuegos](https://github.com/HZ-CodigosParaJuegos)
- Discord: HZ#1234

**Agradecimientos especiales:**
- Comunidad de FiveM por el feedback
- Proveedores de APIs por sus servicios
- Beta testers por su tiempo y dedicación

---

## 🌟 ¿Te gusta el proyecto?

⭐ **¡Dale una estrella en GitHub!**
🔄 **Compártelo con otros desarrolladores**
💬 **Únete a nuestra comunidad**

---

<div align="center">

**Hz_FysoBlockVPN v2.0.0**

*La solución definitiva para proteger tu servidor FiveM*

[🌐 GitHub](https://github.com/HZ-CodigosParaJuegos) • [💬 Discord](https://discord.gg/hz-codigosparajuegos) • [📧 Soporte](mailto:soporte@hz-codigosparajuegos.com)

</div>
