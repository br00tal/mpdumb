FROM easypi/alpine-arm:edge

RUN mkdir /cinch && \
  adduser -S cinch && \
  chown -R cinch /cinch

WORKDIR /cinch

COPY mpdumb.rb .
COPY init.sh .
COPY config.json.tmpl .
COPY Gemfile .

RUN \
  apk add --update \
    git \
    go \
    make \
    musl-dev \
    ruby \
    ruby-dev && \
  git clone https://github.com/jwilder/dockerize && \
  cd dockerize && \
  export PATH=$PATH:/root/go/bin && \
  go get github.com/robfig/glock && \
  glock sync -n < GLOCKFILE && \
  go build && \
  mv dockerize /usr/bin/dockerize && \
  cd .. && \
  rm -rf dockerize && \
  rm -rf /root/go && \
  gem install --no-ri --no-rdoc bundler && \
  bundle config --global silence_root_warning 1 && \
  bundle install && \
  cd /cinch && \
  apk del \
    git \
    go \
    make \
    musl-dev \
    ruby-dev && \
  rm -rf /var/cache/apk/*

USER cinch

CMD ["/cinch/init.sh"]
