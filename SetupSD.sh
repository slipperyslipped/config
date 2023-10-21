#!/bin/bash

#install wget

sudo apt-get install wget -y

# Set the URLs for the LoRA and Stable-diffusion models
lora_urls=("https://civitai.com/api/download/models/188803/" "https://civitai.com/api/download/models/188385")
sd_urls=("https://civitai.com/api/download/models/188803/" "https://civitai.com/api/download/models/188385" "https://civitai.com/api/download/models/146718")

# Set the destination directories
lora_dir="$HOME/Desktop/stable-diffusion-webui/models/LoRA"
sd_dir="$HOME/Desktop/stable-diffusion-webui/models/Stable-diffusion"

# Create the directories if they don't exist
mkdir -p "$lora_dir"
mkdir -p "$sd_dir"

# Download and copy the LoRA models
for url in "${lora_urls[@]}"; do
    filename=$(basename "$url")
    wget -P "$lora_dir" "$url" -O "$filename"
done

# Download and copy the Stable-diffusion models
for url in "${sd_urls[@]}"; do
    filename=$(basename "$url")
    wget -P "$sd_dir" "$url" -O "$filename"
done

echo "Download and copy complete."
