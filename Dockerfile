FROM php:8.2-fpm-alpine AS php-upstream
FROM composer/composer:2-bin AS composer-upstream
FROM mlocati/php-extension-installer:2 AS extension-installer-upstream

##php-base--------------------------------------------------------------------------------------------------------------
FROM php-upstream AS php-base

ENV \
    DIR_DATA="/data" \
    DIR_WORK="/var/www/html"

ARG ALPINE_REPO=http://dl-cdn.alpinelinux.org/alpine/
RUN --mount=type=cache,target=/var/cache/apk,target=/var/cache/apk,sharing=locked,id=apk \
    sed -i -r 's#^http.+/(.+/main)#'${ALPINE_REPO%/}'/\1#' /etc/apk/repositories \
    && sed -i -r 's#^http.+/(.+/community)#'${ALPINE_REPO%/}'/\1#' /etc/apk/repositories \
    && sed -i -r 's#^http.+/(.+/testing)#'${ALPINE_REPO%/}'/\1#' /etc/apk/repositories \
    && apk add --update \
        bash \
        binutils \
        ca-certificates \
        coreutils \
        curl \
        fcgi \
        git \
        less \
        make \
        net-tools \
        openssh-client \
        procps \
        psmisc \
        shadow \
        unzip \
        util-linux \
        wget \
        zip \
        zlib \
    && true

# https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions
RUN --mount=type=bind,from=extension-installer-upstream,source=/usr/bin/install-php-extensions,target=/usr/local/bin/install-php-extensions \
    --mount=type=cache,target=/var/cache/apk,target=/var/cache/apk,sharing=locked,id=apk \
    install-php-extensions \
        apcu \
        bcmath \
        intl \
        opcache \
        pcntl \
        pdo_pgsql \
        uuid \
        xhprof \
        zip \
    && true

COPY --link .docker/rootfs/php-base/ /

ARG USER_ID=10001
ARG GROUP_ID=10001
RUN \
    chmod +x \
        /usr/local/bin/docker-entrypoint \
        /usr/local/bin/docker-healthcheck \
        /usr/local/bin/docker-php-ext-disable \
        /usr/local/bin/docker-php-ext-enable \
    && usermod -u ${USER_ID} www-data \
    && groupmod -g ${GROUP_ID} www-data \
    && mkdir -p ${DIR_DATA} ${DIR_WORK} \
    && chown -R www-data:www-data ${DIR_DATA} ${DIR_WORK} /usr/local/etc/php \
    && true

WORKDIR ${DIR_WORK}

##php-dev---------------------------------------------------------------------------------------------------------------
FROM php-base AS php-dev

RUN --mount=type=bind,from=extension-installer-upstream,source=/usr/bin/install-php-extensions,target=/usr/local/bin/install-php-extensions \
    --mount=type=cache,target=/var/cache/apk,target=/var/cache/apk,sharing=locked,id=apk \
    apk add --update \
        gnupg \
        htop \
        lsof \
        man-pages \
        mandoc \
        nano \
        rsync \
        starship \
        sudo \
        tzdata \
        vim \
    && IPE_DONT_ENABLE=1 install-php-extensions xdebug \
    && echo "www-data ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/www-data \
    && chmod 0440 /etc/sudoers.d/www-data \
    && true

COPY --from=composer-upstream --link /composer /usr/local/bin/
COPY --link .docker/rootfs/php-dev/ /

ENV \
    COMPOSER_HOME="${DIR_DATA}/.composer" \
    HISTFFILE="${DIR_DATA}/.bash_history" \
    PROMPT_COMMAND="history -a"

VOLUME [ "${DIR_DATA}" ]
USER "www-data"
ENTRYPOINT [ "docker-entrypoint" ]
CMD ["php-fpm"]
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["docker-healthcheck"]

##php-vendor------------------------------------------------------------------------------------------------------------
FROM php-base AS php-vendor

COPY --link composer.json composer.lock symfony.lock ./
RUN \
    --mount=type=ssh \
    --mount=type=bind,from=composer-upstream,source=/composer,target=/usr/local/bin/composer \
    --mount=type=cache,target=/var/cache/composer,sharing=locked,id=composer \
    COMPOSER_HOME=/var/cache/composer composer install \
        --prefer-dist \
        --no-dev \
        --no-scripts \
        --no-progress \
        --no-interaction \
        --optimize-autoloader \
    && true

##php-prod--------------------------------------------------------------------------------------------------------------
FROM php-base AS php-prod

COPY --from=php-vendor --link --chown=www-data:www-data /var/www/html/vendor/ vendor/
COPY --link --chown=www-data:www-data . .

USER "www-data"
ENTRYPOINT [ "docker-entrypoint" ]
CMD ["php-fpm"]
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["docker-healthcheck"]
