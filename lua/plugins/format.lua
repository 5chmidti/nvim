local enable_format_hunk = false
local function format_hunks()
    local ignored_filetypes = {}
    if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
        vim.notify("range formatting for " .. vim.bo.filetype .. " not working properly.", vim.log.levels.INFO)
        return
    end

    local hunks = require('gitsigns').get_hunks()
    if hunks == nil then
        return
    end

    local format = require('conform').format

    local function format_range()
        if next(hunks) == nil then
            return
        end
        local hunk = nil
        while next(hunks) ~= nil and (hunk == nil or hunk.type == "delete") do
            hunk = table.remove(hunks)
        end

        if hunk ~= nil and hunk.type ~= "delete" then
            local start = hunk.added.start
            local last = start + hunk.added.count
            -- nvim_buf_get_lines uses zero-based indexing -> subtract from last
            local last_hunk_line = vim.api.nvim_buf_get_lines(0, last - 2, last - 1, true)[1]
            local range = { start = { start, 0 }, ["end"] = { last - 1, last_hunk_line:len() } }
            format({ range = range, async = true, lsp_fallback = true }, function()
                vim.defer_fn(function()
                    format_range()
                end, 1)
            end)
        end
    end

    format_range()
end

return {
    { -- Autoformat
        'stevearc/conform.nvim',
        lazy = false,
        config = function()
            require('conform').setup({
                formatters_by_ft = {
                    nix = { "nixfmt" },
                },
                notify_on_error = false,
                format_on_save = {},
                default_format_opts = {
                    timeout_ms = 500,
                    lsp_format = 'prefer',
                },
            })

            local function format_mode()
                local res = vim.fn.confirm('Format hunks? Currently: ' .. tostring(enable_format_hunk), '&Yes\n&No\nQuit',
                    2,
                    'Question')
                if res == 1 then
                    enable_format_hunk = true
                elseif res == 2 then
                    enable_format_hunk = false
                end
            end
            local function apply_selected_format()
                if enable_format_hunk then
                    format_hunks()
                else
                    require('conform').format({ async = true, lsp_fallback = true })
                end
            end
            vim.keymap.set('n', '<leader>F', format_mode, { desc = "[F]ormat mode" })
            vim.keymap.set('n', '<leader>f', apply_selected_format, { desc = '[F]ormat buffer' })
        end
    },

}
