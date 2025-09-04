local ls = require "luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require "luasnip.util.events"
local ai = require "luasnip.nodes.absolute_indexer"
local fmt = require("luasnip.extras.fmt").fmt
local postfix = require("luasnip.extras.postfix").postfix

local function snakeize(args) return string.lower(string.gsub(args[1][1], "%u", "_%1")) end
local namefile = function()
  return f(function(_args, snip)
    local name = vim.split(snip.snippet.env.TM_FILENAME, ".", true)
    return name[1] or ""
  end)
end

return {
  s(
    { trig = "__te", dscr = "Generic boilerplate for simple Php Unit Test" },
    fmt(
      [[
        /**
         * @test
         * {}
         * @group {}
         */
        public function {}(): void
        {{
            {}
        }}
      ]],
      {
        f(snakeize, { 1 }),
        namefile(),
        i(1, "testName"),
        i(0),
      }
    )
  ),
}
