#!/bin/bash
set -e

source ./lib.sh
source ./base.sh

install_if_not_exists apache2
enable_service apache2

install_if_not_exists php-fpm
install_if_not_exists php-mysql
install_if_not_exists php-cli
install_if_not_exists php-curl
install_if_not_exists php-mbstring
