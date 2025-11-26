return {
  "windwp/nvim-autopairs",
  event = { "InsertEnter" },
  dependencies = {
    "hrsh7th/nvim-cmp",
  },
  config = function()
    local utils = require("nvim.core.utils")
    
    -- import nvim-autopairs
    local autopairs, autopairs_ok = utils.safe_require("nvim-autopairs")
    if not autopairs_ok then
      return
    end

    -- configure autopairs
    autopairs.setup({
      check_ts = true, -- enable treesitter
      ts_config = {
        lua = { "string" }, -- don't add pairs in lua string treesitter nodes
        javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
        java = false, -- don't check treesitter on java
      },
    })

    -- Wait for cmp to be available and integrate
    local function setup_cmp_integration()
      local cmp_autopairs, cmp_autopairs_ok = utils.safe_require("nvim-autopairs.completion.cmp")
      if not cmp_autopairs_ok then
        return
      end

      local cmp, cmp_ok = utils.safe_require("cmp")
      if cmp_ok then
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end

    -- Try to setup immediately, or wait for cmp to load
    if utils.is_available("cmp") then
      setup_cmp_integration()
    else
      -- Wait for cmp to load
      vim.api.nvim_create_autocmd("User", {
        pattern = "CmpLoaded",
        callback = setup_cmp_integration,
        once = true,
      })
    end
  end,
}
