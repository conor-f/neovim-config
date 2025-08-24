-- Justfile support for syntax highlighting and basic functionality
return {
  {
    'NoahTheDuke/vim-just',
    ft = 'just', -- Load only for justfiles
    config = function()
      -- Auto-detect justfiles
      vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
        pattern = { 'justfile', 'Justfile', '.justfile' },
        callback = function()
          vim.bo.filetype = 'just'
        end,
      })
    end,
  },
}