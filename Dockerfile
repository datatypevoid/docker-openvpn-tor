
# Smallest base image
FROM alpine:latest

LABEL maintainer="maintenance@nici.solutions"

# Testing: pamtester
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
  && echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
  && apk add --update \
      openvpn \
      iptables \
      bash \
      easy-rsa \
      openvpn-auth-pam \
      google-authenticator \
      pamtester \
      tor@testing \
      curl \
      git \
      nano \
      vim \
    && ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki
ENV EASYRSA_VARS_FILE $OPENVPN/vars

# Prevents refused client connection because of an expired CRL
ENV EASYRSA_CRL_DAYS 3650

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

COPY ./config/torrc /etc/tor/torrc.default
RUN chown -R tor /etc/tor

CMD ["start"]

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
