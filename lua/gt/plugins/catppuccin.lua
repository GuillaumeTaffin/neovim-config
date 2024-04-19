return {
    "catppuccin/nvim",
    priority = 1000,
    lazy = false,
    config = function()
        require("catppuccin").setup({
            integrations = {
                cmp = true,
                gitsigns = true,
                nvimtree = true,
                neotree = true,
                treesitter = true,
                notify = false,
                mini = {
                    enabled = true,
                    indentscope_color = "",
                },
            },
            styles = {
                comments = { "italic" }, -- Change the style of comments
                conditionals = {},
                loops = {},
                functions = { "italic" },
                keywords = {},
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = { "italic" },
                operators = {},
                -- miscs = {}, -- Uncomment to turn off hard-coded styles
            },
        })
        vim.cmd.colorscheme("catppuccin-frappe")
    end,
}
