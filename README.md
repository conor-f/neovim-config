# Neovim Nix Configuration

A modern, fully self-contained Neovim configuration packaged with Nix for reproducible development environments.

## ✨ Features

- 🚀 **Zero-dependency install**: One command and you're ready
- 🔧 **Complete toolchain**: Language servers, formatters, and tools included
- 🌍 **Reproducible**: Identical setup on any machine with Nix
- 🛡️ **Isolated**: Won't interfere with existing Neovim configs
- 🎯 **Production-ready**: Clean, fast, and reliable

## 🚀 Quick Start

```bash
# Install on any machine with Nix
nix profile add github:conor-f/neovim-config

# Start using immediately
nvim
```

That's it! First run will auto-install all plugins.

## 📖 Full Documentation

- **[USAGE.md](USAGE.md)** - Complete usage guide, troubleshooting, and customization
- **Key bindings and features** - See below

## 🎯 New Machine Setup

1. **Install Nix** (if not already installed):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Install this configuration**:
   ```bash
   nix profile add github:conor-f/neovim-config
   ```

3. **Done!** Run `nvim` anywhere.

## 🔄 Management

```bash
# Upgrade to latest version
nix profile upgrade neovim-config

# Force clean reinstall
nix profile remove neovim-config
nix profile add github:conor-f/neovim-config

# Try without installing
nix run github:conor-f/neovim-config
```

## 🛠 What's Included

### Language Support
- **TypeScript/JavaScript** - Full React/JSX support
- **Python** - Advanced features with Pyright
- **HTML/CSS/JSON** - Modern web development
- **YAML** - Schema validation and formatting
- **Docker** - Dockerfile syntax and linting
- **Shell** - Bash/Zsh script support
- **Lua** - Neovim configuration development
- **Justfiles** - Just build tool support

### Tools & Features
- **Formatters**: Prettier, Black, stylua, shfmt, jq
- **File Explorer**: Neo-tree with git integration
- **Git Integration**: Gitsigns with hunk navigation
- **Search**: Telescope with ripgrep/fd
- **Auto-formatting**: Format on save
- **LSP**: Full language server protocol support

## ⌨️ Key Bindings

| Key | Action | Description |
|-----|--------|-------------|
| **General** |
| `<Space>` | Leader key | Primary modifier |
| `<leader>sf` | Search files | Find files with telescope |
| `<leader>sg` | Live grep | Search text in all files |
| `<leader>sw` | Search word | Search current word |
| `<Ctrl-n>` | File explorer | Toggle Neo-tree |
| **Git Integration** |
| `]h` / `[h` | Next/prev hunk | Navigate git changes |
| `<leader>hs` | Stage hunk | Stage current change |
| `<leader>hp` | Preview hunk | Show diff in popup |
| `<leader>hb` | Git blame | Show line blame |
| **Code** |
| `<leader>f` | Format buffer | Format current file |
| `<leader>fj` | Format as JSON | Convert selection to JSON |
| `<leader>fp` | Format as Python | Convert to Python dict |
| `gd` | Go to definition | Jump to symbol definition |
| `K` | Show docs | Hover documentation |
| `<leader>ca` | Code actions | Show available actions |

## 🔧 Customization

See **[USAGE.md](USAGE.md)** for:
- Making configuration changes
- Adding plugins
- Customizing key bindings  
- Project-specific setups
- Troubleshooting

## 📦 Based On

This configuration extends [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) with Nix packaging for reproducible environments.