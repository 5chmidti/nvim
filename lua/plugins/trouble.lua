return {
    {
        "folke/trouble.nvim",
        opts = {
            modes = {
                lsp_base = {
                    params = {
                        include_current = true, },
                    win = {
                        position = "right",
                    },
                },
                lsp = {
                    win = {
                        position = "right",
                    },
                },
                lsp_document_symbols = {
                    win = {
                        position = "right",
                    },
                },
            },
        },
        cmd = "Trouble",
        keys = {
            {
                "<leader>vd",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>vf",
                "<cmd>Trouble lsp toggle<cr>",
                desc = "LSP (Trouble)",
            },
            {
                "<leader>vr",
                "<cmd>Trouble lsp_references toggle<cr>",
                desc = "LSP references (Trouble)",
            },
            {
                "<leader>vs",
                "<cmd>Trouble symbols toggle<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>vt",
                "<cmd>Trouble todo toggle<cr>",
                desc = "ToDo (Trouble)",
            },
        },
    },
}
