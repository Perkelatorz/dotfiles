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

    -- Clean, minimal header
    dashboard.section.header.val = {
      "",
      "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
      "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
      "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
      "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
      "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
      "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
      "",
    }

    -- Colorful button layout with icons
    dashboard.section.buttons.val = {
      dashboard.button("e", "  󰈔  New File", "<cmd>ene<CR>"),
      dashboard.button("f", "  󰱼  Find File", "<cmd>Telescope find_files<CR>"),
      dashboard.button("r", "  󰄉  Recent Files", "<cmd>Telescope oldfiles<CR>"),
      dashboard.button("s", "  󰁯  Restore Session", "<cmd>SessionRestore<CR>"),
      dashboard.button("g", "  󰊢  Find Word", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("q", "  󰗼  Quit", "<cmd>qa<CR>"),
    }
    
    -- Add colors to buttons
    dashboard.section.buttons.opts.hl = "AlphaButton"
    dashboard.section.buttons.opts.hl_shortcut = "AlphaShortcut"

    -- Footer with stats
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
      "  󰨳  " .. get_plugin_count() .. " plugins loaded",
    }
    
    -- Set colors for better integration
    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.buttons.opts.hl = "AlphaButton"
    dashboard.section.footer.opts.hl = "AlphaFooter"

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
