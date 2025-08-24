-- Simple test script to debug Lazy.nvim issues
-- Run this with: nvim --clean -c "source debug-test.lua"

print("=== DEBUG TEST SCRIPT ===")

-- Test 1: Check if we can create basic directories
local data_dir = vim.fn.stdpath('data')
print("Data directory: " .. data_dir)

-- Test 2: Try to bootstrap lazy manually
local lazypath = data_dir .. '/lazy/lazy.nvim'
print("Lazy path: " .. lazypath)

if not vim.loop.fs_stat(lazypath) then
  print("Cloning Lazy.nvim...")
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--single-branch',
    'https://github.com/folke/lazy.nvim.git',
    lazypath
  })
  if vim.v.shell_error ~= 0 then
    print("ERROR: Failed to clone Lazy.nvim")
    return
  end
end

-- Test 3: Add to runtime path
vim.opt.rtp:prepend(lazypath)

-- Test 4: Try to require lazy
local ok, lazy = pcall(require, 'lazy')
if not ok then
  print("ERROR: Cannot require lazy - " .. lazy)
  return
end

print("SUCCESS: Lazy.nvim loaded")

-- Test 5: Try minimal setup
local setup_ok, err = pcall(lazy.setup, {
  'tpope/vim-sleuth'
}, {
  install = { missing = true }
})

if not setup_ok then
  print("ERROR in setup: " .. err)
else
  print("SUCCESS: Minimal setup worked")
end

print("=== TEST COMPLETE ===")