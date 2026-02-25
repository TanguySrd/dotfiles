return {
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            -- list of servers for mason to install
            ensure_installed = {
                "cssls",
                "emmet_ls",
                "eslint",
                "graphql",
                "html",
                "lua_ls",
                "prismals",
                "pyright",
                "sqlls",
                "svelte",
                "tailwindcss",
                "ts_ls",
            },
        },
        dependencies = {
            {
                "williamboman/mason.nvim",
                opts = {
                    ui = {
                        icons = {
                            package_installed = "✓",
                            package_pending = "➜",
                            package_uninstalled = "✗",
                        },
                    },
                },
            },
            "neovim/nvim-lspconfig",
        },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
            ensure_installed = {
                "black", -- python formatter
                "eslint_d",
                "isort", -- python formatter
                "prettier", -- prettier formatter
                "pylint",
                "sql-formatter",
                "stylua", -- lua formatter
            },
        },
        dependencies = {
            "williamboman/mason.nvim",
        },
    },
}
