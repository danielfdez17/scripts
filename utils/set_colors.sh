#!/bin/bash

cd ~/.local/bin || { echo "Failed to enter ~/.local/bin directory"; exit 1; }

if [ -f "print_error" ]; then
    echo "The file 'print_error' already exists."
else
    echo "Creating 'print_error' file..."
    cat << 'EOF' > print_error
#!/bin/bash

echo -e "\033[0;31m✗ $1 \033[0m"

EOF
fi

if [ -f "print_info" ]; then
    echo "The file 'print_info' already exists."
else
    echo "Creating 'print_info' file..."
    cat << 'EOF' > print_info
#!/bin/bash

echo -e "\033[0;34mℹ  $1 \033[0m"

EOF
fi

if [ -f "print_ok" ]; then
    echo "The file 'print_ok' already exists."
else
    echo "Creating 'print_ok' file..."
    cat << 'EOF' > print_ok
#!/bin/bash

echo -e "\033[0;32m🗸 $1 \033[0m"

EOF
fi


if [ -f "print_warning" ]; then
    echo "The file 'print_warning' already exists."
else
    echo "Creating 'print_warning' file..."
    cat << 'EOF' > print_warning
#!/bin/bash

echo -e "\033[1;33m⚠ $1 \033[0m"

EOF
fi


