#!/usr/bin/env bash

tera -t /tmpl/postfix/main.cf -e /tmpl/default.yaml -o /etc/postfix/main.cf
