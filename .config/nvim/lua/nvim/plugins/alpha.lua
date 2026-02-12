return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local utils = require("nvim.core.utils")
    
    local alpha, alpha_ok = utils.safe_require("alpha")
    if not alpha_ok then
      return
    end
    
    local dashboard, dashboard_ok = utils.safe_require("alpha.themes.dashboard")
    if not dashboard_ok then
      return
    end

    -- Header: Purpleator-style (compact, fits dark purple theme)
    dashboard.section.header.val = {
      "",
      "   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
      "   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
      "   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
      "   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
      "   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
      "   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
      "",
      "   Purpleator  ·  space = leader  ·  space ? = which-key",
      "",
    }

    dashboard.section.buttons.val = {
      dashboard.button("e", "  󰈔  New File", "<cmd>ene<CR>"),
      dashboard.button("f", "  󰱼  Find File", "<cmd>Telescope find_files<CR>"),
      dashboard.button("r", "  󰄉  Recent Files", "<cmd>Telescope oldfiles<CR>"),
      dashboard.button("s", "  󰁯  Restore Session", "<cmd>SessionRestore<CR>"),
      dashboard.button("g", "  󰊢  Find Word", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("q", "  󰗼  Quit", "<cmd>qa<CR>"),
    }

    dashboard.section.buttons.opts.hl = "AlphaButton"
    dashboard.section.buttons.opts.hl_shortcut = "AlphaShortcut"

    local function get_plugin_count()
      local lazy_ok, lazy = pcall(require, "lazy")
      if lazy_ok then
        local stats = lazy.stats()
        return stats.count or 0
      end
      return 0
    end

    dashboard.section.footer.val = {
      "",
      "  󰨳  " .. get_plugin_count() .. " plugins  ·  󰏘  :ColorschemeToggle",
      "",
    }

    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.footer.opts.hl = "AlphaFooter"

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
