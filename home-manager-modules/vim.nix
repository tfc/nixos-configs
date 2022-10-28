{ pkgs, lib, agenix, hostName, ... }:

let
  vim-cmake = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-cmake";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "vhdirk";
      repo = "vim-cmake";
      rev = "d4a6d1836987b933b064ba8ce5f3f0040a976880";
      sha256 = "sha256-/JcO2gCJg99di33d0ANnL33F3yUeeBg4eBVA21iZCvY=";
    };
    postPatch = ''
      sed -i 's;executable("cmake");executable("${pkgs.cmake}/bin/cmake");' plugin/cmake.vim
    '';
  };
in
{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = builtins.readFile ./vimrc;
    plugins = with pkgs.vimPlugins; [
      bufexplorer
      ctrlp
      emodeline
      fugitive
      haskell-vim
      neomake
      nerdtree
      purescript-vim
      surround
      vim-airline
      vim-cmake
      vim-colorschemes
      vim-nix
      vim-tmux-navigator
      vim-trailing-whitespace
    ];
  };

  home.packages = with pkgs; [
    rnix-lsp
  ];
}
