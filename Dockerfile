FROM ubuntu:latest

# Bootstrap prerequisites:
# - git: for cloning/volume setup
# - curl: needed immediately by install.sh (oh-my-zsh install)
# - zsh: required by the #!/usr/bin/env zsh shebang
# - sudo: install scripts use sudo apt-get, sudo tar, etc.
RUN apt-get update \
    && apt-get install -y --no-install-recommends git curl zsh sudo ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user with passwordless sudo
RUN useradd -m -s /bin/zsh user \
    && echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER user
WORKDIR /home/user/dotfiles
