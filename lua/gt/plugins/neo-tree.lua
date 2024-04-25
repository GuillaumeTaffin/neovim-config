return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "folke/which-key.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
        --  INFO: Keymaps
        require("which-key").register({
            ["<leader>e"] = { name = "[E]xplorer", _ = "which_key_ignore" },
        })
        vim.keymap.set("n", "<leader>ee", "<cmd>Neotree toggle<CR>", { desc = "[E]xpand toggle" })
        vim.keymap.set("n", "<leader>er", "<cmd>Neotree filesystem reveal<CR>", { desc = "[R]eveal current file" })
        vim.keymap.set("n", "<leader>k", function()
            local commands = require("neo-tree.sources.common.commands")
            vim.cmd("Neotree git_status git_base=HEAD")
            print(vim.api.nvim_get_current_buf())
            commands.git_add_all()
            commands.git_commit()
        end, { desc = "[K]ommit" })
        vim.keymap.set("n", "<leader>eq", function()
            require("neo-tree.sources.manager").close_all()
        end, { desc = "[Q]uit" })

        --  INFO: Icons
        vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
        vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
        vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
        vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

        -- INFO: Config
        require("neo-tree").setup({
            filesystem = {
                use_libuv_file_watcher = true,
                filtered_items = {
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
            },
        })
    end,
}
