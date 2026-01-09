FROM debian

ARG GITHUB_USER=bestruirui
ENV TZ=Asia/Shanghai

RUN apt update && \
    apt install -y curl sudo nano ca-certificates zsh git openssh-server gcc g++ gdb docker.io tzdata && \
    rm -rf /var/lib/apt/lists/* && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    mkdir -p /run/sshd && \
    ssh-keygen -A && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config && \
    useradd -m -s /bin/zsh dev && echo 'dev:dev' | chpasswd && \
    usermod -aG sudo,docker dev && \
    echo 'dev ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER dev
WORKDIR /home/dev

RUN mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
    curl -fsSL https://github.com/${GITHUB_USER}.keys -o ~/.ssh/authorized_keys && \
    chmod 600 ~/.ssh/authorized_keys && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --skip-chsh && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/' ~/.zshrc && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bestrui"/' ~/.zshrc && \
    curl https://mise.run | sh && \
    echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc && \
    ~/.local/bin/mise use --global node go python && \
    curl -fsSL https://github.com/sigoden/dufs/releases/download/v0.45.0/dufs-v0.45.0-x86_64-unknown-linux-musl.tar.gz | tar -xzf - -C ~/.local/bin dufs

COPY --chown=dev:dev bestrui.zsh-theme /home/dev/.oh-my-zsh/custom/themes/

EXPOSE 2222
CMD ["sudo", "/usr/sbin/sshd", "-D"]