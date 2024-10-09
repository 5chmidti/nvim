return {
    {
        "gregorias/toggle.nvim",
        dependencies = {
            'folke/which-key.nvim',
        },
        config = function()
            local toggle = require("toggle")
            toggle.setup({
                keymaps = {
                    toggle_option_prefix = "yo",
                    previous_option_prefix = "[o",
                    next_option_prefix = "]o",
                    status_dashboard = "yos"
                },
                keymap_registry = require("toggle.keymap").keymap_registry(),
                options_by_keymap = {},
                notify_on_set_default_option = true,
            })
            toggle.register("i", toggle.option.EnumOption({
                name = "cland",
                states = vim.tbl_extend("keep",
                    vim.fn.glob("$HOME/install/llvm*/bin/clangd", false, true),
                    vim.fn.glob("$HOME/dev/llvm-project/build/*/bin/clangd", false, true),
                    vim.fn.glob("$HOME/dev/llvm/*/build/*/bin/clangd", false, true)
                ),
                get_state = function()
                    for _, client in pairs(vim.lsp.get_clients({ name = "clangd" })) do
                        return client.config.cmd[1]
                    end

                    return nil
                end,
                set_state = function(c)
                    for _, client in pairs(vim.lsp.get_clients({ name = "clangd" })) do
                        client.config.cmd[1] = c
                        require("lspconfig").clangd.launch()
                    end
                end
            }))
        end,
    },
}