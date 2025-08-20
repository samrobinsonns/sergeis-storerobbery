#!/bin/bash

echo "=========================================="
echo "Store Robbery Script Installation Script"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "fxmanifest.lua" ]; then
    echo "❌ Error: Please run this script from the resource directory"
    echo "   Make sure you're in the folder containing fxmanifest.lua"
    exit 1
fi

echo "✅ Resource directory found"
echo ""

# Check dependencies
echo "Checking dependencies..."

# Check if ox_lib exists
if [ -d "../ox_lib" ]; then
    echo "✅ ox_lib found"
else
    echo "❌ ox_lib not found in parent directory"
    echo "   Please install ox_lib: https://github.com/overextended/ox_lib"
fi

# Check if qb-core exists
if [ -d "../qb-core" ]; then
    echo "✅ qb-core found"
else
    echo "❌ qb-core not found in parent directory"
    echo "   Please install qb-core: https://github.com/qbcore-framework/qb-core"
fi

# Check if oxmysql exists
if [ -d "../oxmysql" ]; then
    echo "✅ oxmysql found"
else
    echo "⚠️  oxmysql not found (optional dependency)"
    echo "   Install for database features: https://github.com/overextended/oxmysql"
fi

echo ""

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p html/sounds
echo "✅ Directories created"

# Set permissions
echo "Setting file permissions..."
chmod +x *.lua
chmod +x client/*.lua
chmod +x server/*.lua
echo "✅ Permissions set"

# Check for required files
echo ""
echo "Checking required files..."

required_files=(
    "fxmanifest.lua"
    "config.lua"
    "client/main.lua"
    "client/cash_register.lua"
    "client/safe_robbery.lua"
    "client/minigame.lua"
    "server/main.lua"
    "server/cash_register.lua"
    "server/safe_robbery.lua"
    "html/index.html"
    "html/style.css"
    "html/script.js"
)

missing_files=()

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (missing)"
        missing_files+=("$file")
    fi
done

echo ""

if [ ${#missing_files[@]} -eq 0 ]; then
    echo "🎉 All files are present!"
    echo ""
    echo "Installation completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Add 'ensure sergeis-storerobbery' to your server.cfg"
    echo "2. Configure the script in config.lua"
    echo "3. Restart your server"
    echo ""
    echo "For help, check the README.md file"
else
    echo "❌ Some files are missing:"
    for file in "${missing_files[@]}"; do
        echo "   - $file"
    done
    echo ""
    echo "Please ensure all files are present before installation"
    exit 1
fi

echo "=========================================="
echo "Installation script completed!"
echo "=========================================="
