return {
  "norcalli/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- norcalli/nvim-colorizer is unmaintained and its `ex` command helper calls
    -- vim.tbl_flatten, deprecated since 0.10 and removed in 0.13. Swap in a
    -- vim.iter equivalent before setup() so the warning (and future breakage)
    -- goes away. Lives here rather than in the plugin so :Lazy clean can't undo it.
    require("colorizer/nvim").ex = setmetatable({}, {
      __index = function(self, key)
        local command = key:gsub("_$", "!")
        local run = function(...)
          local parts = vim.iter({ command, ... }):flatten(math.huge):totable()
          return vim.api.nvim_command(table.concat(parts, " "))
        end
        rawset(self, key, run)
        return run
      end,
    })

    require("colorizer").setup({
      "*", -- highlight all filetypes
      css = { rgb_fn = true }, -- enable rgb() and rgba() in css
      html = { names = false }, -- disable color names like "Blue" in html
    }, {
      mode = "background", -- display as colored background (default)
    })
  end,
}
