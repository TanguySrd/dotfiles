return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
        "windwp/nvim-ts-autotag"
    },
    config = function()
        -- import nvim-treesitter plugin
       local treesitter = require("nvim-treesitter.configs")

        -- configure treesitter
        treesitter.setup({ 
            highlight = { enable = true },
            indent = { enable = true },
            autotag = { enable = true },
            -- ensure these language parsers are installed
            ensure_installed = {
                "java",
                "scala",
                "json",
                "javascript",
                "typescript",
                "tsx",
                "yaml",
                "html",
                "css",
                "scss",
                "prisma",
                "markdown",
                "markdown_inline",
                "svelte",
                "graphql",
                "sql",
                "bash",
                "lua",
                "vim",
                "dockerfile",
                "gitignore",
                "query",
                "vimdoc",
                "c",
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
        })

    -- use bash parser for zsh files
    vim.treesitter.language.register("bash", "zsh")
    end,
}
