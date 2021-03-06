
FROM vinbero/vinbero_mt_http_lua
MAINTAINER Byeonggon Lee (gonny952@gmail.com)

EXPOSE 80

ENV PASSWORD password

RUN mkdir -p /usr/src
RUN apk update && apk add --no-cache luarocks pcre-dev sqlite-dev g++ openssl-dev nginx jq
RUN git clone https://github.com/vinbero/vinbero-blog /usr/src/vinbero-blog
RUN git clone https://github.com/vinbero/vinbero-blog-frontend /usr/src/vinbero-blog-frontend
RUN luarocks-5.3 install lsqlite3
RUN luarocks-5.3 install rapidjson
RUN luarocks-5.3 install gonapps-url-decoder
RUN luarocks-5.3 install gonapps-url-query-parser
RUN luarocks-5.3 install gonapps-url-router
RUN luarocks-5.3 install gonapps-jwt
RUN mkdir /var/lib/cublog
RUN mkdir /srv/html
RUN cp /usr/src/vinbero-blog-frontend/* /srv/html/
RUN lua5.3 /usr/src/vinbero-blog/gendb.lua /var/lib/cublog/cublog.db
RUN cp -r /usr/src/vinbero-blog/src/* /usr/share/lua/5.3/
RUN cp /usr/src/vinbero-blog/vinbero-config.json /srv/vinbero-config.json
RUN cp /usr/src/vinbero-blog/cublog-config-template.json /srv/cublog-config-template.json
RUN cp /usr/src/vinbero-blog/nginx.conf /etc/nginx/nginx.conf
CMD nginx; jq ".[\"admin.password\"] |= \"$PASSWORD\"" /srv/cublog-config-template.json > /srv/cublog-config.json; vinbero -c /srv/vinbero-config.json
