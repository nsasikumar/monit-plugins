#!/usr/bin/env lua

-- check http port
-- author: ery.lee@gmail.com from monit.cn

dofile("plugin.lua")

-- do check
function check(opts) 
  local http = require("socket.http")
  http.TIMEOUT = 8
  t1 = socket.gettime()
  url = string.format("http://%s:%s/%s", opts["host"], opts["port"], opts["url"])
  local b,c,h,s = http.request(url)
  t2 = socket.gettime()
  if not b then
    print("CRITICAL - "..c.."\r\n")
    return
  end
  size = string.len(b)
  escaped_time = (t2 -t1) * 1000
  if c >= 500 then
    print("CRITICAL - status = "..s.."\r\n")
  elseif c >= 400 then
    print("WARNING - status = "..s.."\r\n")
  else 
    print(string.format("OK - status = %s, size = %sbyte, response time = %.2fms\r\n", s, size, escaped_time))
    print("metric: size="..size)
    print("metric: time="..escaped_time)
  end
end

-- usage
function usage() 
  print("Usage: check_http --host=Host --port=Port --url=Url")
end

-- parse arguments
opts = getopt(arg, {"host", "port"})
opts["port"] = opts["port"] or "80"
url = opts["url"] or ""
opts["url"] = url:gsub("^/+(.-)", "%1")
for _, o in ipairs({"host", "port"}) do
  if not opts[o] then
    print(string.format("UNKNOWN - miss argument = '%s'\r\n", o))
    usage()
    return
  end
end

ok, err = pcall(check, opts)
if not ok then
  print("UNKNOWN - plugin internal error\r\n")
  print(err)
end
