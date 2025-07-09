--[[
    Manejador de APIs - Hz_FysoBlockVPN
    Desarrollado por: HZ - CodigosParaJuegos - FiveMSoluciones
    
    Sistema de consulta a múltiples APIs para detección de VPN/Proxy
    Características:
    - Soporte para múltiples APIs
    - Sistema de fallback automático
    - Rate limiting inteligente
    - Manejo de errores robusto
    - Timeouts configurables
--]]

-- ═══════════════════════════════════════════════════════════════
--                    VARIABLES GLOBALES
-- ═══════════════════════════════════════════════════════════════

local APIHandler = {
    stats = {
        total_requests = 0,
        successful_requests = 0,
        failed_requests = 0,
        api_stats = {}
    },
    rate_limits = {},
    last_cleanup = os.time()
}

-- ═══════════════════════════════════════════════════════════════
--                    FUNCIONES DE UTILIDAD
-- ═══════════════════════════════════════════════════════════════

--- Función para logging específico del manejador de APIs
--- @param level string Nivel del log
--- @param message string Mensaje
--- @param apiName string Nombre de la API (opcional)
local function APILog(level, message, apiName)
    local prefix = apiName and string.format('[API:%s]', apiName) or '[API]'
    local timestamp = os.date('%H:%M:%S')
    
    if level == 'ERROR' then
        print(string.format('[%s]%s ^1%s^0', timestamp, prefix, message))
    elseif level == 'WARN' then
        print(string.format('[%s]%s ^3%s^0', timestamp, prefix, message))
    elseif level == 'INFO' then
        print(string.format('[%s]%s ^2%s^0', timestamp, prefix, message))
    elseif level == 'DEBUG' and Config.Debug then
        print(string.format('[%s]%s ^5%s^0', timestamp, prefix, message))
    end
end

--- Función para limpiar rate limits antiguos
local function CleanupRateLimits()
    local currentTime = os.time()
    local cleaned = 0
    
    for apiName, data in pairs(APIHandler.rate_limits) do
        local validRequests = {}
        for _, requestTime in ipairs(data.requests) do
            if currentTime - requestTime < 60 then -- Mantener últimos 60 segundos
                table.insert(validRequests, requestTime)
            else
                cleaned = cleaned + 1
            end
        end
        APIHandler.rate_limits[apiName].requests = validRequests
    end
    
    if cleaned > 0 then
        APILog('DEBUG', string.format('Rate limits limpiados: %d entradas', cleaned))
    end
end

--- Función para verificar rate limit de una API
--- @param apiName string Nombre de la API
--- @param maxRequests number Máximo de requests por minuto
--- @return boolean Si la request está permitida
local function CheckRateLimit(apiName, maxRequests)
    local currentTime = os.time()
    
    if not APIHandler.rate_limits[apiName] then
        APIHandler.rate_limits[apiName] = {
            requests = {},
            blocked_until = 0
        }
    end
    
    local apiData = APIHandler.rate_limits[apiName]
    
    -- Verificar si está bloqueada temporalmente
    if apiData.blocked_until > currentTime then
        return false
    end
    
    -- Limpiar requests antiguos
    local validRequests = {}
    for _, requestTime in ipairs(apiData.requests) do
        if currentTime - requestTime < 60 then
            table.insert(validRequests, requestTime)
        end
    end
    apiData.requests = validRequests
    
    -- Verificar límite
    if #apiData.requests >= maxRequests then
        APILog('WARN', string.format('Rate limit alcanzado para %s (%d/%d)', apiName, #apiData.requests, maxRequests), apiName)
        apiData.blocked_until = currentTime + 60 -- Bloquear por 1 minuto
        return false
    end
    
    -- Agregar nueva request
    table.insert(apiData.requests, currentTime)
    return true
end

--- Función para obtener estadísticas de una API
--- @param apiName string Nombre de la API
--- @return table Estadísticas
local function GetAPIStats(apiName)
    if not APIHandler.stats.api_stats[apiName] then
        APIHandler.stats.api_stats[apiName] = {
            requests = 0,
            successes = 0,
            failures = 0,
            avg_response_time = 0,
            last_used = 0
        }
    end
    return APIHandler.stats.api_stats[apiName]
end

--- Función para actualizar estadísticas de una API
--- @param apiName string Nombre de la API
--- @param success boolean Si fue exitosa
--- @param responseTime number Tiempo de respuesta en ms
local function UpdateAPIStats(apiName, success, responseTime)
    local stats = GetAPIStats(apiName)
    
    stats.requests = stats.requests + 1
    stats.last_used = os.time()
    
    if success then
        stats.successes = stats.successes + 1
        APIHandler.stats.successful_requests = APIHandler.stats.successful_requests + 1
    else
        stats.failures = stats.failures + 1
        APIHandler.stats.failed_requests = APIHandler.stats.failed_requests + 1
    end
    
    -- Calcular tiempo promedio de respuesta
    if responseTime then
        stats.avg_response_time = (stats.avg_response_time * (stats.requests - 1) + responseTime) / stats.requests
    end
    
    APIHandler.stats.total_requests = APIHandler.stats.total_requests + 1
end

-- ═══════════════════════════════════════════════════════════════
--                    PROCESADORES DE APIs
-- ═══════════════════════════════════════════════════════════════

--- Procesador para ip-api.com
--- @param data table Datos de respuesta
--- @return table Resultado procesado
local function ProcessIPAPI(data)
    local result = {
        isVPN = false,
        isProxy = false,
        isHosting = false,
        isTor = false,
        isMobile = false,
        countryCode = nil,
        country = nil,
        region = nil,
        city = nil,
        isp = nil,
        org = nil,
        asn = nil,
        timezone = nil
    }
    
    if data and data.status == 'success' then
        result.isVPN = data.proxy or false
        result.isProxy = data.proxy or false
        result.isHosting = data.hosting or false
        result.isMobile = data.mobile or false
        result.countryCode = data.countryCode
        result.country = data.country
        result.region = data.regionName
        result.city = data.city
        result.isp = data.isp
        result.org = data.org
        result.asn = data.as
        result.timezone = data.timezone
        
        APILog('DEBUG', string.format('ip-api: proxy=%s, hosting=%s, country=%s', 
            tostring(result.isProxy), tostring(result.isHosting), result.countryCode or 'N/A'))
    else
        APILog('WARN', 'ip-api: Respuesta inválida o error', 'ip-api')
    end
    
    return result
end

--- Procesador para vpnapi.io
--- @param data table Datos de respuesta
--- @return table Resultado procesado
local function ProcessVPNAPI(data)
    local result = {
        isVPN = false,
        isProxy = false,
        isHosting = false,
        isTor = false,
        countryCode = nil,
        country = nil,
        isp = nil
    }
    
    if data and data.security then
        result.isVPN = data.security.vpn or false
        result.isProxy = data.security.proxy or false
        result.isTor = data.security.tor or false
        
        if data.location then
            result.countryCode = data.location.country_code
            result.country = data.location.country
        end
        
        if data.network then
            result.isp = data.network.autonomous_system_organization
        end
        
        APILog('DEBUG', string.format('vpnapi: vpn=%s, proxy=%s, tor=%s', 
            tostring(result.isVPN), tostring(result.isProxy), tostring(result.isTor)))
    else
        APILog('WARN', 'vpnapi: Respuesta inválida', 'vpnapi')
    end
    
    return result
end

--- Procesador para proxycheck.io
--- @param data table Datos de respuesta
--- @return table Resultado procesado
local function ProcessProxyCheck(data)
    local result = {
        isVPN = false,
        isProxy = false,
        isHosting = false,
        countryCode = nil,
        country = nil,
        isp = nil
    }
    
    if data and data.status == 'ok' then
        -- proxycheck.io devuelve los datos con la IP como clave
        for ip, ipData in pairs(data) do
            if type(ipData) == 'table' and ip ~= 'status' then
                result.isVPN = ipData.proxy == 'yes'
                result.isProxy = ipData.proxy == 'yes'
                result.countryCode = ipData.country
                result.isp = ipData.isp
                
                APILog('DEBUG', string.format('proxycheck: proxy=%s, country=%s', 
                    ipData.proxy or 'N/A', ipData.country or 'N/A'))
                break
            end
        end
    else
        APILog('WARN', 'proxycheck: Respuesta inválida', 'proxycheck')
    end
    
    return result
end

-- Mapa de procesadores por API
local API_PROCESSORS = {
    ['ip-api'] = ProcessIPAPI,
    ['vpnapi'] = ProcessVPNAPI,
    ['proxycheck'] = ProcessProxyCheck
}

-- ═══════════════════════════════════════════════════════════════
--                    FUNCIÓN PRINCIPAL DE CONSULTA
-- ═══════════════════════════════════════════════════════════════

--- Función para consultar una API específica
--- @param api table Configuración de la API
--- @param ip string IP a consultar
--- @param callback function Función de callback
local function QuerySingleAPI(api, ip, callback)
    local startTime = GetGameTimer()
    
    -- Verificar rate limit
    if api.ratelimit and not CheckRateLimit(api.name, api.ratelimit) then
        callback(false, nil, 'Rate limit excedido')
        return
    end
    
    -- Construir URL
    local url = string.format(api.url, ip)
    
    APILog('DEBUG', string.format('Consultando %s: %s', api.name, url), api.name)
    
    -- Realizar petición HTTP
    PerformHttpRequest(url, function(err, text, headers)
        local responseTime = GetGameTimer() - startTime
        local success = false
        local result = nil
        local error = nil
        
        if err == 200 then
            local data = json.decode(text)
            if data then
                local processor = API_PROCESSORS[api.name]
                if processor then
                    result = processor(data)
                    success = true
                    APILog('DEBUG', string.format('Respuesta exitosa de %s en %dms', api.name, responseTime), api.name)
                else
                    error = 'Procesador no encontrado para ' .. api.name
                    APILog('ERROR', error, api.name)
                end
            else
                error = 'Error al decodificar JSON'
                APILog('ERROR', string.format('Error JSON en %s: %s', api.name, text or 'nil'), api.name)
            end
        else
            error = string.format('HTTP %d', err)
            APILog('ERROR', string.format('Error HTTP en %s: %d', api.name, err), api.name)
        end
        
        -- Actualizar estadísticas
        UpdateAPIStats(api.name, success, responseTime)
        
        callback(success, result, error)
    end, 'GET', '', {
        ['User-Agent'] = 'Hz_FysoBlockVPN/2.0',
        ['Accept'] = 'application/json'
    })
    
    -- Timeout
    if api.timeout then
        Citizen.SetTimeout(api.timeout, function()
            -- El timeout se maneja automáticamente por PerformHttpRequest
        end)
    end
end

--- Función principal para verificar IP con múltiples APIs
--- @param ip string IP a verificar
--- @param callback function Función de callback (success, result, error)
function CheckIPWithAPIs(ip, callback)
    if not ip or not ValidateIPAddress(ip) then
        callback(false, nil, 'IP inválida')
        return
    end
    
    -- Filtrar APIs habilitadas
    local enabledAPIs = {}
    for _, api in ipairs(Config.APIs) do
        if api.enabled then
            table.insert(enabledAPIs, api)
        end
    end
    
    if #enabledAPIs == 0 then
        callback(false, nil, 'No hay APIs habilitadas')
        return
    end
    
    APILog('INFO', string.format('Verificando IP %s con %d APIs', ip, #enabledAPIs))
    
    local attempts = 0
    local maxAttempts = Config.Detection.max_retries or 3
    
    local function TryNextAPI(apiIndex)
        if apiIndex > #enabledAPIs then
            if attempts < maxAttempts then
                attempts = attempts + 1
                APILog('WARN', string.format('Reintento %d/%d para IP %s', attempts, maxAttempts, ip))
                Citizen.SetTimeout(Config.Detection.retry_delay or 2000, function()
                    TryNextAPI(1)
                end)
            else
                callback(false, nil, 'Todas las APIs fallaron después de ' .. maxAttempts .. ' intentos')
            end
            return
        end
        
        local api = enabledAPIs[apiIndex]
        
        QuerySingleAPI(api, ip, function(success, result, error)
            if success and result then
                APILog('INFO', string.format('Verificación exitosa de %s usando %s', ip, api.name))
                callback(true, result, nil)
            else
                APILog('WARN', string.format('Fallo en %s: %s', api.name, error or 'Error desconocido'), api.name)
                TryNextAPI(apiIndex + 1)
            end
        end)
    end
    
    TryNextAPI(1)
end

-- ═══════════════════════════════════════════════════════════════
--                    FUNCIÓN DE VERIFICACIÓN DE VERSIÓN
-- ═══════════════════════════════════════════════════════════════

--- Función para verificar actualizaciones
function CheckForUpdates()
    if not Config.Developer.update_check_url then
        return
    end
    
    APILog('INFO', 'Verificando actualizaciones...')
    
    PerformHttpRequest(Config.Developer.update_check_url, function(err, text, headers)
        if err == 200 then
            local data = json.decode(text)
            if data and data.tag_name then
                local latestVersion = data.tag_name:gsub('v', '')
                local currentVersion = Config.Developer.version
                
                if latestVersion ~= currentVersion then
                    print('═══════════════════════════════════════')
                    print('^3[Hz_FysoBlockVPN] ¡Nueva versión disponible!^0')
                    print(string.format('^3Versión actual: %s^0', currentVersion))
                    print(string.format('^2Versión disponible: %s^0', latestVersion))
                    print(string.format('^6Descargar: %s^0', data.html_url or Config.Developer.github))
                    print('═══════════════════════════════════════')
                else
                    APILog('INFO', 'Hz_FysoBlockVPN está actualizado')
                end
            end
        else
            APILog('WARN', 'No se pudo verificar actualizaciones')
        end
    end, 'GET', '', {
        ['User-Agent'] = 'Hz_FysoBlockVPN/2.0'
    })
end

-- ═══════════════════════════════════════════════════════════════
--                    COMANDOS DE ADMINISTRACIÓN
-- ═══════════════════════════════════════════════════════════════

RegisterCommand('hzapi', function(source, args, rawCommand)
    if source ~= 0 then return end -- Solo consola
    
    local subcommand = args[1]
    
    if subcommand == 'stats' then
        print('═══════════════════════════════════════')
        print('     Hz_FysoBlockVPN - Estadísticas APIs')
        print('═══════════════════════════════════════')
        print(string.format('Requests totales: %d', APIHandler.stats.total_requests))
        print(string.format('Requests exitosos: %d', APIHandler.stats.successful_requests))
        print(string.format('Requests fallidos: %d', APIHandler.stats.failed_requests))
        print('')
        
        for apiName, stats in pairs(APIHandler.stats.api_stats) do
            local successRate = stats.requests > 0 and (stats.successes / stats.requests * 100) or 0
            print(string.format('API: %s', apiName))
            print(string.format('  Requests: %d | Éxito: %.1f%% | Tiempo promedio: %.0fms', 
                stats.requests, successRate, stats.avg_response_time))
            print(string.format('  Último uso: %s', 
                stats.last_used > 0 and os.date('%H:%M:%S', stats.last_used) or 'Nunca'))
        end
        print('═══════════════════════════════════════')
    elseif subcommand == 'test' then
        local testIP = args[2] or '8.8.8.8'
        print(string.format('Probando APIs con IP: %s', testIP))
        
        CheckIPWithAPIs(testIP, function(success, result, error)
            if success then
                print('^2Prueba exitosa:^0')
                print(string.format('  VPN: %s', tostring(result.isVPN)))
                print(string.format('  Proxy: %s', tostring(result.isProxy)))
                print(string.format('  Hosting: %s', tostring(result.isHosting)))
                print(string.format('  País: %s (%s)', result.country or 'N/A', result.countryCode or 'N/A'))
            else
                print(string.format('^1Error en prueba: %s^0', error or 'Desconocido'))
            end
        end)
    elseif subcommand == 'reset' then
        APIHandler.stats = {
            total_requests = 0,
            successful_requests = 0,
            failed_requests = 0,
            api_stats = {}
        }
        APIHandler.rate_limits = {}
        print('[Hz_FysoBlockVPN] Estadísticas de APIs reiniciadas')
    else
        print('Comandos disponibles:')
        print('  hzapi stats          - Mostrar estadísticas de APIs')
        print('  hzapi test [ip]      - Probar APIs con una IP')
        print('  hzapi reset          - Reiniciar estadísticas')
    end
end, true)

-- ═══════════════════════════════════════════════════════════════
--                    INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════════════

-- Limpiar rate limits periódicamente
Citizen.CreateThread(function()
    while true do
        Wait(60000) -- Cada minuto
        CleanupRateLimits()
    end
end)

APILog('INFO', 'Manejador de APIs inicializado correctamente')
APILog('INFO', string.format('APIs configuradas: %d', #Config.APIs))

local enabledCount = 0
for _, api in ipairs(Config.APIs) do
    if api.enabled then
        enabledCount = enabledCount + 1
        APILog('INFO', string.format('API habilitada: %s', api.name))
    end
end

APILog('INFO', string.format('APIs habilitadas: %d/%d', enabledCount, #Config.APIs))