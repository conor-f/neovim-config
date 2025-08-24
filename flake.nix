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
        lspServers = with pkgs; [
          lua-language-server
          stylua
        ];

        # Additional tools
        additionalTools = with pkgs; [
          ripgrep
          fd
          fzf
          git
          curl
          unzip
          gcc
          gnumake
        ];

        # Create neovim wrapper script
        nvimWrapper = pkgs.writeShellScriptBin "nvim" ''
          export PATH=${pkgs.lib.makeBinPath (lspServers ++ additionalTools)}:$PATH
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
          ] ++ lspServers ++ additionalTools;
          
          shellHook = ''
            echo "Neovim development environment loaded!"
            echo "Available tools: nvim, lua-language-server, stylua, ripgrep, fd, fzf"
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