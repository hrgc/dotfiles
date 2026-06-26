---@diagnostic disable: undefined-global

return {
  -- LSP
  "neovim/nvim-lspconfig",

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    opts = {},
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("vim-treesitter-start", {}),
        callback = function(ctx)
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },

  -- ファイラ
  {
    "stevearc/oil.nvim",
    -- ディレクトリを引数に起動したとき（nvim .）に netrw を乗っ取って Oil を開くため、
    -- 遅延ロードせず起動時に setup する。
    lazy = false,
    opts = {
      default_file_explorer = true,
      view_options = {
        show_hidden = true,
      },
    },
    dependencies = { "nvim-mini/mini.icons" },
    keys = {
      { "<leader>e", "<cmd>Oil<cr>" },
    },
  },

  -- ピッカー類
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile      = { enabled = false },
      dashboard    = { enabled = false },
      explorer     = { enabled = false },
      indent       = { enabled = false },
      input        = { enabled = false },
      picker       = {
        enabled = true,
        exclude = {
          "__pycache__",
        },
      },
      notifier     = { enabled = false },
      quickfile    = { enabled = false },
      scope        = { enabled = false },
      scroll       = { enabled = false },
      statuscolumn = { enabled = false },
      words        = { enabled = false },
    },
    keys = {
      { "<leader>f<space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
      { "<leader>f:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>fr", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
      { "<leader>fh", function() Snacks.picker.recent() end, desc = "Recent" },
      { "<leader>fn", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>fD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
    },
  },

  -- 編集支援（mini.nvim 一式）
  {
    "nvim-mini/mini.nvim",
    version = "*",
    config = function()
      require("mini.align").setup()
      require("mini.comment").setup()
      require("mini.splitjoin").setup()
      require("mini.surround").setup()
      require("mini.bufremove").setup()
      require("mini.icons").setup()
      require("mini.statusline").setup()
      require("mini.files").setup({
        mappings = {
          close = "<esc>",
          go_in_plus = "<cr>",
        },
        options = {
          use_as_default_explorer = false,
        },
      })
    end,
  },
}
