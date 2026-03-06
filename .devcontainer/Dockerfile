# Use lightweight Python base image
FROM python:3.12-bookworm

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
       sudo zsh git curl groff \
       apt-transport-https ca-certificates gnupg software-properties-common lsb-release \
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

RUN ARCH=$(uname -m) \
    && case "${ARCH}" in \
        x86_64) AWS_ARCH="x86_64"; TRIVY_ARCH="64bit"; ARCH="amd64";; \
        aarch64) AWS_ARCH="aarch64"; TRIVY_ARCH="ARM64"; ARCH="arm64";; \
        *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;; \
    esac \
    && curl -fsSL "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl" -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf awscliv2.zip /tmp/aws \
    && curl -L "$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep -o -E -m 1 "https://.+?k9s_Linux_${ARCH}.tar.gz")" > k9s.tar.gz && tar -xzf k9s.tar.gz k9s && rm k9s.tar.gz && mv k9s /usr/bin/ \
    && curl -L "$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep -o -E -i -m 1 "https://.+?/trivy_.+?_Linux-${TRIVY_ARCH}.tar.gz")" > trivy.tar.gz && tar -xzf trivy.tar.gz trivy && rm trivy.tar.gz &&  mv trivy /usr/bin \
    && curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E -m 1 "https://.+?-linux-${ARCH}.tar.gz")" > terraform-docs.tgz && tar -xzf terraform-docs.tgz terraform-docs && rm terraform-docs.tgz && chmod +x terraform-docs && mv terraform-docs /usr/bin/ \
    && curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E -m 1 "https://.+?_linux_${ARCH}.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && mv tflint /usr/bin/ \
    && curl -L "$(curl -s https://api.github.com/repos/infracost/infracost/releases/latest | grep -o -E -m 1 "https://.+?-linux-${ARCH}.tar.gz")" > infracost.tgz && tar -xzf infracost.tgz && rm infracost.tgz && mv infracost-linux-${ARCH} /usr/bin/infracost \
    && curl -L "$(curl -s https://api.github.com/repos/minamijoyo/tfupdate/releases/latest | grep -o -E -m 1 "https://.+?_linux_${ARCH}.tar.gz")" > tfupdate.tar.gz && tar -xzf tfupdate.tar.gz tfupdate && rm tfupdate.tar.gz && mv tfupdate /usr/bin/

# Switch to non-root user and set working directory
USER ${USERNAME}

# User-level setup: Zsh configuration
RUN export RUNZSH=no \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="eastwood"/' ${HOME}/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git aliases alias-finder zsh-syntax-highlighting)/' ${HOME}/.zshrc \
    && sed -i "/^source \$ZSH\\/oh-my-zsh.sh/i zstyle ':omz:plugins:alias-finder' autoload yes\\nzstyle ':omz:plugins:alias-finder' longer yes\\nzstyle ':omz:plugins:alias-finder' exact yes\\nzstyle ':omz:plugins:alias-finder' cheaper yes\\n" ${HOME}/.zshrc \
    && pip install pre-commit checkov
