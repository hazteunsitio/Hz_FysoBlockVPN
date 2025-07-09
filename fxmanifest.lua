--[[
    Script: Hz_FysoBlockVPN
    Desarrollado por: HZ - CodigosParaJuegos - FiveMSoluciones
    Descripción: Sistema avanzado de detección y bloqueo de VPN/Proxy para servidores FiveM
    Versión: 2.0.0
--]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'HZ - CodigosParaJuegos - FiveMSoluciones'
description 'Sistema avanzado de detección y bloqueo de VPN/Proxy para FiveM con múltiples APIs y funciones mejoradas'
version '2.0.0'
url 'https://github.com/HZ-CodigosParaJuegos'

server_only 'yes'

server_scripts {
    'config.lua',
    'server/main.lua',
    'server/utils.lua',
    'server/api_handler.lua'
}

files {
    'README.md'
}

dependencies {
    'yarn',
    'webpack'
}