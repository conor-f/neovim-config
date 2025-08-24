{
  description = "Personal Neovim configuration with all dependencies";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Define LSP servers and tools
        lspServers = (with pkgs.nodePackages; [
          # Node-based language servers
          typescript-language-server
          vscode-langservers-extracted  # html, css, json, eslint
          yaml-language-server
          dockerfile-language-server-nodejs
          bash-language-server
        ]) ++ (with pkgs; [
          # Other language servers
          lua-language-server
          pyright  # Python language server
          # Note: Vue language server (volar) needs to be installed via Mason in Neovim
          # as the Nix package is deprecated
        ]);

        # Formatters and linters
        formatters = with pkgs; [
          stylua          # Lua formatter
          prettierd       # Fast prettier
          nodePackages.prettier  # Prettier fallback
          black           # Python formatter
          isort           # Python import sorter
          shfmt           # Shell formatter
          jq              # JSON processor/formatter
        ];

        # Additional tools
        additionalTools = with pkgs; [
          # Core tools
          ripgrep
          fd
          fzf
          git
          curl
          unzip
          gcc
          gnumake
          
          # Language runtimes needed by language servers
          nodejs
          python3
          python3Packages.pip
          
          # Just for justfile support
          just
          
          # Tree-sitter CLI for parser management
          tree-sitter
        ];

        # All tools combined
        allTools = lspServers ++ formatters ++ additionalTools;

        # Create fully self-contained neovim with bundled config
        nvimWrapper = pkgs.writeShellScriptBin "nvim" ''
          # Create writable directories in user's home for nvim data
          export NVIM_APPNAME="nvim-nix-config"
          export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
          export XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}" 
          export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
          
          # Create the directories if they don't exist
          mkdir -p "$XDG_DATA_HOME/$NVIM_APPNAME"
          mkdir -p "$XDG_STATE_HOME/$NVIM_APPNAME"
          mkdir -p "$XDG_CACHE_HOME/$NVIM_APPNAME"
          
          # Set up config from the Nix store (read-only)
          export XDG_CONFIG_HOME="${self}"
          
          # Ensure all tools are in PATH
          export PATH="${pkgs.lib.makeBinPath allTools}:$PATH"
          
          # Run neovim with the bundled config
          exec ${pkgs.neovim}/bin/nvim "$@"
        '';

      in {
        # Default package - fully self-contained
        packages.default = nvimWrapper;

        # Development shell for working on this config itself
        devShells.default = pkgs.mkShell {
          buildInputs = [ 
            pkgs.neovim
          ] ++ allTools;
          
          shellHook = ''
            echo "🚀 Neovim config development environment!"
            echo "📦 Available language servers: typescript, html/css/json, yaml, dockerfile, bash, python, lua"
            echo "🎨 Available formatters: prettier, black, stylua, shfmt, jq"
            echo "🔧 Additional tools: ripgrep, fd, fzf, git, just"
            echo ""
            echo "💡 This shell is for developing the config itself"
            echo "📝 Use 'nix run .' to test the bundled config"
          '';
        };

        # App for nix run - fully self-contained
        apps.default = {
          type = "app";
          program = "${nvimWrapper}/bin/nvim";
        };
      });
}