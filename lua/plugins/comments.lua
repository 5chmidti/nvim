return {
    -- Highlight todo, notes, etc in comments
    {
        'folke/todo-comments.nvim',
        event = 'VimEnter',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = { signs = false }
    },

    { 'numToStr/Comment.nvim', opts = {} },

    {

        "danymat/neogen",
        dependencies = { 'L3MON4D3/LuaSnip', },
        config = function()
            require('neogen').setup({
                snippet_engine = 'luasnip',
            })

            vim.keymap.set('n', '<leader>nd', function()
                require('neogen').generate({})
            end, { desc = '[N]eogen [D]ocument Code' })
        end
    }
}
