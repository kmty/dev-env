FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

ENV DEBCONF_NOWARNINGS=yes

WORKDIR /root

# cange apt-get servers
RUN sed -i.bak -r 's!http://(security|us.archive).ubuntu.com/ubuntu!http://ftp.riken.jp/Linux/ubuntu!' /etc/apt/sources.list

# Install basic tool
RUN apt-get update -qq && apt-get full-upgrade -y \
    && apt-get install -y --no-install-recommends \
    build-essential \
    libbz2-dev \
    libdb-dev \
    libreadline-dev \
    libffi-dev \
    libgdbm-dev \
    liblzma-dev \
    libncursesw5-dev \
    libsqlite3-dev \
    libssl-dev \
    zlib1g-dev \
    uuid-dev \
    language-pack-ja-base \
    language-pack-ja \
    bash-completion \
    curl \
    git \
    jq \
    iproute2 \
    parted \
    ssh \
    tzdata \
    unzip \
    vim \
    wget \
    zip

# python install
RUN wget --no-check-certificate https://www.python.org/ftp/python/3.12.7/Python-3.12.7.tgz \
    && tar -xzf Python-3.12.7.tgz \
    && cd Python-3.12.7 \
    && ./configure --enable-optimizations \
    && make \
    && make install

# nodejs/npm install
RUN apt-get update -qq && apt-get full-upgrade -y \
    && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    && npm install n -g \
    && n 22.10.0 \
    && apt-get purge -y \
    nodejs \
    npm

# rust install
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# remove dependency packages
RUN apt-get autoremove -y \
    && rm Python-3.12.7.tgz \
    && rm -rf Python-3.12.7

# dev
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws \
    && npm install yarn -g \
    && npm install npm-check-updates -g \
    && pip3 install git-remote-codecommit \
    && pip3 install cfn-lint \
    && pip3 install -U black \
    && pip3 install -U flake8 \
    && pip3 install -U mypy

# setup others
RUN echo 'alias python="python3"' >> ~/.bashrc \
    && echo 'alias pip="pip3"' >> ~/.bashrc \
    && echo "source /usr/share/bash-completion/completions/git" >> ~/.bashrc \
    && echo "complete -C 'usr/local/bin/aws_completer' aws" >> ~/.bashrc \
    && echo "export LANG=ja_JP.UTF-8" >> ~/.bashrc \
    && echo "export PS1='[\[\033[32m\]\u:\[\033[1;34m\]\W\[\033[00m\]]\$ '" >> ~/.bashrc \
    && /bin/bash -c "source /root/.bashrc"

CMD ["/bin/bash"]
