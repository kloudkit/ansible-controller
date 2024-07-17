#!/bin/bash

while IFS= read -r line; do
  read -r name url <<< "${line}"

  curl -fsSL "https://${url}" \
    | gpg --dearmor -o "/etc/apt/keyrings/${name}.gpg"
done < "${1}"
