# Personal Neovim Configuration

A modern, well-documented Neovim configuration with comprehensive language support, git integration, and automated formatting.

## Features

- **Git Integration**: Navigate between changes, view diffs, and manage hunks
- **Language Support**: Full support for React, Python, Docker, justfiles, YAML, JSON, HTML, JSX, CSS, Lua, Vue, and shell scripts
- **Auto-formatting**: Automatic linting and formatting on save
- **Modern UI**: Clean interface with file explorer and enhanced statusline
- **Extensible**: Easy to customize and extend

## Installation

### Prerequisites

- Neovim 0.9.0+ (latest stable recommended)
- Git
- A C compiler (gcc/clang)
- [ripgrep](https://github.com/BurntSushi/ripgrep) for telescope searching
- Node.js and npm (for language servers)
- Python 3 and pip (for Python language server)

### Install

1. **Backup existing config** (if any):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone this configuration**:
   ```bash
   git clone https://github.com/conor-f/neovim-config.git ~/.config/nvim
   ```

3. **Start Neovim**:
   ```bash
   nvim
   ```
   
   Plugins will automatically install on first run.

## Nix Installation & Usage

This configuration includes comprehensive Nix support for reproducible development environments.

### Quick Start with Nix

**Option 1: Install to your profile (recommended)**
```bash
# First, clone this config to ~/.config/nvim
git clone https://github.com/conor-f/neovim-config.git ~/.config/nvim

# Then install the tools wrapper to your profile
nix profile add github:conor-f/neovim-config

# Now 'nvim' command has all language servers and formatters available
nvim
```

**Option 2: Development shell**
```bash
nix develop github:conor-f/neovim-config
# All tools are available, use with your existing ~/.config/nvim
```

**Option 3: Try without installing**
```bash
# Test the bundled config (read-only, for demonstration)
nix run github:conor-f/neovim-config#nvim-with-config

# Or just run with tools available (uses your ~/.config/nvim)
nix run github:conor-f/neovim-config
```

### Nix Flake Integration

Add to your system flake inputs:
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-config.url = "github:conor-f/neovim-config";
  };
  
  outputs = { self, nixpkgs, neovim-config, ... }: {
    # Your system configuration
    nixosConfigurations.yourhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          environment.systemPackages = [
            neovim-config.packages.x86_64-linux.default
          ];
        }
      ];
    };
  };
}
```

### Home Manager Integration

Add to your `home.nix`:
```nix
{ config, pkgs, ... }:

{
  imports = [
    # Import the home-manager module
    (builtins.getFlake "github:conor-f/neovim-config").homeManagerModules.default
  ];
  
  # Or manually configure:
  home.packages = [
    (builtins.getFlake "github:conor-f/neovim-config").packages.${pkgs.system}.default
  ];
}
```

Or copy the provided `home-manager.nix` file to your home-manager configuration.

### Development Environments

#### Project-specific shell

Create a `shell.nix` in your project:
```nix
{ pkgs ? import <nixpkgs> {} }:

let
  neovim-config = builtins.getFlake "github:conor-f/neovim-config";
in
pkgs.mkShell {
  buildInputs = [
    neovim-config.packages.${pkgs.system}.default
    # Your project-specific dependencies
  ];
}
```

#### Flake-based development

Create a `flake.nix` for your project:
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-config.url = "github:conor-f/neovim-config";
  };
  
  outputs = { nixpkgs, neovim-config, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          neovim-config.packages.${system}.default
          # Add your project dependencies here
        ];
      };
    };
}
```

### What's Included in the Nix Environment

The Nix flake automatically provides:

**Language Servers:**
- TypeScript/JavaScript (typescript-language-server)
- HTML/CSS/JSON (vscode-langservers-extracted)
- YAML (yaml-language-server) 
- Docker (dockerfile-language-server)
- Vue.js (vue-language-server)
- Bash (bash-language-server)
- Python (pyright)
- Lua (lua-language-server)

**Formatters:**
- Prettier/Prettierd (JS/TS/JSON/YAML/CSS/HTML)
- Black + isort (Python)
- stylua (Lua)
- shfmt (Shell scripts)
- jq (JSON processing)

**Development Tools:**
- Node.js and Python runtimes
- ripgrep, fd, fzf for telescope
- git, curl, unzip, gcc, make
- just (for justfile support)

### Nix Configuration Files

- `flake.nix` - Main flake definition with all dependencies
- `home-manager.nix` - Home Manager integration example
- `flake.lock` - Pinned dependency versions for reproducibility

### Customizing the Nix Setup

1. **Fork the repository**
2. **Modify `flake.nix`** to add/remove tools:
   ```nix
   # Add your preferred tools
   additionalTools = with pkgs; [
     ripgrep
     fd
     # Add more tools here
   ];
   ```
3. **Update flake.lock**:
   ```bash
   nix flake lock --update-input nixpkgs
   ```

### Troubleshooting Nix Setup

**Enable flakes** (if not already enabled):
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

**Check what's available**:
```bash
nix flake show github:conor-f/neovim-config
```

**Build locally**:
```bash
git clone https://github.com/conor-f/neovim-config.git
cd neovim-config
nix build
./result/bin/nvim
```

## Configuration Structure

```
~/.config/nvim/
├── init.lua                    # Main configuration file
├── lua/
│   ├── kickstart/
│   │   ├── plugins/
│   │   │   ├── gitsigns.lua   # Git integration
│   │   │   ├── neo-tree.lua   # File explorer
│   │   │   ├── autopairs.lua  # Auto-close brackets
│   │   │   ├── debug.lua      # Debug adapter protocol
│   │   │   ├── lint.lua       # Linting configuration
│   │   │   └── indent_line.lua # Indentation guides
│   │   └── health.lua         # Health checks
│   └── custom/
│       └── plugins/           # Your custom plugins
└── lazy-lock.json            # Plugin version lock file
```

## Key Bindings

### General
- `<leader>` = `<Space>`
- `<leader>sh` - Search help documentation
- `<leader>sk` - Search keymaps
- `<leader>sf` - Search files
- `<leader>sw` - Search current word
- `<leader>sg` - Live grep
- `<leader>sd` - Search diagnostics

### File Management
- `<Ctrl-n>` - Toggle file explorer (Neo-tree)
- `<leader>` + `?` - Show recent files

### Git Integration (Gitsigns)
- `]h` - Next git hunk
- `[h` - Previous git hunk
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hp` - Preview hunk diff
- `<leader>hb` - Blame line
- `<leader>hd` - Diff against index
- `<leader>hD` - Diff against last commit

### Code Formatting
- `<leader>f` - Format current buffer
- `<leader>fj` - Format selection as JSON
- `<leader>fp` - Format selection as Python dict

### LSP (Language Server Protocol)
- `gd` - Go to definition
- `gr` - Go to references
- `gI` - Go to implementation
- `<leader>D` - Type definition
- `<leader>ds` - Document symbols
- `<leader>ws` - Workspace symbols
- `<leader>rn` - Rename
- `<leader>ca` - Code actions
- `K` - Hover documentation

## Plugin Overview

### Git Integration - Gitsigns
Provides git integration directly in the editor:
- **Hunk navigation**: Jump between changed sections
- **Stage/unstage hunks**: Stage individual changes
- **Diff preview**: View changes without leaving the editor
- **Blame integration**: See who changed what line

### Language Support
Comprehensive language server support for:
- **React/JSX**: Full TypeScript/JavaScript support with React
- **Python**: Advanced features with Pylsp/Pyright
- **Docker**: Dockerfile syntax and linting
- **Justfiles**: Just build tool support
- **YAML/JSON**: Schema validation and formatting
- **HTML/CSS**: Modern web development support
- **Lua**: Neovim configuration development
- **Vue**: Vue.js single file component support
- **Shell**: Bash/Zsh script support

### Auto-formatting and Linting
- **Format on save**: Automatic code formatting when saving files
- **Multiple formatters**: Prettier, Black, rustfmt, and more
- **Linting**: Real-time error checking and suggestions
- **Configuration**: Respects project-specific formatting rules

### File Explorer - Neo-tree
Modern file tree with:
- **Git integration**: Show file status in tree
- **Buffer management**: Switch between open files
- **File operations**: Create, delete, rename files and directories

## Making Configuration Updates

### Adding New Plugins

1. **Create plugin file**: Add a new file in `lua/kickstart/plugins/` or `lua/custom/plugins/`
2. **Plugin structure**:
   ```lua
   return {
     'author/plugin-name',
     config = function()
       -- Plugin configuration
     end,
     -- Optional: lazy loading conditions
     event = 'VeryLazy',
   }
   ```
3. **Restart Neovim**: Plugins will auto-install

### Modifying Existing Plugins

1. **Find the plugin file**: Look in `lua/kickstart/plugins/`
2. **Edit configuration**: Modify the config function
3. **Reload**: `:source %` or restart Neovim

### Customizing Key Bindings

Edit `init.lua` and modify the keymaps section:
```lua
vim.keymap.set('n', '<leader>your-key', function()
  -- Your custom function
end, { desc = 'Description of what this does' })
```

### Adding Language Support

1. **Install language server**: Usually handled automatically by Mason
2. **Configure in init.lua**: Add to the `servers` table
3. **Add treesitter parser**: Include in `ensure_installed` list

### Project-Specific Settings

Create `.nvim.lua` in your project root:
```lua
-- Project-specific Neovim settings
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
```

## Troubleshooting

### Check Health
Run `:checkhealth` to diagnose issues with your setup.

### Plugin Issues
- `:Lazy` - Open plugin manager
- `:Lazy sync` - Update all plugins
- `:Lazy clean` - Remove unused plugins

### Language Server Issues
- `:LspInfo` - Show attached language servers
- `:Mason` - Manage language servers and tools

### Reset Configuration
If something breaks, you can reset:
```bash
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This configuration is based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) and is available under the MIT license.