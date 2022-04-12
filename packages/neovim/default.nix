{ cmake, vimUtils, fetchFromGitHub, neovim, vimPlugins }:

let
  vim-cmake = vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-cmake";
    version = "1.0";
    src = fetchFromGitHub {
      owner = "vhdirk";
      repo = "vim-cmake";
      rev = "8cc735ba804354c860c8029acf3a5e1539ce711c";
      sha256 = "166ffq0plpi7wv5n7h5vgayfjm5ld5a18rbmv9gs4n7fan02yz0j";
    };
    postPatch = ''
      sed -i 's;executable("cmake");executable("${cmake}/bin/cmake");' plugin/cmake.vim
    '';
  };

in
neovim.override {
  configure = {
    customRC = builtins.readFile ./vimrc;
    packages.nixbundle = with vimPlugins; {
      start = [
        bufexplorer
        ctrlp
        emodeline
        fugitive
        haskell-vim
        neomake
        nerdtree
        surround
        vim-airline
        vim-cmake
        vim-colorschemes
        vim-nix
        vim-tmux-navigator
        vim-trailing-whitespace
      ];
      opt = [ ];
    };
  };
  vimAlias = true;
}
