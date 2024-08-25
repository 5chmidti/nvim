return {
    {
        'mfussenegger/nvim-lint',
        config = function()
            local lint = require('lint')
            lint.linters_by_ft = {
            }
            vim.api.nvim_create_autocmd({ 'TextChanged', 'BufReadPost' }, {
                callback = function() require('lint').try_lint() end,
            })
        end
    }
}