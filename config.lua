--[[
    Archivo de Configuración - Hz_FysoBlockVPN
    Desarrollado por: HZ - CodigosParaJuegos - FiveMSoluciones
    
    ⚠️  IMPORTANTE: Configura cuidadosamente estas opciones según las necesidades de tu servidor
--]]

Config = {}

-- ═══════════════════════════════════════════════════════════════
--                    CONFIGURACIÓN GENERAL
-- ═══════════════════════════════════════════════════════════════

Config.ServerName = 'Tu Servidor FiveM'  -- Nombre de tu servidor
Config.Debug = false                      -- Activar modo debug (logs detallados)
Config.VersionCheck = true                -- Verificar actualizaciones automáticamente

-- ═══════════════════════════════════════════════════════════════
--                    CONFIGURACIÓN DE APIs
-- ═══════════════════════════════════════════════════════════════

-- APIs disponibles para detección de VPN/Proxy (se usan en orden de prioridad)
Config.APIs = {
    {
        name = 'ip-api',
        url = 'http://ip-api.com/json/%s?fields=66846719',
        enabled = true,
        timeout = 5000,
        ratelimit = 45  -- Requests por minuto
    },
    {
        name = 'vpnapi',
        url = 'https://vpnapi.io/api/%s?key=YOUR_API_KEY',
        enabled = false,
        timeout = 5000,
        apikey_required = true
    },
    {
        name = 'proxycheck',
        url = 'https://proxycheck.io/v2/%s?key=YOUR_API_KEY&vpn=1&asn=1',
        enabled = false,
        timeout = 5000,
        apikey_required = true
    }
}

-- ═══════════════════════════════════════════════════════════════
--                    CONFIGURACIÓN DE DETECCIÓN
-- ═══════════════════════════════════════════════════════════════

Config.Detection = {
    vpn_enabled = true,           -- Detectar VPNs
    proxy_enabled = true,         -- Detectar Proxies
    hosting_enabled = true,       -- Detectar servicios de hosting/datacenter
    tor_enabled = true,           -- Detectar red Tor
    mobile_enabled = false,       -- Detectar conexiones móviles (puede causar falsos positivos)
    
    -- Configuración de reintentos
    max_retries = 3,              -- Máximo número de reintentos por API
    retry_delay = 2000,           -- Delay entre reintentos (ms)
    
    -- Cache de IPs
    cache_enabled = true,         -- Activar cache de IPs verificadas
    cache_duration = 3600,        -- Duración del cache en segundos (1 hora)
    cache_max_size = 1000         -- Máximo número de IPs en cache
}

-- ═══════════════════════════════════════════════════════════════
--                    CONFIGURACIÓN DE PAÍSES
-- ═══════════════════════════════════════════════════════════════

Config.CountryCheck = {
    enabled = false,              -- Activar verificación por países
    mode = 'whitelist',           -- 'whitelist' o 'blacklist'
    
    -- Lista de países permitidos (modo whitelist) o bloqueados (modo blacklist)
    -- Códigos ISO 3166-1 alpha-2: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
    countries = {
        'US', 'CA', 'GB', 'DE', 'FR', 'ES', 'IT', 'NL', 'AU', 'JP',
        'MX', 'AR', 'BR', 'CL', 'CO', 'PE', 'UY', 'EC', 'VE', 'BO'
    }
}

-- ═══════════════════════════════════════════════════════════════
--                    CONFIGURACIÓN DE WHITELIST
-- ═══════════════════════════════════════════════════════════════

Config.Whitelist = {
    enabled = true,               -- Activar sistema de whitelist
    
    -- IPs específicas que siempre pueden conectar
    ips = {
        '127.0.0.1',             -- Localhost
        '192.168.1.0/24',        -- Red local ejemplo
        -- Agrega más IPs aquí
    },
    
    -- Rangos de ASN (Autonomous System Numbers) permitidos
    asn_ranges = {
        -- Ejemplos de ISPs principales
        -- 'AS15169',            -- Google
        -- 'AS32934',            -- Facebook
    },
    
    -- Identificadores de Steam permitidos (Steam64)
    steam_ids = {
        -- '76561198000000000',  -- Ejemplo
    }
}

-- ═══════════════════════════════════════════════════════════════
--                    CONFIGURACIÓN DE INTERFAZ
-- ═══════════════════════════════════════════════════════════════

Config.UI = {
    adaptive_card = true,         -- Usar Adaptive Cards (recomendado)
    show_reason = true,           -- Mostrar razón específica del bloqueo
    show_ip_info = false,         -- Mostrar información de IP (solo para admins)
    
    -- Configuración de colores para Adaptive Cards
    colors = {
        primary = '#FF6B6B',      -- Color principal
        secondary = '#4ECDC4',    -- Color secundario
        warning = '#FFE66D',      -- Color de advertencia
        danger = '#FF6B6B'        -- Color de peligro
    }
}

-- ═══════════════════════════════════════════════════════════════
--                    MENSAJES Y LOCALIZACIÓN
-- ═══════════════════════════════════════════════════════════════

Config.Locales = {
    -- Mensajes durante la verificación
    checking = '🔍 Verificando conexión...',
    checking_vpn = '🛡️ Analizando seguridad de la conexión...',
    checking_country = '🌍 Verificando ubicación geográfica...',
    
    -- Mensajes de bloqueo
    vpn_detected = {
        title = '🚫 VPN Detectada',
        message = 'No se permite el acceso mediante VPN, Proxy o servicios similares.\n\n' ..
                 '💡 Si no estás usando una VPN, esto puede deberse a:\n' ..
                 '• Servicios de gaming en la nube\n' ..
                 '• Conexiones corporativas\n' ..
                 '• Algunos proveedores de internet\n\n' ..
                 '📞 Si crees que es un error, contacta con el soporte.'
    },
    
    country_blocked = {
        title = '🌍 País No Permitido',
        message = 'Las conexiones desde tu ubicación geográfica no están permitidas en este servidor.\n\n' ..
                 '📞 Si crees que es un error, contacta con el soporte.'
    },
    
    -- Mensajes de error
    api_error = '⚠️ Error en la verificación de seguridad. Intenta nuevamente.',
    connection_timeout = '⏱️ Tiempo de verificación agotado. Intenta nuevamente.',
    
    -- Mensajes para administradores
    admin_bypass = '👑 Acceso de administrador - Verificaciones omitidas',
    whitelist_bypass = '✅ IP en lista blanca - Acceso permitido'
}

-- ═══════════════════════════════════════════════════════════════
--                    CONFIGURACIÓN DE BOTONES
-- ═══════════════════════════════════════════════════════════════

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
    },
    {
        title = '📋 Soporte',
        url = 'https://tu-servidor.com/soporte',
        style = 'default'
    }
    -- Máximo 5 botones
}

-- ═══════════════════════════════════════════════════════════════
--                    CONFIGURACIÓN AVANZADA
-- ═══════════════════════════════════════════════════════════════

Config.Advanced = {
    -- Configuración de logs
    logging = {
        enabled = true,
        log_attempts = true,      -- Registrar intentos de conexión
        log_blocks = true,        -- Registrar bloqueos
        log_file = 'hz_blockvpn.log'
    },
    
    -- Configuración de rendimiento
    performance = {
        max_concurrent_checks = 10,  -- Máximo de verificaciones simultáneas
        cleanup_interval = 300,      -- Intervalo de limpieza de cache (segundos)
        memory_limit = 50            -- Límite de memoria en MB
    },
    
    -- Configuración de webhooks (Discord)
    webhooks = {
        enabled = false,
        url = '',                    -- URL del webhook de Discord
        send_blocks = true,          -- Enviar notificaciones de bloqueos
        send_errors = true           -- Enviar notificaciones de errores
    }
}

-- ═══════════════════════════════════════════════════════════════
--                    CONFIGURACIÓN DE DESARROLLADOR
-- ═══════════════════════════════════════════════════════════════

-- ⚠️ NO MODIFICAR A MENOS QUE SEPAS LO QUE HACES
Config.Developer = {
    script_name = 'Hz_FysoBlockVPN',
    version = '2.0.0',
    author = 'HZ - CodigosParaJuegos - FiveMSoluciones',
    github = 'https://github.com/HZ-CodigosParaJuegos',
    update_check_url = 'https://api.github.com/repos/HZ-CodigosParaJuegos/Hz_FysoBlockVPN/releases/latest'
}