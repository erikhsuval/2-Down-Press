#!/bin/bash

# Exit if SwiftLint is not installed
if ! which swiftlint >/dev/null; then
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    exit 0
fi

# Get the project root directory
PROJECT_ROOT="$SRCROOT"
cd "$PROJECT_ROOT" || exit 1

# Run SwiftLint with explicit paths
swiftlint --config "$PROJECT_ROOT/.swiftlint.yml" "$PROJECT_ROOT" 