# Home Manager module for integrating this Neovim config
# Add this to your home-manager configuration

{ config, pkgs, lib, ... }:

let
  # Import your Neovim flake from GitHub
  nvimFlake = builtins.getFlake "github:conor-f/neovim-config";
  
  # Or use a local path if you cloned the repo:
  # nvimFlake = builtins.getFlake "path:/path/to/neovim-config";
  
in {
  # Option 1: Use the flake package directly
  home.packages = [ nvimFlake.packages.${pkgs.system}.default ];
  
  # Option 2: Use home-manager's programs.neovim with the config
  programs.neovim = {
    enable = true;
    
    # Copy your init.lua content here, or reference the file
    extraLuaConfig = builtins.readFile ./init.lua;
    
    # Add plugins that aren't managed by lazy.nvim but you want Nix to manage
    plugins = with pkgs.vimPlugins; [
      # These will be available to your config but you'll still use lazy.nvim
      # for most plugin management as in your current setup
    ];
    
    # Ensure required tools are available
    extraPackages = with pkgs; [
      # LSP servers
      lua-language-server
      pyright  # Python language server
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted  # html, css, json
      nodePackages.yaml-language-server
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.bash-language-server
      # Note: Vue language server (volar) will be installed via Mason as the Nix package is deprecated
      
      # Formatters and tools
      stylua
      prettierd
      nodePackages.prettier
      black
      isort
      shfmt
      jq
      
      # Core tools
      ripgrep
      fd
      fzf
      git
      curl
      unzip
      gcc
      gnumake
      nodejs
      python3
      python3Packages.pip
      just
    ];
  };
  
  # Create aliases for convenience
  home.shellAliases = {
    nvim = "nvim";
    vim = "nvim";
  };
  
  # Set environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}