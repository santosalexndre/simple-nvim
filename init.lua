--------------------------------------------------
-- Basic Settings
--------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.visualbell = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.local/undodir/')
vim.opt.scrolloff = 8
vim.opt.signcolumn = "no"
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.fillchars = { eob = " " }
vim.opt.foldmethod = "marker"

vim.o.guicursor = "i:block"

vim.opt.termguicolors = true
vim.opt.signcolumn = "no"
vim.opt.laststatus = 0 -- single statusline for all windows
-- vim.opt.cmdheight = 0

--------------------------------------------------
-- Keymaps
--------------------------------------------------
local set = vim.keymap.set
local opts = { noremap = true, silent = true, }


set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
set("i", "<C-s>", "<Esc><cmd>w<CR>", { desc = "Save file" })

-- navigate buffers
set('n', '<C-h>', '<C-w>h', opts)
set('n', '<C-j>', '<C-w>j', opts)
set('n', '<C-k>', '<C-w>k', opts)
set('n', '<C-l>', '<C-w>l', opts)

-- resizing with arrows
set('n', '<C-Up>', ':resize -2<CR>', opts)
set('n', '<C-Down>', ':resize +2<CR>', opts)
set('n', '<C-Left>', ':vertical resize +2<CR>', opts)
set('n', '<C-Right>', ':vertical resize -2<CR>', opts)

-- dont lose the selected area when identing on visual mode
set('v', '<', '<gv', opts)
set('v', '>', '>gv', opts)

-- move lines like alt in vscode
set("v", "J", ":m '>+1<CR>gv=gv")
set("v", "K", ":m '<-2<CR>gv=gv")

-- clipboard management
set("n", "<Leader>y", '"+y', opts)
set("n", "<Leader>p", '"+p', opts)
set("v", "<Leader>y", '"+y', opts)

-- find and replace thing
set("n", "<Leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- window managment
set("n", "<Leader>ws", "<C-w>s", opts)
set("n", "<Leader>wv", "<C-w>v", opts)
set("n", "<Leader>wq", "<C-w>q", opts)
set("n", "<Leader>wh", "<C-w>h", opts)
set("n", "<Leader>wl", "<C-w>l", opts)
set("n", "<Leader>wj", "<C-w>j", opts)
set("n", "<Leader>wk", "<C-w>k", opts)

local ln_idx = 1
local line_numbers = {
    [1] = { true, false },
    [2] = { false, false },
    [3] = { false, true },
    [4] = { true, true },
}

set('n', '<leader>tnn', function()
    vim.opt.number = line_numbers[ln_idx][1]
    vim.opt.relativenumber = line_numbers[ln_idx][2]
    ln_idx = (ln_idx % #line_numbers) + 1
end)

vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
vim.keymap.set("n", "<leader>o", vim.cmd.Vex)

--------------------------------------------------
-- Configs
--------------------------------------------------

vim.diagnostic.config({
    underline = false,
    virtual_text = false,
    signs = false,
    update_in_insert = false,
})

--------------------------------------------------
-- Utils
--------------------------------------------------


local function run_build()
    vim.cmd("write")

    local cwd = vim.fn.getcwd()

    if vim.fn.has("win32") == 1 then
        local build = cwd .. "\\build.bat"

        if vim.fn.filereadable(build) == 1 then
            vim.fn.jobstart({ "cmd", "/c", build }, { detach = true })
        else
            vim.notify("build.bat not found")
        end
    else
        local build = cwd .. "/build.sh"

        if vim.fn.filereadable(build) == 1 then
            vim.fn.jobstart({ "bash", build }, { detach = true })
        else
            vim.notify("build.sh not found")
        end
    end
end

vim.keymap.set("n", "<M-l>", run_build)
vim.keymap.set("n", "<F5>", run_build)

--------------------------------------------------
-- lazy.nvim Bootstrap
--------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

--------------------------------------------------
-- Plugins
--------------------------------------------------

require("lazy").setup({

    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({})
        end,
    },
    --
    {
        "ibhagwan/fzf-lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            local fzf = require("fzf-lua")

            vim.keymap.set(
                "n",
                "<leader>f",
                fzf.files,
                { desc = "Find files" }
            )

            vim.keymap.set(
                "n",
                "<leader>g",
                fzf.live_grep,
                { desc = "Live grep" }
            )
        end,
    },

    -- Mason
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },

    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
            vim.o.background = "dark"

            require("gruvbox").setup({
                bold = false,
                transparent_mode = true,
                italic = {
                    strings = false,
                    emphasis = false,
                    comments = false,
                    operators = false,
                    folds = false,
                },
                undercurl = false,
            })

            vim.cmd.colorscheme("gruvbox")
        end,
    },

    -- Mason LSP bridge
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "clangd",
                },
            })
        end,
    },

    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                        },
                    },
                },
            })

            vim.lsp.config("clangd", {})

            vim.lsp.enable("lua_ls")
            vim.lsp.enable("clangd")

            vim.keymap.set("n", "gd", vim.lsp.buf.definition)
            vim.keymap.set("n", "gr", vim.lsp.buf.references)
            vim.keymap.set("n", "K", vim.lsp.buf.hover)
            vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename)
            vim.keymap.set("n", "<leader>lc", vim.lsp.buf.code_action)
            vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float)

            vim.keymap.set("n", "<leader>lf", function()
                vim.lsp.buf.format({ async = true })
            end, { desc = "Format buffer" })

            _G.autoformat_enabled = false

            vim.api.nvim_create_user_command("ToggleAutoFormat", function()
                _G.autoformat_enabled = not _G.autoformat_enabled

                -- vim.notify("Auto format " .. (_G.autoformat_enabled and "enabled" or "disabled"))
            end, {})

            vim.keymap.set("n", "<leader>tf", "<cmd>ToggleAutoFormat<CR>")
            vim.api.nvim_create_autocmd("BufWritePre", {
                callback = function(args)
                    if not _G.autoformat_enabled then
                        return
                    end

                    vim.lsp.buf.format({
                        bufnr = args.buf,
                        async = false,
                    })
                end,
            })
        end,
    },

    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                completion = {
                    autocomplete = false,
                },

                sources = {
                    { name = "nvim_lsp" },
                },

                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),

                    ["<CR>"] = cmp.mapping.confirm({
                        select = true,
                    }),
                }),
            })

            _G.autocmp_enabled = false

            local function update_cmp()
                cmp.setup({
                    completion = {
                        autocomplete = _G.autocmp_enabled and { cmp.TriggerEvent.TextChanged }
                            or false,
                    },
                })
            end

            update_cmp()

            vim.api.nvim_create_user_command("ToggleAutoCmp", function()
                _G.autocmp_enabled = not _G.autocmp_enabled
                update_cmp()

                -- vim.notify(
                --     "Auto completion " ..
                --     (_G.autocmp_enabled and "enabled" or "disabled")
                -- )
            end, {})

            vim.keymap.set("n", "<leader>tc", "<cmd>ToggleAutoCmp<CR>")
        end,
    },

    -- {
    --     "nvim-lualine/lualine.nvim",
    --     dependencies = {
    --         "nvim-tree/nvim-web-devicons",
    --     },
    --     config = function()
    --         require("lualine").setup({
    --             options = {
    --                 theme = "gruvbox",
    --                 globalstatus = true,
    --                 icons_enabled = true,
    --                 component_separators = "",
    --                 section_separators = "",
    --             },
    --
    --             sections = {
    --                 lualine_a = { "mode" },
    --                 lualine_b = { "branch"},
    --
    --                 lualine_c = {
    --
    --                     "filename",
    --                 },
    --
    --                 lualine_x = { 
    --                     {
    --                         function()
    --                             return _G.autocmp_enabled and "CMP:ON" or "CMP:OFF"
    --                         end,
    --                     },
    --
    --                     {
    --                         function()
    --                             return _G.autoformat_enabled and "FMT:ON" or "FMT:OFF"
    --                         end,
    --                     },
    --                 },
    --                 lualine_y = { "filetype" },
    --                 lualine_z = {},
    --             },
    --         })
    --
    --     end,
    -- }
})
