#!/bin/bash

# Define the download URL
URL="https://pixeldrain.com/api/file/Wdo8q5q6?download"

# Define the temporary directory
TEMP_DIR="/tmp/my_temp_dir"

# Create the temporary directory
mkdir -p "$TEMP_DIR"

# Download the file
wget --no-check-certificate --output-document="$TEMP_DIR/myfile.zip" "$URL"

# Check if the download was successful
if [ $? -eq 0 ]; then
    # Extract the contents
    unzip "$TEMP_DIR/myfile.zip" -d "$TEMP_DIR"

    # Get the current username
    USERNAME="$(whoami)"

    # Copy the contents to the ~/.config folder in the user's home directory
    cp -r "$TEMP_DIR" "$HOME/.config/"

    # Clean up the temporary directory
    rm -r "$TEMP_DIR"

    echo "Files copied to ~/.config folder."
else
    echo "Download failed. Please check the URL or your network connection."
fi

# Install jq if not already installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing it now..."
    sudo apt-get install -y jq
fi

# Fetch the latest release information from the GitHub API
API_URL="https://api.github.com/repos/Alex313031/Thorium/releases/latest"
DOWNLOAD_URL=$(curl -s "$API_URL" | jq -r '.assets[] | select(.name | endswith(".deb")).browser_download_url')

if [ -n "$DOWNLOAD_URL" ]; then
    # Download the latest .deb file
    wget -O latest.deb "$DOWNLOAD_URL"
    echo "Downloaded the latest .deb file."

    # Install the .deb file
    sudo dpkg -i latest.deb
    sudo apt-get install -f -y  # Install dependencies (if any)
    
    # Cleanup: Remove the .deb file
    rm latest.deb
    echo "Installation of Thorium complete, and the .deb file has been removed."

    # Configure Spotify repository and install the Spotify client
    curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt-get update -y
    sudo apt-get install -y spotify-client
    echo "Installation of Spotify complete."
else
    echo "Failed to fetch the download URL from GitHub."
fi

# Install additional packages
#sudo apt-get install -y 
