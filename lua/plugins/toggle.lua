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
                name = "clangd",
                states = vim.tbl_extend("keep",
                    { "clangd", "/etc/profiles/per-user/julian/bin/clangd", },
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

            local build_dir_option = toggle.option.EnumOption({
                name = "clangd - build dir",
                states = {},
                get_state = function()
                    vim.print("asdf")
                    for _, client in pairs(vim.lsp.get_clients({ name = "clangd" })) do
                        return client.config.cmd[2]
                    end

                    return nil
                end,
                set_state = function(c)
                    for _, client in pairs(vim.lsp.get_clients({ name = "clangd" })) do
                        client.config.cmd[2] = c
                        require("lspconfig").clangd.launch()
                    end
                end
            })
            build_dir_option.get_available_states = function(self)
                for _, client in ipairs(vim.lsp.get_clients({ name = "clangd" })) do
                    return vim.fn.findfile('compile_commands.json', client.root_dir .. "/**2/build/**1", -1)
                end
            end
            toggle.register("x", build_dir_option)
        end,
    },
}
