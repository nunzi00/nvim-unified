# LSP Migration Task - Session Document

## Objetivo
Migrar de `require('lspconfig')` (deprecated) a `vim.lsp.config` API (nvim 0.11+)

## Error Detectado
```
The `require('lspconfig')` "framework" is deprecated, use vim.lsp.config (see :help lspconfig-nvim-0.11) instead.
Feature will be removed in nvim-lspconfig v3.0.0
```

Ubicación del error: `/home/user/.config/nvim/lua/user/plugins/lsp.lua:50`

## Información Importante

### Archivo Principal
- **Ruta**: `/home/user/.config/nvim/lua/user/plugins/lsp.lua`
- **Línea problemática**: 50 (y otras que usan `lspconfig[server_name].setup()`)

### Servidores LSP Configurados
1. bashls
2. dockerls
3. eslint
4. html
5. jsonls
6. lua_ls
7. sqlls
8. ts_ls
9. vimls
10. yamlls
11. intelephense (PHP - con configuración especial)
12. phpactor (PHP - solo code actions)

### Dependencias
- mason.nvim
- mason-lspconfig.nvim
- nvim-lspconfig
- handlers personalizados en: `user.lsp.handlers`

## Estado Actual
- [x] Documento de sesión creado
- [x] Versión de Neovim verificada (v0.11.5)
- [x] Migración a vim.lsp.config completada
- [x] Pruebas realizadas - LSP funciona correctamente

## Cambios Realizados

### Archivo: `/home/user/.config/nvim/lua/user/plugins/lsp.lua`

**Cambios principales:**
1. Eliminado: `local lspconfig = require("lspconfig")`
2. Reemplazado: `lspconfig[server_name].setup()` → `vim.lsp.config(server_name, config)`
3. Agregado: `vim.lsp.enable(server_name)` para activar cada servidor LSP configurado

**Estructura nueva:**
```lua
-- Configurar servidores usando vim.lsp.config()
vim.lsp.config(server_name, {
  on_attach = handlers.on_attach,
  capabilities = handlers.capabilities,
  -- ... otras opciones
})

-- Auto-start configured LSP servers
for _, server_name in ipairs(servers) do
  vim.lsp.enable(server_name)
end

-- Also enable phpactor
vim.lsp.enable("phpactor")
```

## Notas Técnicas
- Intelephense tiene configuración especial (phpVersion 8.3, formato habilitado)
- Phpactor tiene capabilities deshabilitadas para formatting
- Ambos PHP LSP usan `single_file_support = true`
- Default config incluye: `on_attach` y `capabilities` desde handlers
- La nueva API `vim.lsp.config()` define la configuración del servidor
- `vim.lsp.enable()` activa el servidor para archivos correspondientes

## Resultados de Testing
✅ Test realizado con archivo Lua: LSP clients attached: 2 (lua_ls, null-ls)
✅ No aparecen warnings de deprecación
✅ Configuración carga sin errores

## Resumen Final
Migración exitosa de `require('lspconfig')` (deprecated) a `vim.lsp.config()` (nvim 0.11+):
- Todos los servidores LSP configurados correctamente
- LSP se adjunta automáticamente a los archivos correspondientes
- No hay warnings de deprecación
- Funcionalidad completa mantenida

## Última Actualización
2025-12-04 - Migración completada y testeada exitosamente
