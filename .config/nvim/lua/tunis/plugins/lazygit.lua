return {
    "kdheepak/lazygit.nvim",
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    -- floating window border decoration
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended
    -- so the plugin is loaded when the command is run for the 1st time
    keys = {
        { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    },
}
