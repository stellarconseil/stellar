ARG PHP_VERSION=7.3.3
ARG COMPOSER_VERSION=1.10.1

FROM composer:${COMPOSER_VERSION}
FROM php:${PHP_VERSION}-apache

RUN apt-get update -y && apt-get install -y openssl curl zip unzip git libzip-dev \
    && apt-get -y autoclean \
    && docker-php-ext-install pdo mbstring zip mysqli  pdo_mysql \
    && docker-php-ext-configure zip --with-libzip 
    
#RUN apt update && apt install -y --no-install-recommends \
 #       libfreetype6-dev \
  #      libjpeg62-turbo-dev \
   #     libpng-dev \
    #&& docker-php-ext-install -j$(nproc) iconv \
    #&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    #&& docker-php-ext-install -j$(nproc) gd \
    #&& rm -r /var/lib/apt/lists/*



# save composer
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 16.0.0

# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash


# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

#install js dependency
RUN mkdir -p /var/www/html/resources/assets/js/desktop
COPY ./resources/assets/js/desktop/package.json /var/www/html/resources/assets/js/desktop/
#COPY ./resources/assets/js/desktop/package-lock.json /var/www/html/resources/assets/js/desktop/
RUN npm install -g yarn
#RUN yarn --prefix /var/www/html/resources/assets/js/desktop install --only=production

COPY ./composer.json /var/www/html/
COPY ./composer.lock /var/www/html/

WORKDIR /var/www/html/

# Run composer
#RUN composer install --prefer-dist --no-scripts  --no-autoloader && rm -rf /.composer

COPY ./resources/assets/js/desktop ./resources/assets/js/desktop
RUN mkdir -p public/build
# build js
#RUN yarn --prefix /var/www/html/resources/assets/js/desktop run build
#RUN rm -rf /var/www/html/resources/assets/js/desktop/node_modules/

COPY . /var/www/html/
#COPY ./.docker/deps/apache2/000-default.conf /etc/apache2/sites-available/

# Enable mod_rewrite to enable URL matching in apache
RUN a2enmod rewrite

#RUN chown www-data:www-data -R ./
#RUN composer dump-autoload -o && \
 RUN php artisan clear-compiled && \
    php artisan optimize && \
    php artisan route:clear

EXPOSE 80
