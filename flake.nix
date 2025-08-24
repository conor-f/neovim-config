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
        lspServers = with pkgs.nodePackages; [
          # Language servers
          typescript-language-server
          vscode-langservers-extracted  # html, css, json, eslint
          yaml-language-server
          dockerfile-language-server-nodejs
          vue-language-server
          bash-language-server
          pyright
        ] ++ (with pkgs; [
          lua-language-server
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
          cd ${self}
          exec ${pkgs.neovim}/bin/nvim -u ${self}/init.lua "$@"
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