FROM php:8.3.4-fpm-alpine3.18

RUN apk add --no-cache gcc musl-dev make shadow openssl bash mysql-client nodejs vim npm php-xml php-curl php-mbstring freetype-dev libjpeg-turbo-dev libpng-dev libzip-dev git pcre-dev $PHPIZE_DEPS
RUN mkdir -p /usr/src/php/ext/redis; \
    curl -fsSL https://pecl.php.net/get/redis --ipv4 | tar xvz -C "/usr/src/php/ext/redis" --strip 1; \
    docker-php-ext-install redis;
RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-install exif

RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd

RUN touch /home/www-data/.bashrc | echo "PS1='\w\$ '" >> /home/www-data/.bashrc

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN npm config set cache /var/www/.npm-cache --global

RUN npm install -g corepack

COPY ./.docker/php /usr/local/etc/php/conf.d

RUN usermod -u 1000 www-data

WORKDIR /var/www

RUN rm -rf /var/www/html && ln -s public html

USER www-data

EXPOSE 9000