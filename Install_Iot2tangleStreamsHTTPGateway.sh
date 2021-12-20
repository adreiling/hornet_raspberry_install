#!/bin/bash
#
echo "=================================================================="
echo "Installing RUST"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "=================================================================="
echo "Installing Cargo"
apt-get install -y cargo

echo "=================================================================="
echo "Installing build dependencies"
apt -y update
apt install build-essential pkg-config libssl-dev

echo "=================================================================="
echo "Downloading the Repository iot2tangle Streams-HTTP-Gateway"
git clone https://github.com/iot2tangle/Streams-http-gateway.git

echo "=================================================================="
echo "Run the streams-gateway"
cargo run --release
