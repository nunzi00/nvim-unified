return {
  "mfussenegger/nvim-dap",
  lazy = true,
  keys = {
    { "<F5>", "<Cmd>lua require'dap'.continue()<CR>", desc = "DAP: Continue" },
    { "<F6>", "<Cmd>lua require'dap'.terminate()<CR>", desc = "DAP: Terminate" },
    { "<F9>", "<Cmd>lua require'dap'.goto_()<CR>", desc = "DAP: Goto" },
    { "<F2>", "<Cmd>lua require'dap'.step_over()<CR>", desc = "DAP: Step Over" },
    { "<F3>", "<Cmd>lua require'dap'.step_into()<CR>", desc = "DAP: Step Into" },
    { "<F4>", "<Cmd>lua require'dap'.step_out()<CR>", desc = "DAP: Step Out" },
    { "<F10>", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", desc = "DAP: Toggle Breakpoint" },
    { "<F11>", "<Cmd>lua require'dap'.clear_breakpoints()<CR>", desc = "DAP: Clear Breakpoints" },
    { "<F12>", "<Cmd>lua require'dap'.list_breakpoints()<CR>", desc = "DAP: List Breakpoints" },
  },
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    local status_ok, dap = pcall(require, "dap")
    if not status_ok then
      return
    end

    -- Load DAP configuration modules
    require('user.dap.virtualtext')
    require('user.dap.ui')
    require('user.dap.php')
    require('user.dap.go')
    require('user.dap.rust')
  end,
}
