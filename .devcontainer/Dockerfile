# Use lightweight Python base image
FROM python:3.13-bookworm

# Define non-root user
ARG USERNAME
ENV USERNAME=${USERNAME:-"vscode"}
RUN echo "Using USERNAME: ${USERNAME}"

ENV HOME=/home/${USERNAME}
ENV PATH=${HOME}/.local/bin:$PATH \
    ZSH_CUSTOM=${HOME}/.oh-my-zsh/custom


# Install system deps and create user
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       sudo zsh git curl groff\
       apt-transport-https ca-certificates gnupg software-properties-common lsb-release \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -ms /bin/zsh ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && pip install --upgrade pip \
    && ARCH=$(uname -m) \
    && case "${ARCH}" in \
        x86_64) JQ_ARCH="jq-linux64"; YQ_ARCH="yq_linux_amd64"; ;; \
        aarch64) JQ_ARCH="jq-linuxarm64"; YQ_ARCH="yq_linux_arm64"; ;; \
        *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;; \
    esac \
    && curl -L -o /usr/local/bin/jq "https://github.com/stedolan/jq/releases/latest/download/${JQ_ARCH}" \
    && chmod +x /usr/local/bin/jq \
    && curl -L -o /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/latest/download/${YQ_ARCH}" \
    && chmod +x /usr/local/bin/yq \
    \
    # Add HashiCorp Terraform repo
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && echo "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com \
            $(lsb_release -cs) main" \
       > /etc/apt/sources.list.d/hashicorp.list \
    \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       terraform \
    && rm -rf /var/lib/apt/lists/*

# Switch to non-root user and set working directory
USER ${USERNAME}

# User-level setup: Zsh configuration
RUN export RUNZSH=no \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="eastwood"/' ${HOME}/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git aliases alias-finder zsh-syntax-highlighting)/' ${HOME}/.zshrc \
    && sed -i "/^source \$ZSH\\/oh-my-zsh.sh/i zstyle ':omz:plugins:alias-finder' autoload yes\\nzstyle ':omz:plugins:alias-finder' longer yes\\nzstyle ':omz:plugins:alias-finder' exact yes\\nzstyle ':omz:plugins:alias-finder' cheaper yes\\n" ${HOME}/.zshrc
