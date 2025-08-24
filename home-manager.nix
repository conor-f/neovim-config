# Home Manager module for integrating this Neovim config
# Add this to your home-manager configuration

{ config, pkgs, lib, ... }:

let
  # Import your Neovim flake
  nvimFlake = builtins.getFlake "path:/Users/personal/.config/nvim";
  
  # Or if you move it to a git repo, use:
  # nvimFlake = builtins.getFlake "github:yourusername/neovim-config";
  
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
      
      # Formatters
      stylua
      
      # Tools used by plugins
      ripgrep
      fd
      fzf
      git
      curl
      unzip
      gcc
      gnumake
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