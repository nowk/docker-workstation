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
		mosh \
		lsof \
		locales \
		htop \
	&& \
	locale-gen en_US.UTF-8

# Development dependencies
RUN \
	apt-get install -y \
		zsh \
		vim \
		silversearcher-ag \
		tmux \
		tig

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
	chmod +x /usr/bin/docker-compose

ARG username
ARG password

# Create a non-root user
# NOTE whois is for password encryption
#
# TODO we may need the ability to set uid and gid, depend on which linux you
# are on it may start a non-root at a different level and not 1000
RUN \
	apt-get install -y \
		sudo \
		whois \
	&& \
	PASSWORD=$(mkpasswd -m sha-512 $username) \
	&& \
	useradd \
		--create-home \
		--shell /usr/bin/zsh \
		--password $PASSWORD \
		$username \
	&& \
	echo "$username ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$username \
	&& \
    chmod 0440 /etc/sudoers.d/$username

USER $username
WORKDIR /home/$username
