local JSON = require "kong.plugins.middleman.json"
local cjson = require "cjson"
local url = require "socket.url"
local http = require "socket.http"
local string_format = string.format

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

function _M.execute(conf)
  local headers_from_req = get_headers()
  local name = "[middleman] "
  local ok, err
  r,c,h = http.request {method="GET",url=conf.url,headers= {Authorization=headers["Authorization"],route=headers["route"]}}
  return kong_response.send(r, "Ok")

end

return _M
