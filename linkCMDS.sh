#!/usr/bin/env bash

cd "$HOME"

# List of symbolic links to remove
declare -a files_to_remove=(
  "$HOME/.config/starship.toml"
  "$HOME/.config/alacritty/alacritty.toml"
  "$HOME/.zshrc"
  "$HOME/.gitconfig"
  "$HOME/Library/Application Support/espanso/match/addSnpt.yml"
  "$HOME/.config/nvim/init.vim"
  "$HOME/.config/zellij"
)

# Display the list of files to be removed
echo "The following symbolic links will be removed:"
for file in "${files_to_remove[@]}"; do
  echo "  ${file}"
done
echo ""

# Ask the user for confirmation
read -p "Do you want to remove these symbolic links? (y/Y/Enter=yes, n/N=no): " response

# Process based on the response
case "$response" in
  [yY]|"") # y, Y, or Enter
    echo "Starting removal..."
    rm -f "$HOME/.config/starship.toml"
    rm -f "$HOME/.config/alacritty/alacritty.toml"
    rm -f "$HOME/.zshrc"
    rm -f "$HOME/.gitconfig"
    rm -f "$HOME/Library/Application Support/espanso/match/addSnpt.yml"
    rm -f "$HOME/.config/nvim/init.vim"
    rm -f "$HOME/.config/zellij/*"
    echo ""
    echo "Creating espanso directory if it doesn't exist..."
    mkdir -p "$HOME/Library/Application Support/espanso/match/"
    echo "Creating symbolic links..."


   echo -e " ln -s "$HOME/dotfilem/starship.toml" "$HOME/.config/starship.toml" "
   echo -e " ln -s "$HOME/dotfilem/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml" "
   echo -e " ln -s "$HOME/dotfilem/.zshrc" "$HOME/.zshrc" "
   echo -e " ln -s "$HOME/dotfilem/.gitconfig" "$HOME/.gitconfig" "
   echo -e " ln -s "$HOME/dotfilem/addSnpt.yml" "$HOME/Library/Application Support/espanso/match/addSnpt.yml" "
   echo -e " ln -s "$HOME/dotfilem/init.vim" "$HOME/.config/init.vim" "
   echo -e " ln -s "$HOME/dotfilem/zj-dev.kdl" "$HOME/.config/zellij/zj-dev.kdl" "
   echo -e " ln -s "$HOME/dotfilem/zj-ssh.kdl" "$HOME/.config/zellij/zj-ssh.kdl" "
   echo -e " ln -s "$HOME/dotfilem/zj-config.kdl" "$HOME/.config/zellij/zj-config.kdl" "

    ln -s "$HOME/dotfilem/starship.toml" "$HOME/.config/starship.toml"
    ln -s "$HOME/dotfilem/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
    ln -s "$HOME/dotfilem/.zshrc" "$HOME/.zshrc"
    ln -s "$HOME/dotfilem/.gitconfig" "$HOME/.gitconfig"
    ln -s "$HOME/dotfilem/addSnpt.yml" "$HOME/Library/Application Support/espanso/match/addSnpt.yml"
    ln -s /Users/roche/dotfilem/init.vim "$HOME/.config/nvim/init.vim"
    ln -s "$HOME/dotfilem/zj-dev.kdl" "$HOME/.config/zellij/zj-dev.kdl"
    ln -s "$HOME/dotfilem/zj-ssh.kdl" "$HOME/.config/zellij/zj-ssh.kdl"
    ln -s "$HOME/dotfilem/zj-config.kdl" "$HOME/.config/zellij/zj-config.kdl"

    echo "Symbolic links created successfully."
    ;;
  [nN]) # n or N
    echo "Removal cancelled."
    exit 0
    ;;
  *) # Other input
    echo "Invalid input. Removal cancelled."
    exit 1
    ;;
  [nN]) # n or N
    echo "Removal cancelled."
    exit 0
    ;;
  *) # Other input
    echo "Invalid input. Removal cancelled."
    exit 1
    ;;
esac


