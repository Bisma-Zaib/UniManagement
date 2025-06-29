#!/bin/bash

# RSA Key Manager Script
# Provides options to generate, view, copy, and delete RSA key pairs

KEY_PATH="$HOME/.ssh/id_rsa"
PUB_KEY_PATH="$HOME/.ssh/id_rsa.pub"

# Function to generate a new RSA key pair
generate_keys() {
    echo "Choose key size (2048 or 4096):"
    read -r key_size
    if [[ "$key_size" != "2048" && "$key_size" != "4096" ]]; then
        echo "Invalid key size. Using default 2048."
        key_size=2048
    fi

    if [[ -f "$KEY_PATH" || -f "$PUB_KEY_PATH" ]]; then
        echo "RSA key pair already exists. Please delete it first or backup."
        return
    fi

    ssh-keygen -t rsa -b "$key_size" -f "$KEY_PATH"
}

# Function to display the public key
display_pub_key() {
    if [[ -f "$PUB_KEY_PATH" ]]; then
        echo "----- Your Public Key -----"
        cat "$PUB_KEY_PATH"
        echo "---------------------------"
    else
        echo "Public key does not exist."
    fi
}

# Function to copy public key to a remote server
copy_pub_key() {
    if [[ ! -f "$PUB_KEY_PATH" ]]; then
        echo "Public key not found. Generate it first."
        return
    fi

    read -p "Enter remote username: " user
    read -p "Enter server IP or hostname: " host

    echo "Copying public key to $user@$host..."
    ssh-copy-id "$user@$host"

    if [[ $? -eq 0 ]]; then
        echo "Public key copied successfully!"
    else
        echo "Failed to copy public key. Check connection or credentials."
    fi
}

# Function to delete RSA key pair
delete_keys() {
    if [[ -f "$KEY_PATH" || -f "$PUB_KEY_PATH" ]]; then
        read -p "Are you sure you want to delete RSA key pair? (yes/no): " confirm
        if [[ "$confirm" == "yes" ]]; then
            rm -f "$KEY_PATH" "$PUB_KEY_PATH"
            echo "RSA key pair deleted."
        else
            echo "Deletion cancelled."
        fi
    else
        echo "No RSA key files found."
    fi
}

# Main menu loop
while true; do
    echo ""
    echo "====== RSA Key Manager ======"
    echo "1. Generate new RSA key pair"
    echo "2. Display public key"
    echo "3. Copy public key to remote server"
    echo "4. Delete existing RSA key pair"
    echo "5. Exit"
    echo "============================="
    read -p "Enter your choice [1-5]: " choice

    case $choice in
        1) generate_keys ;;
        2) display_pub_key ;;
        3) copy_pub_key ;;
        4) delete_keys ;;
        5) echo "Exiting. Goodbye!"; exit 0 ;;
        *) echo "Invalid option. Please choose between 1 and 5." ;;
    esac
done
