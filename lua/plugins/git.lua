return {
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
                delay = 0,
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
                map('v', '<leader>hs', function()
                    gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end, { desc = '[S]tage [H]unk' })
                map('n', '<leader>hS', gitsigns.stage_buffer, { desc = '[S]tage Buffer' })

                map('n', '<leader>hr', gitsigns.reset_hunk, { desc = '[R]eset Hunk' })
                map('v', '<leader>hr', function()
                    gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end, { desc = '[R]eset Hunk' })
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

    { 'tpope/vim-fugitive' },
}
