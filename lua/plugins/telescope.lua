return {
    { -- Fuzzy Finder (files, lsp, etc)
        'nvim-telescope/telescope.nvim',
        event = 'VimEnter',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
            { 'nvim-telescope/telescope-ui-select.nvim' },
            { 'debugloop/telescope-undo.nvim' },

            -- Useful for getting pretty icons, but requires a Nerd Font.
            { 'nvim-tree/nvim-web-devicons',              enabled = vim.g.have_nerd_font },
        },
        config = function()
            -- Telescope is a fuzzy finder that comes with a lot of different things that
            -- it can fuzzy find! It's more than just a "file finder", it can search
            -- many different aspects of Neovim, your workspace, LSP, and more!
            --
            -- The easiest way to use Telescope, is to start by doing something like:
            --  :Telescope help_tags
            --
            -- After running this command, a window will open up and you're able to
            -- type in the prompt window. You'll see a list of `help_tags` options and
            -- a corresponding preview of the help.
            --
            -- Two important keymaps to use while in Telescope are:
            --  - Insert mode: <c-/>
            --  - Normal mode: ?
            --
            -- This opens a window that shows you all of the keymaps for the current
            -- Telescope picker. This is really useful to discover what Telescope can
            -- do as well as how to actually do it!

            -- [[ Configure Telescope ]]
            -- See `:help telescope` and `:help telescope.setup()`
            require('telescope').setup({
                -- You can put your default mappings / updates / etc. in here
                --  All the info you're looking for is in `:help telescope.setup()`
                --
                defaults = {},
                -- pickers = { }
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown(),
                    },
                    ['undo'] = {
                        side_by_side = true,
                    },
                },
            })

            -- Enable Telescope extensions if they are installed
            pcall(require('telescope').load_extension, 'fzf')
            pcall(require('telescope').load_extension, 'ui-select')
            pcall(require('telescope').load_extension, 'undo')

            -- See `:help telescope.builtin`
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
            vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
            vim.keymap.set('n', '<leader>sF', builtin.find_files, { desc = '[S]earch [F]iles' })
            vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
            vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
            vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
            vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
            vim.keymap.set('n', '<leader>sR', builtin.registers, { desc = '[S]earch [R]esume' })
            vim.keymap.set('n', '<leader>su', "<cmd>Telescope undo<cr>", { desc = '[S]earch [U]ndo' })
            vim.keymap.set('n', '<leader>st', "<cmd>TodoTelescope<cr>", { desc = '[S]earch [T]odo' })
            vim.keymap.set('n', '<leader>s.', builtin.oldfiles,
                { desc = '[S]earch Recent Files ("." for repeat)' })
            vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

            vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find,
                { desc = '[/] Fuzzily search in current buffer' })

            local is_inside_work_tree = {}
            local function project_files(opts)
                local cwd = vim.fn.getcwd()
                local val = is_inside_work_tree[cwd]
                if val == nil then
                    vim.fn.system('git rev-parse --is-inside-work-tree')
                    val = vim.v.shell_error == 0
                    is_inside_work_tree[cwd] = val
                end
                if val then
                    builtin.git_files(opts)
                else
                    builtin.find_files(opts)
                end
            end
            vim.keymap.set('n', '<leader>sf', project_files, { desc = '[S]earch (Git) [F]iles' })

            -- It's also possible to pass additional configuration options.
            --  See `:help telescope.builtin.live_grep()` for information about particular keys
            vim.keymap.set('n', '<leader>s/', function()
                builtin.live_grep({
                    grep_open_files = true,
                    prompt_title = 'Live Grep in Open Files',
                })
            end, { desc = '[S]earch [/] in Open Files' })

            vim.keymap.set('n', '<leader>s?', function()
                builtin.live_grep({
                    prompt_title = 'Live Grep in All Files',
                })
            end, { desc = '[S]earch [?] in All Files' })

            -- Shortcut for searching your Neovim configuration files
            vim.keymap.set('n', '<leader>sn', function()
                builtin.find_files({ cwd = vim.fn.stdpath 'config' })
            end, { desc = '[S]earch [N]eovim files' })

            vim.keymap.set('n', '<leader>si', builtin.lsp_dynamic_workspace_symbols,
                { desc = '[S]earch Workspace [I]dentifiers' })
            vim.keymap.set('n', '<leader>sI', builtin.lsp_document_symbols,
                { desc = '[S]earch Document [I]dentifiers' })
            vim.keymap.set('n', '<leader>sci', builtin.lsp_incoming_calls, { desc = '[S]earch [I]ncoming [C]alls' })
            vim.keymap.set('n', '<leader>sco', builtin.lsp_outgoing_calls, { desc = '[S]earch [O]utgoing [C]alls' })
        end,
    },
}
