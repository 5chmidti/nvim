return {
    { -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Useful status updates for LSP.
            { 'j-hui/fidget.nvim',  opts = {} },

            -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
            -- used for completion, annotations and signatures of Neovim apis
            { 'folke/lazydev.nvim', opts = { ft = "lua", } },
            "nvim-telescope/telescope.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            --  This function gets run when an LSP attaches to a particular buffer.
            --  That is to say, every time a new file is opened that is associated with
            --  an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
            --  function will be executed to configure the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set('n', keys, func,
                            { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    -- Jump to the definition of the word under your cursor.
                    --  This is where a variable was first declared, or where a function is defined, etc.
                    --  To jump back, press <C-t>.
                    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

                    -- Find references for the word under your cursor.
                    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

                    -- Jump to the implementation of the word under your cursor.
                    --  Useful when your language has ways of declaring types without an actual implementation.
                    map('gI', require('telescope.builtin').lsp_implementations,
                        '[G]oto [I]mplementation')

                    -- Jump to the type of the word under your cursor.
                    --  Useful when you're not sure what type a variable is and you want to see
                    --  the definition of its *type*, not where it was *defined*.
                    map('<leader>D', require('telescope.builtin').lsp_type_definitions,
                        'Type [D]efinition')

                    -- Fuzzy find all the symbols in your current document.
                    --  Symbols are things like variables, functions, types, etc.
                    map('<leader>ds', require('telescope.builtin').lsp_document_symbols,
                        '[D]ocument [S]ymbols')

                    -- Fuzzy find all the symbols in your current workspace.
                    --  Similar to document symbols, except searches over your entire project.
                    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols,
                        '[W]orkspace [S]ymbols')

                    -- Rename the variable under your cursor.
                    --  Most Language Servers support renaming across files, etc.
                    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

                    -- Execute a code action, usually your cursor needs to be on top of an error
                    -- or a suggestion from your LSP for this to activate.
                    vim.keymap.set('', '<leader>ca',
                        function() vim.lsp.buf.code_action({ apply = false }) end,
                        { buffer = event.buf, desc = 'LSP: [C]ode [A]ction' })

                    vim.keymap.set('i', '<C-s>', vim.lsp.buf.signature_help,
                        { buffer = event.buf, desc = 'Signature Help' })

                    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    --  See `:help CursorHold` for information about when this is executed
                    --
                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.server_capabilities.documentHighlightProvider then
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            callback = vim.lsp.buf.clear_references,
                        })
                    end

                    -- The following autocommand is used to enable inlay hints in your
                    -- code, if the language server you are using supports them
                    --
                    -- This may be unwanted, since they displace some of your code
                    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
                        end, '[T]oggle Inlay [H]ints')
                    end
                end,
            })

            -- LSP servers and clients are able to communicate to each other what features they support.
            --  By default, Neovim doesn't support everything that is in the LSP specification.
            --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
            --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend('force', capabilities,
                require('cmp_nvim_lsp').default_capabilities())

            --  Add any additional override configuration in the following tables. Available keys are:
            --  - cmd (table): Override the default command used to start the server
            --  - filetypes (table): Override the default list of associated filetypes for the server
            --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
            --  - settings (table): Override the default settings passed when initializing the server.
            --    For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
            local lspconfig = require('lspconfig')
            lspconfig.clangd.setup({
                capabilities = capabilities,
                root_dir = function(fname)
                    local util = require('lspconfig.util')
                    local root_files = {
                        '.clangd',
                        '.clang-tidy',
                        '.clang-format',
                        'compile_commands.json',
                        'compile_flags.txt',
                        'configure.ac',
                    }
                    return util.find_git_ancestor(fname) or util.root_pattern(unpack(root_files))(fname)
                end,
                on_new_config = function(new_config, new_root_dir)
                    local comp_db = vim.fn.findfile('compile_commands.json', new_root_dir .. "/**2/" .. "/build/**2")
                    local comp_db_flag = "--compile-commands-dir=" .. vim.fn.fnamemodify(comp_db, ":p:h")
                    new_config.cmd = { "clangd", comp_db_flag }
                end
            })
            lspconfig.cmake.setup({
                capabilities = capabilities,
            })
            lspconfig.harper_ls.setup({})
            lspconfig.nil_ls.setup({})
            lspconfig.lua_ls.setup({
                -- cmd = {...},
                -- filetypes = { ...},
                capabilities = capabilities,
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = 'Replace',
                        },
                        hint = { enable = true, },
                    },
                },
            })
            lspconfig.ruff.setup({
                capabilities = capabilities,
                init_options = {
                    settings = {
                        lint = {
                            select = { "ALL" },
                            ignore = {
                                -- missing documentation
                                "D100",
                                "D101",
                                "D102",
                                "D103",
                                "D104",
                                "D105",
                                "D106",
                                "D107",
                                -- using `print`
                                "T201",
                            },
                        },
                        ["target-version"] = "py312",
                    },
                },
                on_init = function(client)
                    if client.config.root_dir == nil then
                        return
                    end
                    if client.config.root_dir:find("llvm") ~= nil then
                        client.config.settings["target-version"] = "py38"
                        client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
                    end
                end
            })
            lspconfig.pyright.setup({
                capabilities = capabilities,
            })
            lspconfig.nixd.setup({
                cmd = { "nixd", "--inlay-hints", "--semantic-tokens" },
                capabilities = capabilities,
            })
            lspconfig.texlab.setup({
                capabilities = capabilities,
                settings = {
                    texlab = { chktex = { onEdit = true, }, },
                },
                on_init = function(client)
                    if client.config.root_dir == nil then
                        return
                    end
                    if vim.fn.findfile('build.ninja', client.config.root_dir .. '/build/*') then
                        client.config.settings.texlab.build.executable = 'ninja'
                        client.config.settings.texlab.build.args = { '-C', client.config.root_dir .. '/build' }
                        client.config.settings.texlab.build.onSave = true
                        client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
                    end
                end,
            })
        end,
    },

    -- {
    --     'p00f/clangd_extensions.nvim',
    -- },
}
