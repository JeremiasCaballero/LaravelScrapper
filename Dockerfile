FROM ubuntu:20.04

# Install PHP and nginx-wo
RUN apt-get -y update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends gnupg wget curl software-properties-common \
    #&& add-apt-repository ppa:wordops/nginx-wo -uy \
    && apt-get -y update

RUN apt-get -y install --no-install-recommends \
    php7.4 \
    php7.4-opcache  \
    php7.4-mysql \
    php7.4-intl \
    php7.4-mbstring \
    php7.4-gd \
    php7.4-xml \
    php7.4-zip \
    php7.4-redis \
    php7.4-curl

# Install unit
RUN curl http://nginx.org/keys/nginx_signing.key | apt-key add - \
    && echo "deb https://packages.nginx.org/unit/ubuntu/ focal unit \
    deb-src https://packages.nginx.org/unit/ubuntu/ focal unit"  | tee -a /etc/apt/sources.list.d/unit.list \
    && apt-get -y update \
    && apt-get -y install unit unit-php \
    && unitd --version

# Cleanup /www
RUN rm -fr /var/www/html
WORKDIR /var/www

# Install composer
RUN curl -o /usr/local/bin/composer https://getcomposer.org/composer-stable.phar && chmod +x /usr/local/bin/composer

# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/unit.log

WORKDIR /var/www

EXPOSE 8080
STOPSIGNAL SIGQUIT

COPY . /var/www/

RUN composer install
RUN chown -R www-data:www-data /var/www/

RUN echo \
    '{ \
        "listeners": { \
            "*:80": { "pass": "routes" } \
        }, \
        "routes": [ \
            { \
                "match": { "uri": "!/index.php" }, \
                "action": { \
                    "share": "/var/www/public/", \
                    "fallback": { "pass": "applications/laravel" } \
                } \
            } \
        ], \
        "applications": { \
            "laravel": { "type": "php", "root": "/var/www/public/", "script": "index.php" } \
        } \
    }' > /tmp/config.json;

RUN unitd \
    && curl -X PUT --data-binary @/tmp/config.json --unix-socket \
    /var/run/control.unit.sock http://localhost/config/ \
    && kill `pidof unitd`

CMD ["unitd", "--no-daemon", "--group", "www-data", "--user", "www-data", "--control", "unix:/var/run/control.unit.sock", "php artisan serve --port=8080"]
