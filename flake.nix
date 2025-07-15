{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgsOld.url = "github:NixOS/nixpkgs/70bdadeb94ffc8806c0570eb5c2695ad29f0e421";
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
          grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [ cpp nix python ];
          customConfig = (pkgs.runCommand "custom-config" { } (''
            mkdir -p $out/{after/ftplugin,lsp,parser,queries}
            find ${./after/ftplugin} -name '*.lua' -exec install -v -m644 '{}' $out/after/ftplugin \;
            find ${./lsp} -name '*.lua' -exec install -v -m644 '{}' $out/lsp \;

            install-treesitter-grammar() {
              origGrammar="$1"
              grammarName="$2"
              mkdir -p "$out/queries/$grammarName"
              install -m644 "$origGrammar/parser" "$out/parser/$grammarName.so"
              find "${pkgs.vimPlugins.nvim-treesitter}/queries/$grammarName" -name '*.scm' -exec install -v -m644 '{}' $out/queries/$grammarName/ \;
            }
            ''
            + concatStringsSep "\n" (map (g: "install-treesitter-grammar ${g} ${grammarName g}") grammars) + "\n"
            + ''
              mkdir -p "$out/queries/haskell"
              install -m644 "${inputs.nixpkgsOld.legacyPackages.${pkgs.system}.vimPlugins.nvim-treesitter.builtGrammars.haskell}/parser" "$out/parser/haskell.so"
              find "${inputs.nixpkgsOld.legacyPackages.${pkgs.system}.vimPlugins.nvim-treesitter}/queries/haskell" -name '*.scm' -exec install -v -m644 '{}' $out/queries/haskell/ \;
            '')
          ) // { pname = "custom-config-plugin"; };
        in pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
          extraName = "-custom";
          autoconfigure = false;
          autowrapRuntimeDeps = true;
          withPython3 = false;
          withNodeJs = false;
          withPerl = false;
          withRuby = false;
          luaRcContent = readFile ./init.lua;
          plugins = with pkgs.vimPlugins; [
            customConfig catppuccin-nvim mini-icons fzf-lua haskell-tools-nvim
            (pkgs.vimUtils.buildVimPlugin {
              name = "nvim-repl";
              src = pkgs.fetchFromGitHub {
                owner = "pappasam";
                repo = "nvim-repl";
                rev = "b2dc92607fd6d1833b9c2bd916eeedcb04cad7de";
                hash = "sha256-S19JUbE9mX93lbh5Co/Vd196kk+APR6zheIaHq6WdMU=";
              };
            })
          ];
        };
    in
    {
      packages = forEachSystem (system: pkgs: rec {
        nvim = mkNeovim pkgs;
        default = inputs.nix-appimage.lib.${system}.mkAppImage { program = lib.getExe nvim; };
      });
    };
}
