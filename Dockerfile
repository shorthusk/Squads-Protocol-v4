FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
  curl \
  git \
  build-essential \
  pkg-config \
  libssl-dev \
  libudev-dev \
  zsh \
  && rm -rf /var/lib/apt/lists/*

# Create a non-root user with UID/GID 1000 to match host's ubuntu user
RUN useradd -u 1000 -ms /bin/zsh ubuntu

# Switch to ubuntu user
USER ubuntu

# Set HOME explicitly for clarity
ENV HOME=/home/ubuntu

# Install Rust for ubuntu user
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain 1.78.0
ENV PATH="/home/ubuntu/.cargo/bin:${PATH}"

# Install Node.js (requires root, so install before switching user)
USER root
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs
RUN npm install -g yarn @coral-xyz/anchor-cli@0.29.0
USER ubuntu

# Install Solana CLI v1.18.16 for ubuntu user
RUN sh -c "$(curl -sSfL https://release.anza.xyz/v1.18.16/install)" && \
    /home/ubuntu/.local/share/solana/install/active_release/bin/solana --version
ENV PATH="/home/ubuntu/.local/share/solana/install/active_release/bin:${PATH}"

# Install Oh My Zsh for ubuntu user
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Configure Oh My Zsh for ubuntu user
RUN echo 'export ZSH="/home/ubuntu/.oh-my-zsh"' >> /home/ubuntu/.zshrc && \
    echo 'ZSH_THEME="robbyrussell"' >> /home/ubuntu/.zshrc && \
    echo 'plugins=(git rust node yarn)' >> /home/ubuntu/.zshrc && \
    echo 'source $ZSH/oh-my-zsh.sh' >> /home/ubuntu/.zshrc && \
    echo 'export PATH="/home/ubuntu/.cargo/bin:/home/ubuntu/.local/share/solana/install/active_release/bin:$PATH"' >> /home/ubuntu/.zshrc

# Set working directory
WORKDIR /app

# Default command
CMD ["/bin/zsh"]