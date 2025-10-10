#!/bin/bash

cd "$HOME"

# List of symbolic links to remove
declare -a files_to_remove=(
  "$HOME/.config/starship.toml"
  "$HOME/.zshrc"
  "$HOME/.config/nvim/init.vim"
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
    rm -f "$HOME/.zshrc"
    rm -f "$HOME/.config/nvim/init.vim"
    echo ""

    echo "Creating symbolic links..."


   echo -e " ln -s "$HOME/dotfileu/starship.toml" "$HOME/.config/starship.toml" "
   echo -e " ln -s "$HOME/dotfileu/.zshrc" "$HOME/.zshrc" "
   echo -e " ln -s "$HOME/dotfileu/init.vim" "$HOME/.config/nvim/init.vim" "

   mkdir -p ~/.config/nvim
   ln -s "$HOME/dotfileu/starship.toml" "$HOME/.config/starship.toml"
   ln -s "$HOME/dotfileu/.zshrc" "$HOME/.zshrc"
   ln -s "$HOME/dotfileu/init.vim" "$HOME/.config/nvim/init.vim"

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


