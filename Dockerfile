FROM php:8.2-apache

# Activer le module rewrite pour Apache
RUN a2enmod rewrite

# Installer les dépendances système
RUN apt-get update \
    && apt-get install -y \
        libzip-dev git wget curl gnupg libicu-dev --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Installer les extensions PHP requises
RUN docker-php-ext-install intl pdo pdo_mysql zip

# Installer Node.js et Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install --global yarn

# Vérifier l'installation de Node.js et Yarn
RUN node -v && yarn -v

# Installer Composer
RUN wget https://getcomposer.org/download/2.8.2/composer.phar \
    && mv composer.phar /usr/bin/composer && chmod +x /usr/bin/composer

# Copier la configuration Apache
COPY .docker/apache.conf /etc/apache2/sites-enabled/000-default.conf

# Définir le répertoire de travail
WORKDIR /var/www

# Copier l'ensemble du projet
COPY . /var/www

# Ajuster les permissions pour l'utilisateur Apache
RUN chown -R www-data:www-data /var/www

# Installer les dépendances Composer
RUN composer install -n --prefer-dist

# Installer les dépendances front-end avec Yarn
RUN yarn install

# Exécuter les commandes Symfony
RUN php bin/console cache:clear
