#!/bin/bash

IN=$(getent group | awk '/docker_group/' | cut -d ":" -f 4)

IFS=',' read -r -a array <<< "$IN"
for name in "${array[@]}"; do
        echo "$name"
        usermod -aG docker $name
done