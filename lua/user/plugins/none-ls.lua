return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    local formatting = null_ls.builtins.formatting
    local diagnostics = null_ls.builtins.diagnostics

    null_ls.setup({
      debug = true,
      sources = {
        diagnostics.twigcs,
        diagnostics.phpstan.with({
          command = "./vendor/bin/phpstan"
        }),
        diagnostics.yamllint.with({
          extra_args = { "-d { extends: default, rules: {line-length: {max: 120}}}" }
        }),
        diagnostics.phpcs.with({
          command = "./vendor/bin/phpcs",
          extra_args = { "--standard=PSR12" }
        }),
        formatting.prettier,
        diagnostics.staticcheck,
        diagnostics.zsh,
        diagnostics.npm_groovy_lint,
        diagnostics.semgrep.with({ filetypes = {"go"}, extra_args = { "--config=auto" }}),
        formatting.xmllint,
        diagnostics.stylelint,
        formatting.stylelint,
        formatting.tidy,
        formatting.black.with({ extra_args = { "--fast" } }),
        formatting.stylua,
        formatting.yamlfmt,
        formatting.phpcbf.with({ extra_args = { "--standard=PSR12" } }),
        formatting.shfmt
      },
    })
  end
}
