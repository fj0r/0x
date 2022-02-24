#!/bin/bash
rsync -a /app/wireguard/wg0.conf /etc/wireguard/wg0.conf
wg syncconf wg0 <(wg-quick strip wg0)
