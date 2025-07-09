--[[
    Archivo de Utilidades - Hz_FysoBlockVPN
    Desarrollado por: HZ - CodigosParaJuegos - FiveMSoluciones
    
    Funciones auxiliares y herramientas para el sistema de bloqueo VPN
--]]

-- ═══════════════════════════════════════════════════════════════
--                    UTILIDADES DE RED
-- ═══════════════════════════════════════════════════════════════

--- Función para validar formato de IP más robusta
--- @param ip string IP a validar
--- @return boolean, string Válida y tipo (IPv4/IPv6)
function ValidateIPAddress(ip)
    if not ip or type(ip) ~= 'string' then
        return false, 'invalid'
    end
    
    -- Remover puerto si existe
    local cleanIP = ip:match('([^:]+)') or ip
    
    -- Verificar IPv4
    local ipv4Pattern = '^(%d+)%.(%d+)%.(%d+)%.(%d+)$'
    local a, b, c, d = cleanIP:match(ipv4Pattern)
    
    if a and b and c and d then
        a, b, c, d = tonumber(a), tonumber(b), tonumber(c), tonumber(d)
        if a >= 0 and a <= 255 and b >= 0 and b <= 255 and 
           c >= 0 and c <= 255 and d >= 0 and d <= 255 then
            return true, 'IPv4'
        end
    end
    
    -- Verificar IPv6 (básico)
    if cleanIP:match('^[0-9a-fA-F:]+$') and cleanIP:find(':') then
        return true, 'IPv6'
    end
    
    return false, 'invalid'
end

--- Función para verificar si una IP está en un rango CIDR
--- @param ip string IP a verificar
--- @param cidr string Rango CIDR (ej: 192.168.1.0/24)
--- @return boolean
function IsIPInCIDR(ip, cidr)
    local network, mask = cidr:match('([^/]+)/(%d+)')
    if not network or not mask then
        return false
    end
    
    mask = tonumber(mask)
    if not mask or mask < 0 or mask > 32 then
        return false
    end
    
    -- Convertir IPs a números
    local function ipToNumber(ipStr)
        local parts = {}
        for part in ipStr:gmatch('(%d+)') do
            table.insert(parts, tonumber(part))
        end
        if #parts ~= 4 then return nil end
        return (parts[1] << 24) + (parts[2] << 16) + (parts[3] << 8) + parts[4]
    end
    
    local ipNum = ipToNumber(ip)
    local networkNum = ipToNumber(network)
    
    if not ipNum or not networkNum then
        return false
    end
    
    local maskNum = (0xFFFFFFFF << (32 - mask)) & 0xFFFFFFFF
    
    return (ipNum & maskNum) == (networkNum & maskNum)
end

--- Función para obtener información geográfica de una IP
--- @param ip string IP a consultar
--- @return table Información geográfica
function GetIPGeolocation(ip)
    return {
        country = 'Unknown',
        countryCode = 'XX',
        region = 'Unknown',
        city = 'Unknown',
        isp = 'Unknown',
        timezone = 'Unknown'
    }
end

-- ═══════════════════════════════════════════════════════════════
--                    UTILIDADES DE TIEMPO
-- ═══════════════════════════════════════════════════════════════

--- Función para formatear tiempo transcurrido
--- @param seconds number Segundos transcurridos
--- @return string Tiempo formateado
function FormatUptime(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if days > 0 then
        return string.format('%dd %dh %dm %ds', days, hours, minutes, secs)
    elseif hours > 0 then
        return string.format('%dh %dm %ds', hours, minutes, secs)
    elseif minutes > 0 then
        return string.format('%dm %ds', minutes, secs)
    else
        return string.format('%ds', secs)
    end
end

--- Función para obtener timestamp formateado
--- @param format string Formato de fecha (opcional)
--- @return string Timestamp formateado
function GetFormattedTimestamp(format)
    format = format or '%Y-%m-%d %H:%M:%S'
    return os.date(format)
end

-- ═══════════════════════════════════════════════════════════════
--                    UTILIDADES DE CADENAS
-- ═══════════════════════════════════════════════════════════════

--- Función para escapar caracteres especiales en JSON
--- @param str string Cadena a escapar
--- @return string Cadena escapada
function EscapeJSON(str)
    if not str then return '' end
    
    local replacements = {
        ['\\'] = '\\\\',
        ['"'] = '\\"',
        ['/'] = '\\/',
        ['\b'] = '\\b',
        ['\f'] = '\\f',
        ['\n'] = '\\n',
        ['\r'] = '\\r',
        ['\t'] = '\\t'
    }
    
    return str:gsub('[\\"/%c]', replacements)
end

--- Función para truncar texto
--- @param text string Texto a truncar
--- @param maxLength number Longitud máxima
--- @param suffix string Sufijo para texto truncado
--- @return string Texto truncado
function TruncateText(text, maxLength, suffix)
    suffix = suffix or '...'
    if not text or #text <= maxLength then
        return text or ''
    end
    return text:sub(1, maxLength - #suffix) .. suffix
end

--- Función para capitalizar primera letra
--- @param str string Cadena a capitalizar
--- @return string Cadena capitalizada
function Capitalize(str)
    if not str or #str == 0 then return str end
    return str:sub(1, 1):upper() .. str:sub(2):lower()
end

-- ═══════════════════════════════════════════════════════════════
--                    UTILIDADES DE TABLAS
-- ═══════════════════════════════════════════════════════════════

--- Función para clonar tabla profundamente
--- @param original table Tabla original
--- @return table Tabla clonada
function DeepCloneTable(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in next, original, nil do
            copy[DeepCloneTable(key)] = DeepCloneTable(value)
        end
        setmetatable(copy, DeepCloneTable(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

--- Función para fusionar tablas
--- @param target table Tabla destino
--- @param source table Tabla fuente
--- @return table Tabla fusionada
function MergeTables(target, source)
    for key, value in pairs(source) do
        if type(value) == 'table' and type(target[key]) == 'table' then
            target[key] = MergeTables(target[key], value)
        else
            target[key] = value
        end
    end
    return target
end

--- Función para verificar si tabla está vacía
--- @param tbl table Tabla a verificar
--- @return boolean
function IsTableEmpty(tbl)
    return next(tbl) == nil
end

--- Función para contar elementos en tabla
--- @param tbl table Tabla a contar
--- @return number Número de elementos
function CountTableElements(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- ═══════════════════════════════════════════════════════════════
--                    UTILIDADES DE VALIDACIÓN
-- ═══════════════════════════════════════════════════════════════

--- Función para validar URL
--- @param url string URL a validar
--- @return boolean
function IsValidURL(url)
    if not url or type(url) ~= 'string' then
        return false
    end
    
    local pattern = '^https?://[%w%-%.]+[%w%-%.%/%?%&%=%#]*$'
    return url:match(pattern) ~= nil
end

--- Función para validar Steam ID
--- @param steamId string Steam ID a validar
--- @return boolean
function IsValidSteamID(steamId)
    if not steamId or type(steamId) ~= 'string' then
        return false
    end
    
    -- Steam64 ID pattern
    local pattern = '^7656119[0-9]{10}$'
    return steamId:match(pattern) ~= nil
end

--- Función para validar código de país
--- @param countryCode string Código de país
--- @return boolean
function IsValidCountryCode(countryCode)
    if not countryCode or type(countryCode) ~= 'string' then
        return false
    end
    
    -- ISO 3166-1 alpha-2 pattern
    return #countryCode == 2 and countryCode:match('^[A-Z][A-Z]$') ~= nil
end

-- ═══════════════════════════════════════════════════════════════
--                    UTILIDADES DE ARCHIVOS
-- ═══════════════════════════════════════════════════════════════

--- Función para escribir log a archivo
--- @param filename string Nombre del archivo
--- @param content string Contenido a escribir
--- @param append boolean Si agregar al final del archivo
function WriteToFile(filename, content, append)
    -- Esta función sería implementada usando las funciones nativas de FiveM
    -- Por ahora solo registramos en consola
    if Config.Debug then
        print(string.format('[FILE_WRITE] %s: %s', filename, content))
    end
end

--- Función para leer archivo
--- @param filename string Nombre del archivo
--- @return string|nil Contenido del archivo
function ReadFromFile(filename)
    -- Esta función sería implementada usando las funciones nativas de FiveM
    if Config.Debug then
        print(string.format('[FILE_READ] %s', filename))
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════
--                    UTILIDADES DE WEBHOOK
-- ═══════════════════════════════════════════════════════════════

--- Función para enviar webhook a Discord
--- @param webhookUrl string URL del webhook
--- @param data table Datos a enviar
--- @param callback function Función de callback
function SendDiscordWebhook(webhookUrl, data, callback)
    if not IsValidURL(webhookUrl) then
        if callback then callback(false, 'URL de webhook inválida') end
        return
    end
    
    local payload = {
        username = data.username or 'Hz_FysoBlockVPN',
        avatar_url = data.avatar_url,
        content = data.content,
        embeds = data.embeds
    }
    
    PerformHttpRequest(webhookUrl, function(err, text, headers)
        local success = err == 200 or err == 204
        if callback then
            callback(success, success and 'Webhook enviado' or ('Error HTTP: ' .. tostring(err)))
        end
    end, 'POST', json.encode(payload), {
        ['Content-Type'] = 'application/json'
    })
end

--- Función para crear embed de Discord
--- @param title string Título del embed
--- @param description string Descripción
--- @param color number Color del embed
--- @param fields table Campos adicionales
--- @return table Embed formateado
function CreateDiscordEmbed(title, description, color, fields)
    local embed = {
        title = title,
        description = description,
        color = color or 16711680, -- Rojo por defecto
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        footer = {
            text = 'Hz_FysoBlockVPN v' .. Config.Developer.version,
            icon_url = 'https://cdn.discordapp.com/emojis/123456789.png' -- Icono personalizado
        }
    }
    
    if fields and type(fields) == 'table' then
        embed.fields = fields
    end
    
    return embed
end

-- ═══════════════════════════════════════════════════════════════
--                    UTILIDADES DE RENDIMIENTO
-- ═══════════════════════════════════════════════════════════════

--- Función para medir tiempo de ejecución
--- @param func function Función a medir
--- @param ... any Argumentos para la función
--- @return any, number Resultado de la función y tiempo en ms
function MeasureExecutionTime(func, ...)
    local startTime = GetGameTimer()
    local result = func(...)
    local endTime = GetGameTimer()
    return result, endTime - startTime
end

--- Función para limitar tasa de ejecución
local rateLimiters = {}

--- @param key string Clave única para el limitador
--- @param maxCalls number Máximo número de llamadas
--- @param timeWindow number Ventana de tiempo en segundos
--- @return boolean Si la llamada está permitida
function RateLimit(key, maxCalls, timeWindow)
    local currentTime = os.time()
    
    if not rateLimiters[key] then
        rateLimiters[key] = {
            calls = {},
            count = 0
        }
    end
    
    local limiter = rateLimiters[key]
    
    -- Limpiar llamadas antiguas
    local validCalls = {}
    for _, callTime in ipairs(limiter.calls) do
        if currentTime - callTime < timeWindow then
            table.insert(validCalls, callTime)
        end
    end
    
    limiter.calls = validCalls
    limiter.count = #validCalls
    
    -- Verificar límite
    if limiter.count >= maxCalls then
        return false
    end
    
    -- Agregar nueva llamada
    table.insert(limiter.calls, currentTime)
    limiter.count = limiter.count + 1
    
    return true
end

-- ═══════════════════════════════════════════════════════════════
--                    UTILIDADES DE CONFIGURACIÓN
-- ═══════════════════════════════════════════════════════════════

--- Función para validar configuración
--- @return boolean, table Válida y errores encontrados
function ValidateConfig()
    local errors = {}
    
    -- Validar configuración básica
    if not Config.ServerName or #Config.ServerName == 0 then
        table.insert(errors, 'ServerName no puede estar vacío')
    end
    
    -- Validar APIs
    if not Config.APIs or #Config.APIs == 0 then
        table.insert(errors, 'Debe configurar al menos una API')
    else
        for i, api in ipairs(Config.APIs) do
            if not api.name or #api.name == 0 then
                table.insert(errors, string.format('API %d: nombre requerido', i))
            end
            if not api.url or not IsValidURL(api.url) then
                table.insert(errors, string.format('API %d: URL inválida', i))
            end
        end
    end
    
    -- Validar botones
    if Config.Buttons then
        for i, button in ipairs(Config.Buttons) do
            if not button.title or #button.title == 0 then
                table.insert(errors, string.format('Botón %d: título requerido', i))
            end
            if not button.url or not IsValidURL(button.url) then
                table.insert(errors, string.format('Botón %d: URL inválida', i))
            end
        end
    end
    
    -- Validar países
    if Config.CountryCheck.enabled and Config.CountryCheck.countries then
        for i, country in ipairs(Config.CountryCheck.countries) do
            if not IsValidCountryCode(country) then
                table.insert(errors, string.format('Código de país inválido: %s', country))
            end
        end
    end
    
    return #errors == 0, errors
end

--- Función para obtener configuración por defecto
--- @return table Configuración por defecto
function GetDefaultConfig()
    return {
        ServerName = 'Mi Servidor FiveM',
        Debug = false,
        VersionCheck = true,
        Detection = {
            vpn_enabled = true,
            proxy_enabled = true,
            hosting_enabled = true,
            tor_enabled = true,
            cache_enabled = true,
            cache_duration = 3600,
            max_retries = 3
        }
    }
end

-- ═══════════════════════════════════════════════════════════════
--                    INICIALIZACIÓN DE UTILIDADES
-- ═══════════════════════════════════════════════════════════════

-- Validar configuración al cargar
Citizen.CreateThread(function()
    local isValid, errors = ValidateConfig()
    
    if not isValid then
        print('^1[Hz_FysoBlockVPN] Errores en la configuración:^0')
        for _, error in ipairs(errors) do
            print('^1  - ' .. error .. '^0')
        end
        print('^3[Hz_FysoBlockVPN] Por favor, corrige los errores antes de continuar^0')
    else
        print('^2[Hz_FysoBlockVPN] Configuración validada correctamente^0')
    end
end)