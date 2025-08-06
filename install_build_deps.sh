#!/bin/bash -ex

# Check for permission to run apt-get update/install
if [ "$(id -u)" -eq 0 ]; then
    # Running as root, OK
    :
elif command -v sudo >/dev/null 2>&1; then
    if ! sudo -n true 2>/dev/null; then
        echo "Error: This script requires permission to run 'apt-get update/install'. Please run as root or ensure you have passwordless sudo access." >&2
        exit 1
    fi
else
    echo "Error: This script requires root or sudo privileges to run 'apt-get update/install'." >&2
    exit 1
fi

# install gpg
apt-get update -y && sudo apt install -y gpg
# Add intel-sgx package repository, key is download from https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key
cat intel-sgx-deb.key | gpg --dearmor | sudo tee /usr/share/keyrings/intel-sgx-deb.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/intel-sgx-deb.gpg] https://download.01.org/intel-sgx/sgx_repo/ubuntu noble main" | sudo tee /etc/apt/sources.list.d/intel-sgx-deb.list > /dev/null
# Install dependencies for build
apt-get update -y
apt-get install -y protobuf-compiler libsgx-dcap-ql-dev clang-18
