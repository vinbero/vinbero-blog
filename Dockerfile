
FROM vinbero/alpine-vinbero_mt_http_lua
MAINTAINER Byeonggon Lee (gonny952@gmail.com)

EXPOSE 80

RUN apk update && apk add luarocks pcre-dev sqlite-dev g++

RUN git clone https://github.com/vinbero/vinbero-blog
RUN luarocks-5.3 install lsqlite3
RUN luarocks-5.3 install rapidjson
RUN luarocks-5.3 install gonapps-url-decoder
RUN luarocks-5.3 install gonapps-url-query-parser
RUN luarocks-5.3 install gonapps-url-router
RUN luarocks-5.3 install gonapps-jwt
RUN mkdir /var/lib/cublog
RUN /vinbero-blog/gendb.lua /var/lib/cublog/cublog.db
RUN cp -r /vinbero-blog/src/* /usr/share/lua/5.3/
RUN cp /vinbero-blog/config.json /srv/config.json

CMD ["/usr/bin/vinbero", "-c", "/srv/config.json", "-f", "60"]
