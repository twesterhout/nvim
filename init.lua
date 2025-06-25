-- general options
vim.o.completeopt = "menu,menuone,popup,fuzzy" -- modern completion menu

vim.o.foldenable = true   -- enable fold
vim.o.foldlevel = 99      -- start editing with all folds opened
vim.o.foldmethod = "expr" -- use tree-sitter for folding method
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.o.termguicolors = true  -- enable rgb colors
vim.o.cursorline = true     -- enable cursor line
vim.o.number = true         -- enable line number
-- vim.o.signcolumn = "yes"    -- always show sign column
vim.o.pumheight = 10        -- max height of completion menu
vim.o.list = true           -- use special characters to represent things like tabs or trailing spaces
vim.opt.listchars = {       -- NOTE: using `vim.opt` instead of `vim.o` to pass rich object
    tab = "▏ ",
    trail = "·",
    extends = "»",
    precedes = "«",
}

vim.opt.diffopt:append("linematch:60") -- second stage diff to align lines

vim.o.confirm = true     -- show dialog for unsaved file(s) before quit
vim.o.updatetime = 200   -- save swap file with 200ms debouncing
vim.o.ignorecase = true  -- case-insensitive search
vim.o.smartcase = true   -- , until search pattern contains upper case characters
vim.o.smartindent = true -- auto-indenting when starting a new line
vim.o.shiftround = true  -- round indent to multiple of 'shiftwidth'
vim.o.shiftwidth = 0     -- 0 to follow the 'tabstop' value
vim.o.tabstop = 2        -- tab width
vim.o.expandtab = true
vim.o.undofile = true    -- enable persistent undo
vim.o.undolevels = 10000 -- 10x more undo levels

-- define <leader> and <localleader> keys
-- you should use `vim.keycode` to translate keycodes or pass raw keycode values like `" "` instead of just `"<space>"`
vim.g.mapleader = vim.keycode("<space>")
vim.g.maplocalleader = vim.keycode("<cr>")

-- remove netrw banner for cleaner looking
vim.g.netrw_banner = 0


-- treesitter
vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(vim.treesitter.start)
    end
})
vim.cmd("syntax off") -- disable builtin syntax highlighting

require("mini.icons").setup({ style = "ascii", })

local fzf = require("fzf-lua")
fzf.setup({
  fzf_colors = true,
})
vim.keymap.set('n', '<leader>f', fzf.files, { desc = "Search [f]iles" })
vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = "Seach buffers" })
vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [k]eymaps' })

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
    callback = function(ev)
        vim.lsp.completion.enable(true, ev.data.client_id, ev.buf)
        vim.keymap.set({'n', 'x'}, "<leader>ca", function() fzf.lsp_code_actions({silent = true}) end, { desc = "LSP: [C]ode [A]ction" })
        vim.keymap.set('n', '<space>cl', vim.lsp.codelens.run, { desc = "LSP: [C]ode [L]ens run" })
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "LSP: [G]o to [D]efinition" })
        -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { desc = "LSP: Hover" })
    end,
})

-- movements in the terminal
vim.keymap.set('t', '<esc>', '<c-\\><c-n>', { desc = "Making <esc> work in the terminal" })
vim.keymap.set('t', '<a-h>', '<c-\\><c-n><c-w>h', { })
vim.keymap.set('t', '<a-j>', '<c-\\><c-n><c-w>j', { })
vim.keymap.set('t', '<a-k>', '<c-\\><c-n><c-w>k', { })
vim.keymap.set('t', '<a-l>', '<c-\\><c-n><c-w>l', { })
vim.keymap.set('n', '<a-h>', '<c-w>h', { })
vim.keymap.set('n', '<a-j>', '<c-w>j', { })
vim.keymap.set('n', '<a-k>', '<c-w>k', { })
vim.keymap.set('n', '<a-l>', '<c-w>l', { })

-- colorscheme
require("catppuccin").setup({
    background = { light = "latte", dark = "macchiato" },
    integrations = {
        treesitter = true,
        mini = { enabled = true, indentscope_color = "" },
        fzf = true,
        cmp = false,
        gitsigns = false,
        nvimtree = false,
        notify = false,
    },
})
vim.cmd.colorscheme "catppuccin"
