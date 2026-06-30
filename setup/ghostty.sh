brew install --cask ghostty
mv ~/Library/Application\ Support/com.mitchellh.ghostty ~/Library/Application\ Support/com.mitchellh.ghostty_unsynced
ln -s "$(realpath ../files/ghostty)" ~/Library/Application\ Support/com.mitchellh.ghostty
