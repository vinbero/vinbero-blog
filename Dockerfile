
FROM vinbero/vinbero_mt_http_lua
MAINTAINER Byeonggon Lee (gonny952@gmail.com)

EXPOSE 80

RUN apk update && apk add --no-cache luarocks pcre-dev sqlite-dev g++ openssl-dev nginx

RUN git clone https://github.com/vinbero/vinbero-blog
RUN git clone https://github.com/vinbero/vinbero-blog-frontend
RUN luarocks-5.3 install lsqlite3
RUN luarocks-5.3 install rapidjson
RUN luarocks-5.3 install gonapps-url-decoder
RUN luarocks-5.3 install gonapps-url-query-parser
RUN luarocks-5.3 install gonapps-url-router
RUN luarocks-5.3 install gonapps-jwt
RUN mkdir /var/lib/cublog
RUN mkdir /srv/html
RUN cp /vinbero-blog-frontend/* /srv/html/
RUN lua5.3 /vinbero-blog/gendb.lua /var/lib/cublog/cublog.db
RUN cp -r /vinbero-blog/src/* /usr/share/lua/5.3/
RUN cp /vinbero-blog/config.json /srv/config.json
RUN cp /vinbero-blog/nginx.conf /etc/nginx/nginx.conf
RUN cp /vinbero-blog/start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
