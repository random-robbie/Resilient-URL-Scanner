#!/bin/bash

echo "=== Resilient URL Scanner Setup ==="
echo "Setting up your server for large-scale URL scanning..."
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  This script should be run as root for system packages installation"
    echo "Please run: sudo $0"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo "❌ Cannot detect OS version"
    exit 1
fi

echo "🖥️  Detected OS: $OS $VER"
echo

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

if [ $? -ne 0 ]; then
    echo "❌ Failed to update system packages"
    exit 1
fi

# Install dependencies
echo "🔧 Installing dependencies..."
apt install -y golang-go screen htop wget curl git

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Check Go installation
echo "🔍 Checking Go installation..."
go version

if [ $? -ne 0 ]; then
    echo "❌ Go installation failed"
    exit 1
fi

# Install httpx
echo "🚀 Installing httpx..."
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

if [ $? -ne 0 ]; then
    echo "❌ Failed to install httpx"
    exit 1
fi

# Setup PATH
echo "🔧 Setting up Go PATH..."
export PATH=$PATH:/root/go/bin

# Add to bashrc if not already there
if ! grep -q "export PATH=\$PATH:/root/go/bin" /root/.bashrc; then
    echo 'export PATH=$PATH:/root/go/bin' >> /root/.bashrc
    echo "✅ Added Go PATH to .bashrc"
fi

# Verify httpx installation
echo "🧪 Testing httpx installation..."
/root/go/bin/httpx -version

if [ $? -ne 0 ]; then
    echo "❌ httpx installation verification failed"
    echo "📍 Try running: export PATH=\$PATH:/root/go/bin"
    exit 1
fi

# Create directories
echo "📁 Creating project directories..."
mkdir -p completed results logs

# Make scripts executable
echo "🔧 Setting script permissions..."
chmod +x scan.sh monitor.sh status.sh setup.sh

# Create sample URLs file if it doesn't exist
if [ ! -f urls.txt ]; then
    echo "📝 Creating sample urls.txt..."
    cat > urls.txt << 'EOF'
# Place your URLs here (one per line)
# Examples:
# example.com
# test.com
# google.com
EOF
    echo "✅ Created sample urls.txt - edit this file with your target URLs"
fi

echo
echo "🎉 Setup completed successfully!"
echo
echo "📋 Next steps:"
echo "1. Edit urls.txt with your target URLs"
echo "2. Run: screen -S scanner"
echo "3. Run: ./scan.sh"
echo "4. Detach: Ctrl+A then D"
echo "5. Monitor: ./monitor.sh"
echo
echo "📚 For more information, see the README.md"
echo "🔗 Digital Ocean hosting: https://m.do.co/c/e22bbff5f6f1"
echo
echo "Happy scanning! 🎯"