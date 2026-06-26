---@diagnostic disable: undefined-global

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.filetype.add({
  extension = {
    inc = "c",
    jsxinc = "javascript.jsx",
  },
})

-- vscode/通常で共通の基本設定
local function setup_common_options()
  vim.opt.tabstop = 4
  vim.opt.shiftwidth = 4
  vim.opt.nrformats = "hex"
end


local function setup_keymaps()
  local opts = { noremap = true, silent = true }

  vim.keymap.set("i", "jj", "<esc>", opts)

  vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", opts)
  vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", opts)
  vim.keymap.set("n", "<leader>Q", "<cmd>qa<cr>", opts)

  vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

  vim.keymap.set("n", "<c-k>", vim.diagnostic.open_float, opts)

  vim.keymap.set("i", "<up>", function()
    return vim.fn.pumvisible() == 1 and "<up>" or "<c-x><c-o>"
  end, { expr = true, noremap = true, silent = true })

  vim.keymap.set("i", "<down>", function()
    return vim.fn.pumvisible() == 1 and "<down>" or "<c-x><c-o>"
  end, { expr = true, noremap = true, silent = true })

  vim.keymap.set("c", "<down>", function()
    return vim.fn.pumvisible() == 1 and "<c-n>" or "<down>"
  end, { expr = true })

  vim.keymap.set("c", "<up>", function()
    return vim.fn.pumvisible() == 1 and "<c-p>" or "<up>"
  end, { expr = true })
end


local function setup_options()
  setup_common_options()
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.cursorline = true
  vim.opt.fileformats = "dos"

  -- 改行時にコメントリーダーを引き継がない
  vim.api.nvim_create_autocmd("FileType", {
    callback = function()
      vim.opt_local.formatoptions:remove({ "r", "o" })
    end,
  })

  vim.lsp.enable({ "lua_ls", "clangd", "pyright", "ruff" })
end


local function setup_vscode()
  setup_common_options()
  vim.opt.clipboard = "unnamedplus"
end


local function bootstrap_lazy()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
        { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
        { out, "WarningMsg" },
        { "\nPress any key to exit..." },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
  vim.opt.rtp:prepend(lazypath)
end


bootstrap_lazy()

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = { cond = not vim.g.vscode },
  install = { colorscheme = { "kanagawa" } },
  checker = { enabled = true },
})

if vim.g.vscode then
  setup_vscode()
else
  setup_keymaps()
  setup_options()
end
