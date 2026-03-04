return {
  "mrjones2014/smart-splits.nvim",
  init = function()
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader><leader>h", require("smart-splits").resize_left)
    keymap.set("n", "<leader><leader>j", require("smart-splits").resize_down)
    keymap.set("n", "<leader><leader>k", require("smart-splits").resize_up)
    keymap.set("n", "<leader><leader>l", require("smart-splits").resize_right)
    -- moving between splits
    keymap.set("n", "<M-h>", require("smart-splits").move_cursor_left)
    keymap.set("n", "<M-j>", require("smart-splits").move_cursor_down)
    keymap.set("n", "<M-k>", require("smart-splits").move_cursor_up)
    keymap.set("n", "<M-l>", require("smart-splits").move_cursor_right)
  end,
}
