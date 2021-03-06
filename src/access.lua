local JSON = require "kong.plugins.middleman.json"
local cjson = require "cjson"
local url = require "socket.url"
local http = require "socket.http"
local string_format = string.format
local ltn12 = require 'ltn12'
local kong_response = kong.response

local get_headers = ngx.req.get_headers
local get_uri_args = ngx.req.get_uri_args
local read_body = ngx.req.read_body
local get_body = ngx.req.get_body_data
local get_method = ngx.req.get_method
local ngx_re_match = ngx.re.match
local ngx_re_find = ngx.re.find

local HTTP = "http"
local HTTPS = "https"

local _M = {}

local function parse_url(host_url)
  local parsed_url = url.parse(host_url)
  if not parsed_url.port then
    if parsed_url.scheme == HTTP then
      parsed_url.port = 80
     elseif parsed_url.scheme == HTTPS then
      parsed_url.port = 443
     end
  end
  if not parsed_url.path then
    parsed_url.path = "/"
  end
  return parsed_url
end

local function getAuthUrl(host_url,conf_url)
  local response = "dummy"
  ngx.log(ngx.ERR,host_url)
  ngx.log(ngx.ERR,conf_url)
  for w in conf_url:gmatch('([^,]+)')
    do
        ngx.log(ngx.ERR,w)
        if not string.match(w, host_url) then
            ngx.log(ngx.ERR,"returning" .. w)
            return w
        end
    end
    return "Dummy"
end



function _M.execute(conf)
  ngx.log(ngx.ERR,ngx.var.server_addr)
  local headers_from_req = get_headers()
  local name = "[middleman] "
  local ok, err
  ngx.log(ngx.ERR,conf.url)
  ngx.log(ngx.ERR,headers_from_req["Host"])
  local authurl = getAuthUrl(ngx.var.server_addr,conf.url)
  ngx.log(ngx.ERR,authurl)
  --ngx.log(ngx.ERR,"http object is " .. http)
  local res = {}
  r,c,h = http.request {method="GET",url=authurl,headers= {cicauth="true",Authorization=headers_from_req["Authorization"],route=headers_from_req["route"]},sink = ltn12.sink.table(res)}
  --ngx.log(ngx.ERR,headers_from_req["Authorization"])
  res = table.concat(res)
  --local response_body = string.match(r,"%b{}")
  ngx.log(ngx.ERR,c)
  if (c == 401 or c == 403)then
  return kong_response.exit(c,res)
  else return
  end	  

end

return _M
