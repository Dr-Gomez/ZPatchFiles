-- ~/.config/nvim/lua/plugins/alpha.lua
return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional: for file icons
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Set header
    dashboard.section.header.val = {
      "██████╗  ██████╗ ███╗   ███╗██████╗  █████╗ ██████╗  █████╗ ████████╗ ██████╗██╗  ██╗",
      "██╔══██╗██╔═══██╗████╗ ████║██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██║  ██║",
      "██████╔╝██║   ██║██╔████╔██║██████╔╝███████║██████╔╝███████║   ██║   ██║     ███████║",
      "██╔══██╗██║   ██║██║╚██╔╝██║██╔══██╗██╔══██║██╔═══╝ ██╔══██║   ██║   ██║     ██╔══██║",
      "██████╔╝╚██████╔╝██║ ╚═╝ ██║██████╔╝██║  ██║██║     ██║  ██║   ██║   ╚██████╗██║  ██║",
      "╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝",
    }

    -- Set menu
    dashboard.section.buttons.val = {
      dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button("f", "󰆋  Find file", ":Telescope find_files <CR>"),
      dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
      dashboard.button("s", "  Settings", ":e $MYVIMRC <CR>"),
      dashboard.button("q", "󰩈  Quit", ":qa<CR>"),
    }

    -- Set footer
    local function footer()
      return "  Powered by Neovim"
    end
    dashboard.section.footer.val = footer()

    -- Set up alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
