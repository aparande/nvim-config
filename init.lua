-- General Settings
vim.opt.belloff = 'all'
vim.opt.tabstop=2 
vim.opt.shiftwidth=2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.signcolumn = 'yes'
-- Refresh when file changes outside vim
vim.opt.autoread = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.updatetime = 300
vim.opt.laststatus = 2
vim.opt.statusline = '%r %-m %-f %=%p %%'

-- Packages
require('paq') {
  'savq/paq-nvim',
  'tpope/vim-fugitive',
  -- Theme
  'folke/tokyonight.nvim',
  -- Language Server & Code Completion
  'neovim/nvim-lspconfig',
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  'neovim/nvim-lspconfig', 
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-buffer',
  'nvim-lua/plenary.nvim',
  'Exafunction/codeium.nvim',
}

-- Theme & Highlighting
vim.cmd('colorscheme tokyonight-night')

require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'lua', 'vim', 'markdown', 'python', 'rust',
    'javascript', 'verilog'
  },
  auto_install = true,
})

-- Code completion
require('codeium').setup({})


-- Add cmp_nvim_lsp capabilities settings to lspconfig
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

-- Code Completion
local cmp = require('cmp')
cmp.setup({
  -- Automatically select the first item
  preselect = 'item',
  -- Don't automatically insert
  completion = {
    completeopt = 'noinsert'
  },
  sources = {
    {name = 'nvim_lsp'},
    {name = 'buffer'},
  },
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
})

cmp.setup.filetype({'python', 'rust', 'lua'}, {
  sources = cmp.config.sources(cmp.get_config().sources, {
    {name = 'codeium'},
  }),
})

-- LSPs
local lspconfig = require('lspconfig')
lspconfig.pyright.setup({})
lspconfig.rust_analyzer.setup({})
lspconfig.svlangserver.setup({})

-- Keybindings
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', 'rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  end,
})

local cmp = require('cmp')
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({select = true}),
    ['<Tab>'] = cmp.mapping(function(fallback)
      local col = vim.fn.col('.') - 1

      if cmp.visible() then
        cmp.select_next_item({behavior = 'select'})
      elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        fallback()
      else
        cmp.complete()
      end
    end, {'i', 's'}),

    -- Previous item
    ['<S-Tab>'] = cmp.mapping.select_prev_item({behavior = 'select'}),
  }),
})

-- Autoformatting
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = {'*rs', '*.v', '*.sv'},
  callback = function()
    vim.lsp.buf.format()
  end,
})
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*py',
  callback = function()
    vim.cmd('silent !yapf --in-place %')
    vim.cmd('edit!')
  end,
})
