#!/usr/bin/env sh

# Autoload Ruby and Node correct versions after changing the project folder

# Append to ~/.bashrc
function cd() {
  # Call the built-in cd command with the provided arguments
  builtin cd "$@" || return

  # Function to set version for given language
  set_version() {
    local lang="$1"
    local lvm="$2"
    local version_file="$3"

    if [ -f "$version_file" ]; then
      local version=$(sed -n '1p' "$version_file")

      if [ -n "$version" ]; then
        $lvm use "$version" >/dev/null 2>&1

        if [ $? -eq 0 ]; then
          echo "$lang version set to $version"
        else
          echo "Error: Failed to set $lang version to $version"
        fi
      fi
    fi
  }

  #            Lang   Tool   File
  set_version "Ruby" "rvm" ".ruby-version"
  set_version "Node" "nvm" ".nvmrc"
}

# and reload cmd:
# source ~/.bashrc
