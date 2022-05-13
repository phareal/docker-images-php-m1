# define env variable
ARG INSTALL_CRON=1
ARG INSTALL_COMPOSER=1
ARG PHP_VERSION
ARG GLOBAL_VERSION

FROM arm64v8/ubuntu:20.04


LABEL authors="Justin Essosolam POTCHONA <potchjust@gmail.com>"

# Fixes some weird terminal issues such as broken clear / CTRL+L
#ENV TERM=linux

# Ensure apt doesn't ask questions when installing stuff
ENV DEBIAN_FRONTEND=noninteractive

ARG PHP_VERSION
ENV PHP_VERSION=8.1

# Install php an other packages
# |--------------------------------------------------------------------------
# | Main PHP extensions
# |--------------------------------------------------------------------------
# |
# | Installs the main PHP extensions
# |

# Install php an other packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends gnupg \
    && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main" > /etc/apt/sources.list.d/ondrej-php.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        git \
        nano \
        sudo \
        iproute2 \
        openssh-client \
        procps \
        unzip \
        ca-certificates \
        curl \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-opcache \
        php${PHP_VERSION}-readline \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-zip \
   && if [[ "${PHP_VERSION}" =~ ^7 ]]; then apt-get install -y --no-install-recommends php${PHP_VERSION}-json; fi \
      && if [[ "${PHP_VERSION}" =~ ^8 ]]; then apt-get install -y --no-install-recommends php${PHP_VERSION}-json; fi \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

 # add user to the docker file with sudo right ( It will be docker in our use case \

RUN useradd -ms /bin/bash docker && adduser docker sudo
# Users in the sudoers group can sudo as root without password.
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#install composer on the computer

#ENV COMPOSER_ALLOW_SUPERUSER 1

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer &&\
    chmod +x /usr/local/bin/composer
