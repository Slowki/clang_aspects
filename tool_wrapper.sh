#!/bin/bash -e

# Set up compile commands file then run a Clang tool

readonly TOOL="$1"
shift
readonly COMPILE_COMMANDS="$1"
shift

# Replace PWD_SIGIL with the current working directory
sed -e "s|PWD_SIGIL|$(pwd)|" "$COMPILE_COMMANDS" > compile_commands.json

exec "$TOOL" -p=. "$@"
