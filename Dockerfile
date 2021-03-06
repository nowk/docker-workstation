FROM ubuntu:bionic
MAINTAINER Yung Hwa Kwon <yung.kwon@damncarousel.com>

ENV DOCKER_WORKSTATION_VERSION 0.1.0

# TODO should this be done through a local profile when you load your shell?
ENV PATH "/src/go/bin:/usr/local/go/bin:${PATH}"
ENV LANG en_US.UTF-8

# Core dependencies
RUN \
	apt-get update \
	&& \
	apt-get install -y \
		curl \
		wget \
		make \
		build-essential \
		cmake \
		python3-dev \
		python3-pip \
		software-properties-common \
		mosh \
		lsof \
		locales \
		htop \
		unzip \
	&& \
	locale-gen en_US.UTF-8

# Development dependencies
RUN \
	add-apt-repository ppa:neovim-ppa/stable \
	&& \
	apt-get update \
	&& \
	apt-get install -y \
		zsh \
		neovim \
		vim \
		silversearcher-ag \
		tmux \
		tig \
	&& \
	pip3 install --user pynvim

# Install Docker
RUN \
	apt-get remove -y \
		docker \
		docker-engine \
		docker.io \
		containerd \
		runc \
	&& \
	apt-get install -y \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg-agent \
		software-properties-common \
	&& \
	curl -fsSL \
		https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
	&& \
	add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	   $(lsb_release -cs) \
	   stable" \
	&& \
	apt-get update \
	&& \
	apt-get install -y \
		docker-ce \
		docker-ce-cli \
		containerd.io \
	&& \
	curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" \
		-o /usr/bin/docker-compose \
	&& \
	chmod +x /usr/bin/docker-compose \
	&& \
	curl -L "https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd6" \
		-o /usr/local/bin/dumb-init \
	&& \
	chmod +x /usr/local/bin/dumb-init

ARG username
ARG password
ARG u_id
ARG g_id
ARG host_docker_group_id

# Create a non-root user
# NOTE whois is for password encryption
RUN \
	apt-get install -y \
		sudo \
		whois \
	&& \
	PASSWORD=$(mkpasswd -m sha-512 $username) \
	&& \
	groupadd hostdocker -f -g $host_docker_group_id \
	&& \
	groupadd $username -f -g $g_id \
	&& \
	useradd \
		--create-home \
		-u $u_id \
		-g $g_id \
		--shell /usr/bin/zsh \
		--password $PASSWORD \
		$username \
	&& \
	usermod -aG hostdocker $username \
	&& \
	echo "$username ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$username \
	&& \
    chmod 0440 /etc/sudoers.d/$username

USER $username
WORKDIR /home/$username
