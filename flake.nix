{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgsOld.url = "github:nixos/nixpkgs/70bdadeb94ffc8806c0570eb5c2695ad29f0e421";
    nix-appimage = {
      url = "github:ralismark/nix-appimage";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      inherit (inputs.nixpkgs) lib;
      forEachSystem = f: lib.mapAttrs f inputs.nixpkgs.legacyPackages;

      mkNeovim = with builtins; pkgs:
        let
          grammarName = with lib; g: pipe g [ getName (removeSuffix "-grammar") (removePrefix "tree-sitter-") (replaceStrings [ "-" ] [ "_" ]) ];
          grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
            nix python
            inputs.nixpkgsOld.legacyPackages.${pkgs.targetPlatform.system}.vimPlugins.nvim-treesitter.builtGrammars.haskell
          ];
          customConfig = (pkgs.runCommand "custom-config" { } (''
            mkdir -p $out/{after/ftplugin,lsp,parser,queries}
            install -m644 ${./init.lua} $out
            find ${./after/ftplugin} -name '*.lua' -exec install -m644 '{}' $out/after/ftplugin \;
            find ${./lsp} -name '*.lua' -exec install -m644 '{}' $out/lsp \;

            install-treesitter-grammar() {
              origGrammar="$1"
              grammarName="$2"
              installQueries="$3"

              install -m644 "$origGrammar/parser" "$out/parser/$grammarName.so"
              if [ "$installQueries" == 1 ]; then
                mkdir -p "$out/queries/$grammarName"
                if [ -d "$origGrammar/queries/$grammarName" ]; then
                  origQueries="$origGrammar/queries/$grammarName"
                else
                  origQueries="$origGrammar/queries"
                fi
                find "$origQueries" -type f -exec install -m644 '{}' $out/queries/$grammarName/ \;
              fi
            }
            ''
            + concatStringsSep "\n" (map (g: "install-treesitter-grammar ${g} ${grammarName g} 1") grammars)
            + ''

            '')
          ) // { pname = "custom-config-plugin"; };
        in pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
          extraName = "-custom";
          autoconfigure = false;
          autowrapRuntimeDeps = false;
          withPython3 = false;
          withNodeJs = false;
          withPerl = false;
          withRuby = false;
          plugins = with pkgs.vimPlugins; [ customConfig catppuccin-nvim mini-icons fzf-lua haskell-tools-nvim ];
        };
    in
    {
      packages = forEachSystem (system: pkgs: rec {
        nvim = mkNeovim pkgs;
        default = inputs.nix-appimage.lib.${system}.mkAppImage { program = lib.getExe nvim; };
      });
    };
}
