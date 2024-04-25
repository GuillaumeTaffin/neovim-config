return {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle",
    event = { "InsertLeave", "TextChanged" },
    keys = {
        { "<leader>ts", ":ASToggle<CR>", desc = "Auto-[S]ave" },
    },
    opts = {
        enabled = false,
        debounce_delay = 1000,
    },
}
