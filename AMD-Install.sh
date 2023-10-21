#!/bin/bash

# Prompt the user for their choice
PS3="Select an option: "
options=("Select This First" "Select This After Reboot" "Quit")
select choice in "${options[@]}"; do
    case $choice in
        "Select This First")
            # Step 1: Prompt the user for the path to the AMD Drivers .deb file
            read -p "Download the AMD Drivers .deb file from https://www.amd.com/en/support/linux-drivers and provide the full path to the AMD driver .deb file: " deb_file_path

            # Check if the provided .deb file exists
            if [ -f "$deb_file_path" ]; then
                # Install AMD Drivers from the provided .deb file
                sudo apt-get install -y "$deb_file_path"
                echo "AMD Drivers installed successfully."
            else
                echo "The provided .deb file does not exist. Please make sure to specify the correct path."
                exit 1
            fi

            # Step 2: Give proper permissions
            sudo usermod -a -G render $USER
            sudo usermod -a -G video $USER

            # Step 3: Install ROCm
            sudo amdgpu-install -y --usecase=rocm --no-dkms

            # Step 4: Install related stuff
            sudo apt-get install -y git python3.10-venv python3-pip
            sudo apt-get install -y libstdc++-12-dev

            # Step 5: Install automatic1111
            git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui
            cd stable-diffusion-webui
            sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 5
            python -m pip install -y --upgrade pip wheel

            # Step 6: Reboot the system with a 1-minute delay
            echo "The system will reboot in 1 minute. To cancel, press Ctrl+C."
            sleep 60
            sudo reboot
            ;;

        "Select This After Reboot")
            # Set HSA_OVERRIDE_GFX_VERSION
            export HSA_OVERRIDE_GFX_VERSION=10.3.0

            # Create a virtual environment
            python -m venv venv
            source venv/bin/activate

            # Install PyTorch and launch.py using the provided URL
            pip3 install -y --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm5.5
            python launch.py
            ;;
        "Quit")
            echo "Quitting."
            exit 0
            ;;
        *)
            echo "Invalid option. Please select a valid option."
            ;;
    esac
done

