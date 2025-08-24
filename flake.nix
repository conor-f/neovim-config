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
          
          # Always use the user's standard neovim config locations
          # This assumes you have the config installed at ~/.config/nvim
          exec ${pkgs.neovim}/bin/nvim "$@"
        '';

      in {
        # Default package - just the tools wrapper
        packages.default = nvimWrapper;
        
        # Separate package with bundled config (for testing)
        packages.nvim-with-config = pkgs.symlinkJoin {
          name = "nvim-with-config";
          paths = [ nvimWrapper ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/nvim \
              --set XDG_CONFIG_HOME ${self}
          '';
        };

        # Development shell with all tools
        devShells.default = pkgs.mkShell {
          buildInputs = [ 
            pkgs.neovim
          ] ++ allTools;
          
          shellHook = ''
            echo "🚀 Neovim development environment loaded!"
            echo "📦 Available language servers: typescript, html/css/json, yaml, dockerfile, bash, python, lua"
            echo "🎨 Available formatters: prettier, black, stylua, shfmt, jq"
            echo "🔧 Additional tools: ripgrep, fd, fzf, git, just"
            echo ""
            echo "💡 Use 'nvim' to start Neovim with your ~/.config/nvim config"
            echo "📝 All language servers and formatters are available in PATH"
          '';
        };

        # App for nix run - uses your local config
        apps.default = {
          type = "app";
          program = "${nvimWrapper}/bin/nvim";
        };
        
        # App for testing with bundled config
        apps.nvim-with-config = {
          type = "app";
          program = "${self.packages.${system}.nvim-with-config}/bin/nvim";
        };
      });
}