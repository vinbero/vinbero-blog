apk add luarocks pcre-dev sqlite-dev g++
sudo cp -r src/* /usr/share/lua/5.3/
luarocks-5.3 install lsqlite3
luarocks-5.3 install rapidjson
luarocks-5.3 install gonapps-url-decoder
luarocks-5.3 install gonapps-url-query-parser
luarocks-5.3 install gonapps-url-router
luarocks-5.3 install gonapps-jwt
/vinbero-blog/gendb.lua cublog.db
