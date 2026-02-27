local mason_lspconfig = require("mason-lspconfig")

local home_dir = os.getenv("HOME")

local function get_server(name)
    local servers = mason_lspconfig.get_installed_servers()
    if vim.tbl_contains(servers, name) then
        return true, vim.lsp.config[name]
    end
    return false, nil
end

local is_file_exist = function(path)
    local f = io.open(path, "r")
    return f ~= nil and io.close(f)
end

local fn = vim.fn

local get_lombok_javaagent = function()
    local lombok_dir = home_dir .. "/.m2/repository/org/projectlombok/lombok/"
    local lombok_versions = io.popen('ls -1 "' .. lombok_dir .. '" | sort -r')
    if lombok_versions ~= nil then
        local lb_i, lb_versions = 0, {}
        for lb_version in lombok_versions:lines() do
            lb_i = lb_i + 1
            lb_versions[lb_i] = lb_version
        end
        lombok_versions:close()
        if next(lb_versions) ~= nil then
            local lombok_jar =
                fn.expand(string.format("%s%s/lombok-%s.jar", lombok_dir, lb_versions[1], lb_versions[1]))
            if is_file_exist(lombok_jar) then
                return string.format("--jvm-arg=-javaagent:%s", lombok_jar)
            end
        end
    end
    return ""
end

local ok, jdtls = get_server("jdtls")

if not ok then
    vim.notify("mason-lspconfig: jdtls not found, please install it first", vim.log.levels.ERROR)
    return
end

local project_name = fn.fnamemodify(fn.getcwd(), ":p:h:t")
local project_setting = fn.getcwd() .. "/.jdtls"

local settingsTable = {}
local file = io.open(project_setting, "r") -- Open the file in read mode

if file then
    for line in file:lines() do
        local key, value = line:match("^(%S+)%s*=%s*(%S+)$")
        if key and value then
            settingsTable[key] = value
        end
    end
    file:close()
end

local format_url = settingsTable["format_setting"]
    or "https://gist.githubusercontent.com/ikws4/7880fdcb4e3bf4a38999a628d287b1ab/raw/9005c451ed1ff629679d6100e22d63acc805e170/jdtls-formatter-style.xml"

local workspace_dir = home_dir .. "/.cache/jdtls/workspace/" .. project_name

local capabilities = {
    workspace = {
        configuration = true,
    },
    textDocument = {
        completion = {
            completionItem = {
                snippetSupport = true,
            },
        },
    },
}

local extendedClientCapabilities = require("jdtls").extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local bundles = {
    -- vim.fn.glob(get_jdp_javaagent(), 1),
    -- vim.fn.glob(vim.fn.stdpath('data')..'/mason/packages/java-test/extension/server/*.jar', true ),
    -- vim.fn.glob(
    --     vim.fn.stdpath('data') ..
    --     '/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar',
    --     true),
}

vim.list_extend(
    bundles,
    vim.split(
        vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/java-debug-adapter/extension/server/*.jar", true),
        "\n"
    )
)

vim.list_extend(
    bundles,
    vim.split(vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/java-test/extension/server/*.jar", true), "\n")
)

-- Paste it after bundles but before assigning bundles to jdtls
-- Following filters out unwanted bundles
-- local ignored_bundles = { "com.microsoft.java.test.runner-jar-with-dependencies.jar", "jacocoagent.jar", "junit-platform-commons_1.11.0.jar", "junit-platform-engine_1.11.0.jar", "junit-platform-launcher_1.11.0.jar", "org.apiguardian.api_1.1.2.jar", "org.opentest4j_1.3.0.jar", "" }
-- local find = string.find
-- local function should_ignore_bundle(bundle)
--     for _, ignored in ipairs(ignored_bundles) do
--         if find(bundle, ignored, 1, true) then
--             return true
--         end
--     end
-- end
-- bundles = vim.tbl_filter(function(bundle) return bundle ~= "" and not should_ignore_bundle(bundle) end, bundles)

local config = {
    -- capabilities = require("cmp_nvim_lsp").default_capabilities(),
    capabilities = capabilities,
    on_attach = function()
        require("jdtls").setup_dap({ hotcodereplace = "auto" })
        require("jdtls.dap").setup_dap_main_class_configs()
    end,
    cmd = {
        "jdtls",
        "-config",
        home_dir .. "/.cache/jdtls/config",
        "-data",
        workspace_dir,
        get_lombok_javaagent(),
    },
    root_dir = require("jdtls.setup").find_root({
        "pom.xml",
        "build.gradle",
        ".git",
    }),
    settings = {
        java = {
            jdt = {
                ls = {
                    vmargs = "-XX:+UseParallelGC -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -Dsun.zip.disableMemoryMapping=true -Xmx16G -Xms4G -Xss128M",
                },
            },
            format = {
                comments = {
                    enabled = false,
                },
                settings = {
                    url = format_url,
                },
            },
            completion = {
                importOrder = {
                    "java",
                    "javax",
                    "jakarta",
                    "org",
                    "com",
                },
            },
            useBlocks = true,
            signatureHelp = { enabled = true },
            autobuild = {
                enabled = false, -- Disable automatic builds
            },
            eclipse = {
                downloadSources = true,
            },
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
        },
    },
    flags = {
        allow_incremental_sync = true,
    },
    init_options = {
        bundles = bundles,
        extendedClientCapabilities = require("jdtls").extendedClientCapabilities,
    },
}

require("jdtls.ui").pick_one = function(items, prompt, label_fn)
    local co = coroutine.running()
    local callback = function(item)
        coroutine.resume(co, item)
    end
    callback = vim.schedule_wrap(callback)
    vim.ui.select(items, {
        prompt = prompt,
        format_item = label_fn,
    }, callback)

    return coroutine.yield()
end

-- if project_name ~= 'enecogen-cms' then
require("jdtls").start_or_attach(config)
-- end
