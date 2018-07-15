FROM vault:0.10.0 as vault

FROM docker:18.04.0-ce-git

RUN apk update && apk add --no-cache vim curl wget procps jq sudo zsh bash \
  ncurses openssl nodejs gnupg
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

RUN npm install -g heroku

ADD https://storage.googleapis.com/kubernetes-release/release/v1.10.1/bin/linux/amd64/kubectl /usr/local/bin/kubectl

RUN chmod +x /usr/local/bin/kubectl
