{
  description = "Personal Neovim configuration with all dependencies";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Define LSP servers and tools based on your config
        lspServers = with pkgs; [
          lua-language-server
          stylua
        ];

        # Additional tools that might be useful
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

        # Create a wrapped neovim with all dependencies
        neovimWithConfig = pkgs.wrapNeovim pkgs.neovim {
          configure = {
            customRC = ''
              set runtimepath^=${self}/nvim
              set runtimepath+=${self}/nvim/after
              lua dofile("${self}/nvim/init.lua")
            '';
          };
        };

        # Create the main package
        neovimPackage = pkgs.stdenv.mkDerivation {
          pname = "nvim-config";
          version = "1.0.0";
          
          src = ./.;
          
          nativeBuildInputs = [ pkgs.makeWrapper ];
          
          installPhase = ''
            mkdir -p $out/bin
            mkdir -p $out/nvim
            
            # Copy configuration files
            cp -r $src/* $out/nvim/
            
            # Create wrapper script
            makeWrapper ${neovimWithConfig}/bin/nvim $out/bin/nvim \
              --prefix PATH : ${pkgs.lib.makeBinPath (lspServers ++ additionalTools)}
          '';
          
          meta = with pkgs.lib; {
            description = "Personal Neovim configuration";
            homepage = "https://github.com/nvim-lua/kickstart.nvim";
            license = licenses.mit;
            maintainers = [ maintainers.self ];
            platforms = platforms.all;
          };
        };

      in {
        # Default package
        packages.default = neovimPackage;
        
        # Alternative package names
        packages.nvim = neovimPackage;
        packages.neovim = neovimPackage;

        # Development shell with all tools
        devShells.default = pkgs.mkShell {
          buildInputs = [ 
            pkgs.neovim
          ] ++ lspServers ++ additionalTools;
          
          shellHook = ''
            echo "Neovim development environment loaded!"
            echo "Available tools: nvim, lua-language-server, stylua, ripgrep, fd, fzf"
          '';
        };

        # App for easy running
        apps.default = {
          type = "app";
          program = "${neovimPackage}/bin/nvim";
        };

        # Alternative apps
        apps.nvim = self.apps.${system}.default;
        apps.neovim = self.apps.${system}.default;
      });
}