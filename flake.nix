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
        ];

        # All tools combined
        allTools = lspServers ++ formatters ++ additionalTools;

        # Create neovim wrapper script
        nvimWrapper = pkgs.writeShellScriptBin "nvim" ''
          export PATH=${pkgs.lib.makeBinPath allTools}:$PATH
          # Use the config from the current directory or user's config
          if [ -f "./init.lua" ]; then
            exec ${pkgs.neovim}/bin/nvim -u ./init.lua "$@"
          elif [ -d "$HOME/.config/nvim" ]; then
            NVIM_APPNAME=nvim exec ${pkgs.neovim}/bin/nvim "$@"
          else
            # Fallback to the config from this flake
            export XDG_CONFIG_HOME=${self}
            exec ${pkgs.neovim}/bin/nvim "$@"
          fi
        '';

      in {
        # Default package
        packages.default = nvimWrapper;

        # Development shell with all tools
        devShells.default = pkgs.mkShell {
          buildInputs = [ 
            pkgs.neovim
          ] ++ allTools;
          
          shellHook = ''
            echo "🚀 Neovim development environment loaded!"
            echo "📦 Available language servers: typescript, html/css/json, yaml, dockerfile, vue, bash, python, lua"
            echo "🎨 Available formatters: prettier, black, stylua, shfmt, jq"
            echo "🔧 Additional tools: ripgrep, fd, fzf, git, just"
            echo ""
            echo "💡 Use 'nvim' to start with full language support"
            export NVIM_APPNAME="nvim-config"
          '';
        };

        # App for nix run
        apps.default = {
          type = "app";
          program = "${nvimWrapper}/bin/nvim";
        };
      });
}