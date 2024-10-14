return {
    {
        'mfussenegger/nvim-lint',
        config = function()
            local lint = require('lint')
            lint.linters.cmakelint.cmd = "cmake-lint"
            lint.linters_by_ft = {
                fish = { "fish", },
                lua = { "selene", },
                sh = { "shellcheck", },
                ['yaml.gha'] = { "actionlint", },
                cmake = { "cmakelint", },
            }
            vim.api.nvim_create_autocmd({
                'TextChanged',
                'BufReadPost',
                'BufWritePost',
            }, {
                callback = function()
                    require('lint').try_lint()
                end,
            })
        end
    }
}
