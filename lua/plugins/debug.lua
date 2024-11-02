return {
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'rcarriga/nvim-dap-ui',
            'nvim-neotest/nvim-nio',
            'theHamsta/nvim-dap-virtual-text',
        },
        keys = function(_, keys)
            local dap = require('dap')
            local ui = require('dapui')

            return {
                { '<F5>',      dap.continue, },
                { '<F1>',      dap.step_into, },
                { '<F2>',      dap.step_over, },
                { '<F3>',      dap.step_out, },
                { '<leader>b', dap.toggle_breakpoint, },
                { '<leader>B', function()
                    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
                end, },
                { '<F7>', ui.toggle, },
                unpack(keys),
            }
        end,
        config = function()
            local dap = require('dap')
            local ui = require('dapui')
            ui.setup({})
            dap.listeners.after.event_initialized['dapui_config'] = ui.open
            dap.listeners.before.event_terminated['dapui_config'] = ui.close
            dap.listeners.before.event_exited['dapui_config'] = ui.close

            dap.adapters.lldb = {
                type = 'executable',
                command = '/etc/profiles/per-user/julian/bin/lldb-dap',
                name = 'lldb',
            }
        end
    },
    {
        'mfussenegger/nvim-dap-python',
        dependencies = {
            'mfussenegger/nvim-dap',
            'nvim-treesitter/nvim-treesitter',
        },
        config = function()
            require('dap-python').setup('python')
        end
    }
}
