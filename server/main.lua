--[[
    Archivo Principal del Servidor - Hz_FysoBlockVPN
    Desarrollado por: HZ - CodigosParaJuegos - FiveMSoluciones
    
    Sistema avanzado de detección y bloqueo de VPN/Proxy para FiveM
    Características:
    - Múltiples APIs de verificación
    - Sistema de cache inteligente
    - Whitelist avanzada
    - Verificación por países
    - Adaptive Cards mejoradas
    - Sistema de logs completo
--]]

-- ═══════════════════════════════════════════════════════════════
--                    VARIABLES GLOBALES
-- ═══════════════════════════════════════════════════════════════

local HzBlockVPN = {
    cache = {},
    stats = {
        total_checks = 0,
        blocked_connections = 0,
        allowed_connections = 0,
        api_errors = 0,
        cache_hits = 0
    },
    active_checks = 0,
    start_time = os.time()
}

-- ═══════════════════════════════════════════════════════════════
--                    FUNCIONES DE UTILIDAD
-- ═══════════════════════════════════════════════════════════════

--- Función para logging con diferentes niveles
--- @param level string Nivel del log (INFO, WARN, ERROR, DEBUG)
--- @param message string Mensaje a registrar
--- @param data table Datos adicionales opcionales
local function Log(level, message, data)
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local prefix = string.format('[%s][Hz_FysoBlockVPN][%s]', timestamp, level)
    
    if level == 'ERROR' then
        print(string.format('%s ^1%s^0', prefix, message))
    elseif level == 'WARN' then
        print(string.format('%s ^3%s^0', prefix, message))
    elseif level == 'INFO' then
        print(string.format('%s ^2%s^0', prefix, message))
    elseif level == 'DEBUG' and Config.Debug then
        print(string.format('%s ^5%s^0', prefix, message))
    end
    
    -- Escribir a archivo si está habilitado
    if Config.Advanced.logging.enabled then
        -- Aquí se implementaría la escritura a archivo
    end
end

--- Función para validar IP
--- @param ip string IP a validar
--- @return boolean
local function IsValidIP(ip)
    if not ip then return false end
    
    -- Remover puerto si existe
    ip = ip:match('([^:]+)')
    
    -- Validar formato IPv4
    local parts = {}
    for part in ip:gmatch('(%d+)') do
        local num = tonumber(part)
        if not num or num < 0 or num > 255 then
            return false
        end
        table.insert(parts, num)
    end
    
    return #parts == 4
end

--- Función para verificar si una IP está en whitelist
--- @param ip string IP a verificar
--- @param steamId string Steam ID del jugador
--- @return boolean
local function IsWhitelisted(ip, steamId)
    if not Config.Whitelist.enabled then return false end
    
    -- Verificar IP específica
    for _, whitelistedIP in ipairs(Config.Whitelist.ips) do
        if ip == whitelistedIP then
            return true
        end
        
        -- Verificar rangos CIDR (implementación básica)
        if whitelistedIP:match('/') then
            local network, mask = whitelistedIP:match('([^/]+)/(%d+)')
            -- Aquí se implementaría la verificación CIDR completa
        end
    end
    
    -- Verificar Steam ID
    if steamId then
        for _, whitelistedSteam in ipairs(Config.Whitelist.steam_ids) do
            if steamId == whitelistedSteam then
                return true
            end
        end
    end
    
    return false
end

--- Función para verificar si un país está permitido
--- @param countryCode string Código del país
--- @return boolean
local function IsCountryAllowed(countryCode)
    if not Config.CountryCheck.enabled or not countryCode then
        return true
    end
    
    local isInList = false
    for _, country in ipairs(Config.CountryCheck.countries) do
        if country == countryCode then
            isInList = true
            break
        end
    end
    
    if Config.CountryCheck.mode == 'whitelist' then
        return isInList
    else -- blacklist
        return not isInList
    end
end

--- Función para limpiar cache antiguo
local function CleanupCache()
    local currentTime = os.time()
    local cleaned = 0
    
    for ip, data in pairs(HzBlockVPN.cache) do
        if currentTime - data.timestamp > Config.Detection.cache_duration then
            HzBlockVPN.cache[ip] = nil
            cleaned = cleaned + 1
        end
    end
    
    if cleaned > 0 then
        Log('DEBUG', string.format('Cache limpiado: %d entradas eliminadas', cleaned))
    end
end

--- Función para obtener información del cache
--- @param ip string IP a buscar
--- @return table|nil
local function GetFromCache(ip)
    if not Config.Detection.cache_enabled then return nil end
    
    local cached = HzBlockVPN.cache[ip]
    if cached and (os.time() - cached.timestamp) <= Config.Detection.cache_duration then
        HzBlockVPN.stats.cache_hits = HzBlockVPN.stats.cache_hits + 1
        Log('DEBUG', string.format('Cache hit para IP: %s', ip))
        return cached.data
    end
    
    return nil
end

--- Función para guardar en cache
--- @param ip string IP a guardar
--- @param data table Datos a guardar
local function SaveToCache(ip, data)
    if not Config.Detection.cache_enabled then return end
    
    -- Verificar límite de cache
    local cacheSize = 0
    for _ in pairs(HzBlockVPN.cache) do
        cacheSize = cacheSize + 1
    end
    
    if cacheSize >= Config.Detection.cache_max_size then
        CleanupCache()
    end
    
    HzBlockVPN.cache[ip] = {
        data = data,
        timestamp = os.time()
    }
    
    Log('DEBUG', string.format('Datos guardados en cache para IP: %s', ip))
end

--- Función para crear Adaptive Card
--- @param cardType string Tipo de tarjeta ('vpn' o 'country')
--- @return table
local function CreateAdaptiveCard(cardType)
    local config = cardType == 'vpn' and Config.Locales.vpn_detected or Config.Locales.country_blocked
    
    local card = {
        ['$schema'] = 'http://adaptivecards.io/schemas/adaptive-card.json',
        ['type'] = 'AdaptiveCard',
        ['version'] = '1.6',
        ['body'] = {
            {
                ['type'] = 'Container',
                ['style'] = 'emphasis',
                ['items'] = {
                    {
                        ['type'] = 'TextBlock',
                        ['text'] = Config.ServerName,
                        ['weight'] = 'bolder',
                        ['size'] = 'large',
                        ['horizontalAlignment'] = 'center',
                        ['color'] = 'light'
                    }
                }
            },
            {
                ['type'] = 'TextBlock',
                ['text'] = config.title,
                ['weight'] = 'bolder',
                ['size'] = 'medium',
                ['horizontalAlignment'] = 'center',
                ['color'] = 'attention',
                ['spacing'] = 'medium'
            },
            {
                ['type'] = 'TextBlock',
                ['text'] = config.message,
                ['size'] = 'default',
                ['horizontalAlignment'] = 'center',
                ['wrap'] = true,
                ['spacing'] = 'medium'
            }
        }
    }
    
    -- Agregar botones si existen
    if Config.Buttons and #Config.Buttons > 0 then
        local actions = {}
        for _, button in ipairs(Config.Buttons) do
            table.insert(actions, {
                ['type'] = 'Action.OpenUrl',
                ['title'] = button.title,
                ['url'] = button.url,
                ['style'] = button.style or 'default'
            })
        end
        
        table.insert(card.body, {
            ['type'] = 'ActionSet',
            ['horizontalAlignment'] = 'center',
            ['spacing'] = 'medium',
            ['actions'] = actions
        })
    end
    
    return card
end

--- Función para manejar el rechazo de conexión
--- @param deferrals table Objeto de deferrals
--- @param reason string Razón del rechazo
--- @param cardType string Tipo de tarjeta adaptativa
local function HandleRejection(deferrals, reason, cardType)
    HzBlockVPN.stats.blocked_connections = HzBlockVPN.stats.blocked_connections + 1
    
    if Config.UI.adaptive_card then
        local card = CreateAdaptiveCard(cardType)
        deferrals.presentCard(card)
    else
        deferrals.done(reason)
    end
end

--- Función para procesar respuesta de API
--- @param data table Datos de la API
--- @param apiName string Nombre de la API
--- @return table Resultado procesado
local function ProcessAPIResponse(data, apiName)
    local result = {
        isVPN = false,
        isProxy = false,
        isHosting = false,
        isTor = false,
        countryCode = nil,
        isp = nil,
        asn = nil
    }
    
    if apiName == 'ip-api' then
        if data.status == 'success' then
            result.isVPN = data.proxy or false
            result.isProxy = data.proxy or false
            result.isHosting = data.hosting or false
            result.countryCode = data.countryCode
            result.isp = data.isp
            result.asn = data.as
        end
    elseif apiName == 'vpnapi' then
        result.isVPN = data.security and data.security.vpn or false
        result.isProxy = data.security and data.security.proxy or false
        result.isTor = data.security and data.security.tor or false
        result.countryCode = data.location and data.location.country_code
    elseif apiName == 'proxycheck' then
        if data[1] then
            local ipData = data[1]
            result.isVPN = ipData.proxy == 'yes'
            result.isProxy = ipData.proxy == 'yes'
            result.countryCode = ipData.country
        end
    end
    
    return result
end

-- ═══════════════════════════════════════════════════════════════
--                    EVENTO PRINCIPAL
-- ═══════════════════════════════════════════════════════════════

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    local playerIP = GetPlayerEndpoint(src)
    local steamId = nil
    
    -- Obtener Steam ID
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local identifier = GetPlayerIdentifier(src, i)
        if identifier and identifier:match('steam:') then
            steamId = identifier:gsub('steam:', '')
            break
        end
    end
    
    deferrals.defer()
    deferrals.update(Config.Locales.checking)
    
    HzBlockVPN.stats.total_checks = HzBlockVPN.stats.total_checks + 1
    HzBlockVPN.active_checks = HzBlockVPN.active_checks + 1
    
    Log('INFO', string.format('Verificando conexión: %s (%s)', name, playerIP))
    
    -- Validar IP
    if not IsValidIP(playerIP) then
        Log('ERROR', string.format('IP inválida detectada: %s', playerIP or 'nil'))
        deferrals.done(Config.Locales.api_error)
        HzBlockVPN.active_checks = HzBlockVPN.active_checks - 1
        return
    end
    
    -- Verificar whitelist
    if IsWhitelisted(playerIP, steamId) then
        Log('INFO', string.format('IP en whitelist: %s', playerIP))
        deferrals.done()
        HzBlockVPN.stats.allowed_connections = HzBlockVPN.stats.allowed_connections + 1
        HzBlockVPN.active_checks = HzBlockVPN.active_checks - 1
        return
    end
    
    -- Verificar cache
    local cachedResult = GetFromCache(playerIP)
    if cachedResult then
        if cachedResult.blocked then
            Log('INFO', string.format('IP bloqueada (cache): %s - Razón: %s', playerIP, cachedResult.reason))
            HandleRejection(deferrals, cachedResult.reason, cachedResult.cardType)
        else
            Log('INFO', string.format('IP permitida (cache): %s', playerIP))
            deferrals.done()
            HzBlockVPN.stats.allowed_connections = HzBlockVPN.stats.allowed_connections + 1
        end
        HzBlockVPN.active_checks = HzBlockVPN.active_checks - 1
        return
    end
    
    -- Verificar límite de verificaciones concurrentes
    if HzBlockVPN.active_checks > Config.Advanced.performance.max_concurrent_checks then
        Log('WARN', 'Límite de verificaciones concurrentes alcanzado')
        deferrals.done(Config.Locales.api_error)
        HzBlockVPN.active_checks = HzBlockVPN.active_checks - 1
        return
    end
    
    deferrals.update(Config.Locales.checking_vpn)
    
    -- Llamar al manejador de APIs
    CheckIPWithAPIs(playerIP, function(success, result, error)
        HzBlockVPN.active_checks = HzBlockVPN.active_checks - 1
        
        if not success then
            Log('ERROR', string.format('Error en verificación de IP %s: %s', playerIP, error or 'Desconocido'))
            HzBlockVPN.stats.api_errors = HzBlockVPN.stats.api_errors + 1
            deferrals.done(Config.Locales.api_error)
            return
        end
        
        local blocked = false
        local reason = ''
        local cardType = 'vpn'
        
        -- Verificar detecciones habilitadas
        if Config.Detection.vpn_enabled and result.isVPN then
            blocked = true
            reason = Config.Locales.vpn_detected.title .. '\n' .. Config.Locales.vpn_detected.message
        elseif Config.Detection.proxy_enabled and result.isProxy then
            blocked = true
            reason = Config.Locales.vpn_detected.title .. '\n' .. Config.Locales.vpn_detected.message
        elseif Config.Detection.hosting_enabled and result.isHosting then
            blocked = true
            reason = Config.Locales.vpn_detected.title .. '\n' .. Config.Locales.vpn_detected.message
        elseif Config.Detection.tor_enabled and result.isTor then
            blocked = true
            reason = Config.Locales.vpn_detected.title .. '\n' .. Config.Locales.vpn_detected.message
        end
        
        -- Verificar país si no está bloqueado por VPN
        if not blocked and not IsCountryAllowed(result.countryCode) then
            blocked = true
            reason = Config.Locales.country_blocked.title .. '\n' .. Config.Locales.country_blocked.message
            cardType = 'country'
        end
        
        -- Guardar resultado en cache
        SaveToCache(playerIP, {
            blocked = blocked,
            reason = reason,
            cardType = cardType,
            result = result
        })
        
        if blocked then
            Log('INFO', string.format('Conexión bloqueada: %s (%s) - %s', name, playerIP, reason:gsub('\n', ' ')))
            HandleRejection(deferrals, reason, cardType)
        else
            Log('INFO', string.format('Conexión permitida: %s (%s)', name, playerIP))
            deferrals.done()
            HzBlockVPN.stats.allowed_connections = HzBlockVPN.stats.allowed_connections + 1
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════════
--                    COMANDOS DE ADMINISTRACIÓN
-- ═══════════════════════════════════════════════════════════════

RegisterCommand('hzblockvpn', function(source, args, rawCommand)
    if source ~= 0 then return end -- Solo consola
    
    local subcommand = args[1]
    
    if subcommand == 'stats' then
        local uptime = os.time() - HzBlockVPN.start_time
        print('═══════════════════════════════════════')
        print('        Hz_FysoBlockVPN - Estadísticas')
        print('═══════════════════════════════════════')
        print(string.format('Tiempo activo: %d segundos', uptime))
        print(string.format('Verificaciones totales: %d', HzBlockVPN.stats.total_checks))
        print(string.format('Conexiones bloqueadas: %d', HzBlockVPN.stats.blocked_connections))
        print(string.format('Conexiones permitidas: %d', HzBlockVPN.stats.allowed_connections))
        print(string.format('Errores de API: %d', HzBlockVPN.stats.api_errors))
        print(string.format('Cache hits: %d', HzBlockVPN.stats.cache_hits))
        print(string.format('Verificaciones activas: %d', HzBlockVPN.active_checks))
        print('═══════════════════════════════════════')
    elseif subcommand == 'clearcache' then
        HzBlockVPN.cache = {}
        print('[Hz_FysoBlockVPN] Cache limpiado exitosamente')
    elseif subcommand == 'reload' then
        print('[Hz_FysoBlockVPN] Recargando configuración...')
        -- Aquí se implementaría la recarga de configuración
    else
        print('Comandos disponibles:')
        print('  hzblockvpn stats     - Mostrar estadísticas')
        print('  hzblockvpn clearcache - Limpiar cache')
        print('  hzblockvpn reload    - Recargar configuración')
    end
end, true)

-- ═══════════════════════════════════════════════════════════════
--                    INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    -- Limpiar cache periódicamente
    while true do
        Wait(Config.Advanced.performance.cleanup_interval * 1000)
        CleanupCache()
    end
end)

-- Verificación de versión
if Config.VersionCheck then
    Citizen.CreateThread(function()
        CheckForUpdates()
    end)
end

Log('INFO', string.format('Hz_FysoBlockVPN v%s iniciado correctamente', Config.Developer.version))
Log('INFO', string.format('Desarrollado por: %s', Config.Developer.author))