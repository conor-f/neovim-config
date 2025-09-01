# Neovim Nix Configuration - Usage Guide

A fully self-contained Neovim configuration packaged with Nix for reproducible development environments.

## Quick Start

### 🚀 Install and Use

```bash
# Install the configuration (one command, zero setup)
nix profile add github:conor-f/neovim-config

# Start using Neovim with full configuration
nvim
```

That's it! The first time you run `nvim`, all plugins will install automatically.

## Management Commands

### 🔄 Upgrade to Latest Version

```bash
nix profile upgrade neovim-config
```

### 🔄 Force Reinstall (Clean Cache)

If you encounter issues or want a completely fresh installation:

```bash
# Remove existing installation
nix profile remove neovim-config

# Clear all cached data
rm -rf ~/.local/share/nvim-nix-config
rm -rf ~/.local/state/nvim-nix-config
rm -rf ~/.cache/nvim-nix-config

# Reinstall fresh
nix profile add github:conor-f/neovim-config
```

### 📋 Check What's Installed

```bash
# List all profile packages
nix profile list

# Check if neovim-config is installed
nix profile list | grep neovim-config
```

## Making Changes

### 🛠 Modifying the Configuration

If you want to customize the configuration:

1. **Fork the repository**:
   ```bash
   # On GitHub, fork https://github.com/conor-f/neovim-config
   ```

2. **Clone your fork locally**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/neovim-config.git
   cd neovim-config
   ```

3. **Make your changes** to `init.lua`, add plugins, etc.

4. **Test your changes locally**:
   ```bash
   nix run .
   ```

5. **Install your custom version**:
   ```bash
   nix profile remove neovim-config  # Remove original
   nix profile add github:YOUR-USERNAME/neovim-config  # Add yours
   ```

### 📝 Common Customizations

#### Adding New Plugins

Edit `init.lua` and add plugins to the `lazy.setup()` table:

```lua
require('lazy').setup({
  -- Existing plugins...
  
  -- Add your new plugin
  'author/plugin-name',
  
  -- Or with configuration
  {
    'author/plugin-name',
    config = function()
      -- Plugin setup
    end,
  },
})
```

#### Changing Key Bindings

Add custom keymaps anywhere in `init.lua`:

```lua
-- Custom keybinding example
vim.keymap.set('n', '<leader>x', ':YourCommand<CR>', { desc = 'Your description' })
```

#### Adding Language Servers

Edit the `servers` table in `init.lua`:

```lua
local servers = {
  -- Existing servers...
  
  -- Add new language server
  your_language_server = {
    settings = {
      -- Server-specific settings
    },
  },
}
```

## Alternative Usage Patterns

### 🧪 Try Without Installing

```bash
# Test the configuration without installing
nix run github:conor-f/neovim-config
```

### 🏗 Development Environment

```bash
# Enter development shell with all tools available
nix develop github:conor-f/neovim-config
```

### 🏠 Project-Specific Usage

Add to your project's `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-config.url = "github:conor-f/neovim-config";
  };
  
  outputs = { nixpkgs, neovim-config, ... }:
    let
      system = "x86_64-linux";  # or your system
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          neovim-config.packages.${system}.default
          # Your project dependencies
        ];
      };
    };
}
```

Then use with:
```bash
nix develop
nvim
```

## New Machine Setup

### 🆕 Complete Setup on Fresh Machine

1. **Install Nix**:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Install the Neovim configuration**:
   ```bash
   nix profile add github:conor-f/neovim-config
   ```

3. **Start using**:
   ```bash
   nvim
   ```

That's it! You now have the complete development environment on any machine.

## Troubleshooting

### 🔧 Common Issues

#### Configuration Not Loading
```bash
# Check if profile is installed
nix profile list | grep neovim-config

# Verify command exists
which nvim
```

#### Plugins Not Installing
```bash
# Check data directory
ls -la ~/.local/share/nvim-nix-config/

# Force clean reinstall (see "Force Reinstall" above)
```

#### Language Servers Not Working
```bash
# In neovim, check LSP status
:LspInfo
:Mason
:checkhealth lsp
```

### 🩺 Health Check

```bash
# Start nvim and run health check
nvim -c ':checkhealth'
```

### 🆘 Reset Everything

If something goes wrong, complete reset:

```bash
# Remove from profile
nix profile remove neovim-config

# Clear all data
rm -rf ~/.local/share/nvim-nix-config
rm -rf ~/.local/state/nvim-nix-config  
rm -rf ~/.cache/nvim-nix-config

# Clear Nix cache (optional, if needed)
nix-collect-garbage -d

# Reinstall
nix profile add github:conor-f/neovim-config
```

## What's Included

### 🛠 Tools and Servers

- **Language Servers**: TypeScript, Python, HTML, CSS, JSON, YAML, Lua, Bash, Docker
- **Formatters**: Prettier, Black, stylua, shfmt, jq
- **Tools**: ripgrep, fd, fzf, git, nodejs, python3, just

### 🎛 Key Features

- **File Management**: `<Ctrl-n>` for file explorer
- **Git Integration**: `]h`/`[h` for hunks, `<leader>hs` to stage
- **Formatting**: `<leader>f` for format, `<leader>fj`/`<leader>fp` for JSON/Python
- **Search**: `<leader>sf` files, `<leader>sg` grep, `<leader>sw` word under cursor
- **LSP**: Full language server protocol support with diagnostics and completion

### 🚫 Isolation

- **Completely isolated** from any existing Neovim configuration
- **No conflicts** with `~/.config/nvim`
- **Self-contained** - everything bundled in Nix package
- **Reproducible** - identical setup on any machine

## Support

For issues, questions, or feature requests, please open an issue at:
https://github.com/conor-f/neovim-config/issues