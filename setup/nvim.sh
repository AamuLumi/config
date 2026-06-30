brew install neovim
mv ~/.config/nvim ~/config/nvim_unsynced
ln -s "$(realpath ./files/nvim/)" ~/.config/nvim
