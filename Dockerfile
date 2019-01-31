FROM debian:stretch-slim

LABEL maintainer="normisg@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PHP_VERSION 7.2

# update distro and install common dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        git \
        lsb-release \
        unzip \
        vim \
        wget && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# install PHP
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt-get update && apt-get install -y --no-install-recommends \
        libapache2-mod-php${PHP_VERSION} \
        php${PHP_VERSION} \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-zip \
        php-amqp \
        php-apcu \
        php-apcu-bc \
        php-xml && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# install apache
RUN apt-get update && apt-get install -y --no-install-recommends \
        apache2 && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/www && \
    a2enmod rewrite
COPY ./apache.conf /etc/apache2/sites-available/000-default.conf

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# intall node & gulp
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 \
    software-properties-common && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get update && apt-get install -y --no-install-recommends \
        nodejs && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    npm install gulp-cli -g

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]