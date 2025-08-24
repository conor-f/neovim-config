-- Minimal test configuration
print("Loading minimal test config...")

-- Basic settings
vim.opt.number = true
print("Line numbers set")

-- Bootstrap lazy
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--single-branch',
    'https://github.com/folke/lazy.nvim.git',
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Test lazy setup
require('lazy').setup({
  'tpope/vim-sleuth'
})

print("Minimal config loaded successfully")