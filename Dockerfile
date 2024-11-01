
FROM php:8.1-fpm AS laravel

RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Define o diretório de trabalho para Laravel
WORKDIR /var/www/html/laravel

# Copia os arquivos do Laravel
COPY ./laravel .

# Instala as dependências do Laravel
RUN composer install

# Build da aplicação React
FROM node:16 AS react

# Define o diretório de trabalho para React
WORKDIR /app

# Copia os arquivos da aplicação React
COPY ./react .

# Instala as dependências
RUN npm install

# Build da aplicação React
RUN npm run build

# Agora, vamos combinar os dois
FROM php:8.1-fpm

# Instala dependências do sistema para o Laravel
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Define o diretório de trabalho
WORKDIR /var/www/html

# Copia os arquivos do Laravel
COPY --from=laravel /var/www/html/laravel .

# Copia os arquivos da aplicação React
COPY --from=react /app/build ./public

# Expondo a porta do PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]
