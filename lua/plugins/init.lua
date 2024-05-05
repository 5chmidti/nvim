-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--  :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--  :Lazy u date
--
return {
    { 'numToStr/Comment.nvim', opts = {} },
    --
    { -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
            signcolumn = true,
            numhl = true,
            current_line_blame = true,
            current_line_opts = {
                delay = 50,
            },
            current_line_blame_formatter_opts = { relative_time = true, },
            on_attach = function(bufnr)
                local gitsigns = require('gitsigns')

                local function map(mode, keys, callback, opts)
                    opts.buffer = bufnr
                    vim.keymap.set(mode, keys, callback, opts)
                end

                map('n', ']c', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ ']c', bang = true })
                    else
                        gitsigns.nav_hunk('next')
                    end
                end, { desc = '[[] Next Hunk' })
                map('n', '[c', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ '[c', bang = true })
                    else
                        gitsigns.nav_hunk('prev')
                    end
                end, { desc = '[]] Prev Hunk' })

                map('n', '<leader>hs', gitsigns.stage_hunk, { desc = '[S]tage [H]unk' })
                -- map('i', '<leader>hs', function()
                --     gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                -- end, { desc = '[S]tage [H]unk' })
                map('n', '<leader>hS', gitsigns.stage_buffer, { desc = '[S]tage Buffer' })

                map('n', '<leader>hr', gitsigns.reset_hunk, { desc = '[R]eset Hunk' })
                -- map('i', '<leader>hr', function()
                --     gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                -- end, { desc = '[R]eset Hunk' })
                map('n', '<leader>hR', gitsigns.reset_buffer, { desc = '[R]eset Buffer' })

                map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = '[U]ndo Stage Hunk' })
                map('n', '<leader>hp', gitsigns.preview_hunk, { desc = '[P]review Hunk' })
                map('n', '<leader>hb', function()
                    gitsigns.blame_line({ full = true })
                end, { desc = '[B]lame Line' })
                map('n', '<leader>hp', gitsigns.preview_hunk, { desc = '[P]review [H]unk' })
                map('n', '<leader>hd', gitsigns.diffthis, { desc = '[D]iffthis [H]unk' })
                map('n', '<leader>hD', function()
                    gitsigns.diffthis('~')
                end, { desc = '[D]iffthis' })
                map('n', '<leader>td', gitsigns.toggle_deleted, { desc = '[T]oggle [D]eleted' })
            end
        },
    },

    {                       -- Useful plugin to show you pending keybinds.
        'folke/which-key.nvim',
        event = 'VimEnter', -- Sets the loading event to 'VimEnter'
        config = function() -- This is the function that runs, AFTER loading
            require('which-key').setup()

            -- Document existing key chains
            require('which-key').register({
                ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
                ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
                ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
                ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
                ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
            })
            -- visual mode
            require('which-key').register({
                -- ['<leader>h'] = { 'Git [H]unk' },
            }, { mode = 'v' })
        end,
    },

    { -- You can easily change to a different colorscheme.
        -- Change the name of the colorscheme plugin below, and then
        -- change the command in the config to whatever the name of that colorscheme is.
        --
        -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
        'folke/tokyonight.nvim',
        priority = 1000, -- Make sure to load this before all the other start plugins.
        init = function()
            -- Load the colorscheme here.
            -- Like many other themes, this one has different styles, and you could load
            -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
            vim.cmd.colorscheme 'tokyonight-night'

            -- You can configure highlights by doing something like:
            vim.cmd.hi 'Comment gui=none'
        end,
    },

    -- Highlight todo, notes, etc in comments
    { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

    { -- Collection of various small independent plugins/modules
        'echasnovski/mini.nvim',
        config = function()
            -- Better Around/Inside textobjects
            --
            -- Examples:
            --  - va)  - [V]isually select [A]round [)]paren
            --  - yinq - [Y]ank [I]nside [N]ext [']quote
            --  - ci'  - [C]hange [I]nside [']quote
            require('mini.ai').setup({ n_lines = 500 })

            -- Add/delete/replace surroundings (brackets, quotes, etc.)
            --
            -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
            -- - sd'   - [S]urround [D]elete [']quotes
            -- - sr)'  - [S]urround [R]eplace [)] [']
            require('mini.surround').setup()

            -- Simple and easy statusline.
            --  You could remove this setup call if you don't like it,
            --  and try some other statusline plugin
            local statusline = require('mini.statusline')
            -- set use_icons to true if you have a Nerd Font
            statusline.setup({ use_icons = vim.g.have_nerd_font })

            -- You can configure sections in the statusline by overriding their
            -- default behavior. For example, here we set the section for
            -- cursor location to LINE:COLUMN
            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_location = function()
                return '%2l:%-2v'
            end

            -- ... and there is more!
            --  Check out: https://github.com/echasnovski/mini.nvim
        end,
    },
}
