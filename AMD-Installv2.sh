#!/bin/bash

# Specify the log file path
log_file="install_log.txt"

# Function to log to both stdout and a log file
log() {
    local message="$1"
    echo "$message"
    echo "$message" >> "$log_file"
}

# Function to install AMD Drivers
install_amd_drivers() {
    log "Step 1: Installing AMD Drivers"
    read -p "Download the AMD Drivers .deb file from https://www.amd.com/en/support/linux-drivers and provide the full path to the AMD driver .deb file: " deb_file_path

    # Check if the provided .deb file exists
    if [ -f "$deb_file_path" ]; then
        # Install AMD Drivers from the provided .deb file
        sudo apt-get install -y "$deb_file_path"
        log "AMD Drivers installed successfully."
    else
        log "The provided .deb file does not exist. Please make sure to specify the correct path."
        retry_section "install_amd_drivers"
    fi
}

# Function to give proper permissions
give_permissions() {
    log "Step 2: Giving proper permissions"
    sudo usermod -a -G render $USER
    sudo usermod -a -G video $USER
}

# Function to install ROCm
install_rocm() {
    log "Step 3: Installing ROCm"
    sudo amdgpu-install -y --usecase=rocm --no-dkms
}

# Function to install related stuff
install_related_stuff() {
    log "Step 4: Installing related stuff"
    sudo apt-get install -y git python3.10-venv python3-pip
    sudo apt-get install -y libstdc++-12-dev
}

# Function to install automatic1111
install_automatic1111() {
    log "Step 5: Installing automatic1111"
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui
    cd stable-diffusion-webui
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 5
    python -m pip install -y --upgrade pip wheel
}

# Function to retry a specific section
retry_section() {
    local section_name="$1"
    read -p "Retry $section_name (y/n)? " retry_choice
    if [ "$retry_choice" = "y" ]; then
        log "Retrying $section_name..."
        "$section_name"
    else
        log "Skipping $section_name."
    fi
}

# Enable error checking
set -e

# Create or truncate the log file
> "$log_file"

# Main menu
PS3="Select an option: "
options=("Select This First" "Select This After Reboot" "Quit")
select choice in "${options[@]}"; do
    case $choice in
        "Select This First")
            install_amd_drivers
            give_permissions
            install_rocm
            install_related_stuff
            install_automatic1111
            ;;
        "Select This After Reboot")
            log "Step 6: Setting HSA_OVERRIDE_GFX_VERSION"
            export HSA_OVERRIDE_GFX_VERSION=10.3.0

            log "Step 7: Creating a virtual environment"
            python -m venv venv
            source venv/bin/activate

            log "Step 8: Installing PyTorch and launch.py"
            pip3 install -y --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm5.5
            python launch.py
            ;;
        "Quit")
            log "Quitting."
            exit 0
            ;;
        *)
            log "Invalid option. Please select a valid option."
            ;;
    esac
done
