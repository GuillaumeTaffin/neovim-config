return {
    "nvim-nej-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "folke/which-key.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
        require("which-key").register({
            ["<leader>we"] = { name = "[E]xplorer", _ = "which_key_ignore" },
        })
        vim.keymap.set("n", "<leader>wee", "<cmd>Neotree toggle<CR>", { desc = "[E]xpand toggle" })
        vim.keymap.set("n", "<leader>wer", "<cmd>Neotree filesystem reveal<CR>", { desc = "[R]eveal current file" })
    end,
}
