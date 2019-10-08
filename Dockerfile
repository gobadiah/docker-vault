FROM vault:0.10.0 as vault

FROM docker:19-git

RUN apk update && apk add --no-cache vim curl wget procps jq sudo zsh bash \
  ncurses openssl nodejs gnupg yarn
RUN apk add pass --update-cache \
  --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
  --allow-untrusted
RUN pass init "My password store"

COPY --from=vault /bin/vault /usr/local/bin/vault

RUN apk -Uuv add groff less python py-pip && \
  pip install awscli && \
  apk --purge -v del py-pip && \
  rm /var/cache/apk/*

RUN wget https://github.com/direnv/direnv/releases/download/v2.15.2/direnv.linux-amd64 -O direnv && \
  chmod +x direnv && mv direnv /usr/local/bin && \
  echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc && \
  echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

RUN yarn global add heroku

ADD https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/amd64/kubectl /usr/local/bin/kubectl

RUN chmod +x /usr/local/bin/kubectl

RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache


# See https://github.com/facebook/flow/issues/3649 for an explanation for this
RUN apk --no-cache add ca-certificates
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk
RUN apk add glibc-2.28-r0.apk

RUN pip install datadog
