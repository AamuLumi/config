cargo install --locked zellij
mv ~/.config/zellij ~/config/zellij_unsynced
ln -s "$(realpath ./files/zellij/)" ~/.config/zellij
