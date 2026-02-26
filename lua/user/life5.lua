local M = {}

function M.setup()
  vim.api.nvim_create_user_command("Life5Run", function()

    -- 1️⃣ Eliminar líneas que no contengan "message"
    vim.cmd([[g!/message/d]])

    -- 2️⃣ Para todas las líneas:
    --    inicio línea → borrar 6 palabras → final línea → borrar 2 caracteres
    vim.cmd([[%normal! 0d6w$h2x]])

    -- 3️⃣ Sustituciones finales
    vim.cmd([[%s/SCOR_PRE_RENEWAL --- date/## SCOR_PRE_RENEWAL ## date/g]])
    vim.cmd([[%s@subscriptionId: @subscriptionId: https://admin.life5.com/en/admin/subscription/view/@]])
    vim.cmd([[%s/SCOR_PRE_RENEWAL --- email/email/g]])



    -- Insertar encima: línea en blanco, ### RESUME, ```text
    vim.cmd([[
      g/SCOR_PRE_RENEWAL --- Finished\. Total:/call append(line('.')-1, ['', '### RESUME', '```'])
    ]])

    -- Insertar debajo: ```
    vim.cmd([[
      g/SCOR_PRE_RENEWAL --- Finished\. Total:/call append(line('.'), ['```'])
    ]])
   -- paso añadido: para cada línea con ## SCOR_PRE_RENEWAL ## date:
    vim.cmd([[
      g/## SCOR_PRE_RENEWAL ## date:/call append(line('.'), ['```', '```'])
    ]])

    -- --------------------------------------------------------
    -- NUEVO: insertar bloque TRAITS antes de la primera coincidencia
    -- --------------------------------------------------------

    -- Buscar la primera línea que coincida con el patrón
    local first = vim.fn.search(
      "SCOR_PRE_RENEWAL --- Purchase traits updated for lead ulid",
      "nw"
    )
    if first > 0 then
      -- append() inserta líneas debajo de la línea indicada.
      -- Para insertar antes de 'first', usamos first-1.
      -- Vemos en la documentación y ejemplos que append()
      -- añade las líneas justo después de la línea especificada. :contentReference[oaicite:0]{index=0}
      vim.api.nvim_buf_set_lines(
        0,               -- buffer actual
        first - 1,       -- índice donde insertar
        first - 1,       -- la misma línea, no reemplazar nada
        false,           -- no usar strict_indexing
        {                -- líneas a insertar
          "",
          "### TRAITS",
          "```",
          "```",
        }
      )
    end

  end, {})
end

return M


-- %normal! 0d6w$h2x
-- Para cada línea:
-- 0 → inicio de línea
-- d6w → borra 6 palabras
-- $ → final de línea
-- h → retrocede 1 carácter (para quedar en el penúltimo)
-- 2x → borra los últimos 2 caracteres
