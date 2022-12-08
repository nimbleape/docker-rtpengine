#!/bin/bash
set -e

PATH=/usr/local/bin:$PATH

case $CLOUD in
  gcp)
    LOCAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
    PUBLIC_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)
    ;;
  aws)
    LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
    ;;
  digitalocean)
    LOCAL_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)
    PUBLIC_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
    ;;
  azure)
    LOCAL_IP=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text")
    PUBLIC_IP=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2017-08-01&format=text")
    ;;
  *)
    ;;
esac

LOCAL_IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`

if [ -n "$INTERFACE_LIST" ]; then
  MY_IP="$INTERFACE_LIST"
elif [ -n "$PUBLIC_IP" ]; then
  MY_IP="$LOCAL_IP"!"$PUBLIC_IP"
else
  MY_IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
fi

if [ "$1" = 'rtpengine' ]; then
  shift
  echo "rtpengine --interface=$MY_IP --foreground --log-stderr --port-min=$MIN_PORT --port-max=$MAX_PORT --recording-dir=$RECORDING_DIR --recording-method=$RECORDING_METHOD --recording-format=$RECORDING_FORMAT --log-level=$LOG_LEVEL --delete-delay=$DELETE_DELAY --listen-http=$HTTP_PORT --listen-ng=$NG_PORT $@"
  exec rtpengine --interface=$MY_IP --foreground --log-stderr --port-min=$MIN_PORT --port-max=$MAX_PORT --recording-dir=$RECORDING_DIR --recording-method=$RECORDING_METHOD --recording-format=$RECORDING_FORMAT --log-level=$LOG_LEVEL --delete-delay=$DELETE_DELAY --listen-http=$HTTP_PORT --listen-ng=$NG_PORT "$@"
fi

exec "$@"