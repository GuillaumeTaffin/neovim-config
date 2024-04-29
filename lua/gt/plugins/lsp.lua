return { -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    dependencies = {
        -- Automatically install LSPs and related tools to stdpath for Neovim
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",

        -- Useful status updates for LSP.
        -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
        { "j-hui/fidget.nvim", opts = {} },

        -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
        -- used for completion, annotations and signatures of Neovim apis
        { "folke/neodev.nvim", opts = {} },
    },
    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
            callback = function(event)
                local keymap = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                end

                -- Jump to the definition of the word under your cursor.
                --  This is where a variable was first declared, or where a function is defined, etc.
                --  To jump back, press <C-t>.
                keymap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

                -- Find references for the word under your cursor.
                keymap("gr", function()
                    require("telescope.builtin").lsp_references({
                        include_declaration = false,
                    })
                end, "[g]oto [R]eferences")

                -- Jump to the implementation of the word under your cursor.
                --  Useful when your language has ways of declaring types without an actual implementation.
                keymap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

                -- Jump to the type of the word under your cursor.
                --  Useful when you're not sure what type a variable is and you want to see
                --  the definition of its *type*, not where it was *defined*.
                keymap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

                -- Fuzzy find all the symbols in your current document.
                --  Symbols are things like variables, functions, types, etc.
                keymap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

                -- Fuzzy find all the symbols in your current workspace.
                --  Similar to document symbols, except searches over your entire project.
                keymap(
                    "<leader>ws",
                    require("telescope.builtin").lsp_dynamic_workspace_symbols,
                    "[W]orkspace [S]ymbols"
                )

                -- Rename the variable under your cursor.
                --  Most Language Servers support renaming across files, etc.
                keymap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

                -- Execute a code action, usually your cursor needs to be on top of an error
                -- or a suggestion from your LSP for this to activate.
                keymap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

                -- Opens a popup that displays documentation about the word under your cursor
                --  See `:help K` for why this keymap.
                keymap("K", vim.lsp.buf.hover, "Hover Documentation")

                -- WARN: This is not Goto Definition, this is Goto Declaration.
                --  For example, in C this would take you to the header.
                keymap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                -- The following two autocommands are used to highlight references of the
                -- word under your cursor when your cursor rests there for a little while.
                --    See `:help CursorHold` for information about when this is executed
                --
                -- When you move your cursor, the highlights will be cleared (the second autocommand).
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client.server_capabilities.documentHighlightProvider then
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = event.buf,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                        buffer = event.buf,
                        callback = vim.lsp.buf.clear_references,
                    })
                end

                -- The following autocommand is used to enable inlay hints in your
                -- code, if the language server you are using supports them
                --
                -- This may be unwanted, since they displace some of your code
                if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                    keymap("<leader>th", function()
                        vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled())
                    end, "[T]oggle Inlay [H]ints")
                end
            end,
        })

        -- LSP servers and clients are able to communicate to each other what features they support.
        --  By default, Neovim doesn't support everything that is in the LSP specification.
        --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
        --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
        capabilities.textDocument.completion.completionItem.snippetSupport = true

        -- Enable the following language servers
        --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
        --
        --  Add any additional override configuration in the following tables. Available keys are:
        --  - cmd (table): Override the default command used to start the server
        --  - filetypes (table): Override the default list of associated filetypes for the server
        --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
        --  - settings (table): Override the default settings passed when initializing the server.
        --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/

        vim.filetype.add({
            extension = {
                jsligo = "jsligo",
            },
        })
        vim.filetype.add({
            extension = {
                mligo = "mligo",
            },
        })

        local servers = {
            -- clangd = {},
            gopls = {
                settings = {
                    completeUnimported = true,
                    usePlaceholders = true,
                },
            },
            pyright = {},
            rust_analyzer = {},
            tailwindcss = {},
            cssls = {},
            html = {},
            htmx = {},
            templ = {},
            emmet_language_server = {},
            svelte = {
                on_attach = function(client)
                    vim.api.nvim_create_autocmd("BufWritePost", {
                        desc = "Trigger svelte lsp update on JS/TS file changes",
                        group = vim.api.nvim_create_augroup("svelte-ts-js-trigger", { clear = true }),
                        pattern = { "*.js", "*.ts" },
                        callback = function(ctx)
                            client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
                        end,
                    })
                end,
            },
            -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
            --
            -- Some languages (like typescript) have entire language plugins that can be useful:
            --    https://github.com/pmizio/typescript-tools.nvim
            --
            -- But for many setups, the LSP (`tsserver`) will work just fine
            --

            lua_ls = {
                -- cmd = {...},
                -- filetypes = { ...},
                -- capabilities = {},
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace",
                        },
                        -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                        -- diagnostics = { disable = { 'missing-fields' } },
                    },
                },
            },
            tsserver = {},
            eslint = {},
        }

        -- Ensure the servers and tools above are installed
        --  To check the current status of installed tools and/or manually install
        --  other tools, you can run
        --    :Mason
        --
        --  You can press `g?` for help in this menu.
        require("mason").setup()

        -- You can add other tools here that you want Mason to install
        -- for you, so that they are available from within Neovim.
        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
            "prettier",
            "stylua",
            "isort",
            "black",
            "pylint",
            "goimports",
            "gofumpt",
            "shellcheck",
            "shfmt",
        })
        require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

        require("mason-lspconfig").setup({
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    -- This handles overriding only values explicitly passed
                    -- by the server configuration above. Useful when disabling
                    -- certain features of an LSP (for example, turning off formatting for tsserver)
                    server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                    require("lspconfig")[server_name].setup(server)
                end,
            },
        })

        local lspconfig = require("lspconfig")
        local configs = require("lspconfig.configs")
        if not configs.ligo then
            configs.ligo = {
                default_config = {
                    cmd = { "ligo", "lsp", "all-capabilities" },
                    filetypes = { "jsligo", "mligo" },
                    capabilities = capabilities,
                    -- root_dir = function(filename, bufnr)
                    --     return nil
                    -- end,
                    single_file_support = true,
                    autostart = true,
                    on_attach = function()
                        vim.cmd("syntax=jsligo")
                    end,
                },
            }
        end

        -- lspconfig.ligo.setup({
        --     cmd = { "ligo", "lsp", "all-capabilities" },
        --     filetypes = { "jsligo", "mligo" },
        --     capabilities = capabilities,
        --     -- root_dir = function(filename, bufnr)
        --     --     return nil
        --     -- end,
        --     single_file_support = true,
        --     autostart = true,
        --     on_attach = function()
        --         -- vim.cmd("syntax=jsligo")
        --     end,
        -- })

        local customClient = {}
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("ligo-lsp", { clear = true }),
            pattern = "jsligo",
            callback = function()
                if not customClient.ligo_lsp then
                    customClient.ligo_lsp = vim.lsp.start_client({
                        name = "ligo_lsp",
                        cmd = { "/opt/homebrew/bin/ligo", "lsp", "all-capabilities" },
                        capabilities = capabilities,
                    })
                end
                if not customClient.ligo_lsp then
                    vim.notify("LIGO CLIENT COULD NOT BE STARTED")
                end
                vim.lsp.buf_attach_client(0, customClient.ligo_lsp)
                vim.cmd("syntax=jsligo")
            end,
        })
    end,
}
