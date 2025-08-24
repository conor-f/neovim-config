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

        # Create fully self-contained neovim with bundled config
        nvimWrapper = pkgs.symlinkJoin {
          name = "nvim-with-config";
          paths = [ pkgs.neovim ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            # Create config directory structure
            mkdir -p $out/share/nvim-config
            cp -r ${self}/* $out/share/nvim-config/
            
            # Wrap nvim to use bundled config and tools
            wrapProgram $out/bin/nvim \
              --set PATH "${pkgs.lib.makeBinPath allTools}:$PATH" \
              --set XDG_CONFIG_HOME "$out/share" \
              --set NVIM_APPNAME "nvim-config"
          '';
        };

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