#!/bin/sh

export NODE_PATH=.
cd /var/www/node
forever start index.js
