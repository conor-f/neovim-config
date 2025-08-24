# Nix-based Neovim Configuration

This repository contains a Neovim configuration packaged with Nix for reproducible setups across Mac and Linux systems.

## What is Nix?

Nix is a package manager and build system that provides:
- **Reproducible builds**: Same exact environment across different machines
- **Declarative configuration**: Define what you want, not how to get it
- **Cross-platform**: Works on macOS, Linux, and more
- **Isolation**: Dependencies don't interfere with system packages

## Prerequisites

1. **Install Nix** (works on macOS and Linux):
   ```bash
   # Option 1: Official installer (recommended)
   curl -L https://nixos.org/nix/install | sh
   
   # Option 2: Determinate Systems installer (faster, better UX)
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Enable flakes** (required for this config):
   ```bash
   # Add to ~/.config/nix/nix.conf (create directory if needed)
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

## Quick Start

### Method 1: Run Directly from this Directory

Navigate to this config directory and run:

```bash
# Run Neovim with full configuration
nix run .

# Or build and install to your profile
nix profile install .
```

### Method 2: Run from GitHub (if you push this to a repo)

```bash
# Replace with your actual GitHub repo
nix run github:yourusername/neovim-config
```

### Method 3: Development Shell

Get a development environment with all tools:

```bash
nix develop
# Now 'nvim' and all LSP servers/tools are available
```

## Installation Methods

### Temporary Usage

```bash
# Try it once without installing
nix run .
```

### Install to User Profile

```bash
# Install permanently for current user
nix profile install .

# List installed packages
nix profile list

# Remove later if needed
nix profile remove <index-from-list>
```

### Using with Home Manager

If you use Home Manager, copy the `home-manager.nix` file and integrate it:

1. **Add to your existing home-manager config:**
   ```nix
   # In your home.nix or wherever you manage home-manager
   imports = [ 
     ./path/to/this/neovim/home-manager.nix 
   ];
   ```

2. **Apply the configuration:**
   ```bash
   home-manager switch
   ```

### System-wide Installation (NixOS only)

Add to your NixOS configuration:

```nix
# In /etc/nixos/configuration.nix
environment.systemPackages = [
  (import /path/to/this/config {}).packages.${pkgs.system}.default
];
```

## Directory Structure

```
~/.config/nvim/
├── flake.nix           # Main Nix configuration
├── flake.lock          # Locked dependencies
├── home-manager.nix    # Home Manager integration
├── init.lua            # Your Neovim config (unchanged)
├── lazy-lock.json      # Lazy.nvim lockfile (unchanged)
├── lua/                # Lua configuration (unchanged)
└── README-NIX.md       # This file
```

## How It Works

1. **Nix flake** (`flake.nix`) defines:
   - Neovim package with your configuration
   - All LSP servers and tools as dependencies
   - Development shell with everything pre-installed

2. **Your existing config** (`init.lua`, `lua/`) remains unchanged
   - Lazy.nvim still manages most plugins
   - All your keybindings and settings work exactly the same

3. **Package wrapping** ensures:
   - All tools (ripgrep, fd, LSP servers) are available in PATH
   - No need to install anything manually
   - Works identically on any machine with Nix

## Adding New Tools

Edit `flake.nix` and add tools to the appropriate arrays:

```nix
# For LSP servers
lspServers = with pkgs; [
  lua-language-server
  rust-analyzer        # Add this
  typescript-language-server  # Add this
];

# For general tools
additionalTools = with pkgs; [
  ripgrep
  fd
  nodejs    # Add this for some plugins
];
```

Then rebuild:
```bash
nix run . --recreate-lock-file
```

## Troubleshooting

### "experimental-features" Error
```bash
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### LSP Server Not Working
The LSP servers are automatically added to PATH when running through Nix. If Mason tries to install them, it might conflict. You can:

1. Let Mason install (will use Mason's versions)
2. Or disable Mason's auto-installation for tools provided by Nix

### Plugin Installation Issues
Your existing lazy.nvim setup should work unchanged. If there are issues:

1. Clear lazy cache: `:Lazy clear`
2. Reinstall plugins: `:Lazy sync`

### Different Behavior on Different Machines
This usually means:
1. Nix isn't properly set up on one machine
2. Different versions of the flake are being used

Check with:
```bash
nix flake metadata .
```

## Updating

Update the flake inputs:
```bash
nix flake update
```

Rebuild:
```bash
nix run . --recreate-lock-file
```

## Benefits of This Setup

1. **Reproducible**: Same environment on any machine with Nix
2. **No global installs**: Tools are isolated and don't conflict
3. **Version pinning**: Exact versions are locked and reproducible
4. **Easy sharing**: Others can use your exact setup with `nix run`
5. **Rollback**: Easy to revert to previous configurations
6. **Cross-platform**: Works on macOS, Linux, WSL

## Migration from Pure Lazy.nvim

Your current config will work without changes. Benefits of adding Nix:

- **Before**: Install nvim, then install ripgrep, fd, LSP servers separately
- **After**: `nix run .` gives you everything at once

Your lazy.nvim plugin management continues to work exactly the same.

## Advanced Usage

### Custom Neovim Build
Modify the flake to use a specific Neovim version:

```nix
neovim = pkgs.neovim-nightly;  # Use nightly builds
```

### Environment Variables
Add environment variables in the wrapper:

```nix
makeWrapper ... \
  --set SOME_VAR "value"
```

### Binary Cache
Speed up builds by using binary caches:

```bash
# Add to ~/.config/nix/nix.conf
substituters = https://cache.nixos.org https://nix-community.cachix.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
```

This setup gives you a fully reproducible Neovim environment that works identically across all your machines!