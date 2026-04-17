return {
  "norcalli/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("colorizer").setup({
      "*", -- highlight all filetypes
      css = { rgb_fn = true }, -- enable rgb() and rgba() in css
      html = { names = false }, -- disable color names like "Blue" in html
    }, {
      mode = "background", -- display as colored background (default)
    })
  end,
}
