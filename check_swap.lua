#!/usr/bin/env lua

-- check linux swap
-- author: ery.lee@gmail.com from monit.cn

dofile("plugin.lua")

-- do check
function check() 
  local output = os.cmd("free o")
  local headers = {"total", "used", "free"}
  local metrics = {string.match(output, "Swap:%s+(%d+)%s+(%d+)%s+(%d+)")}
  if #metrics < 3 then 
    print("UNKNOWN - no swap data\r\n") 
    return  
  end
  local metrics = table.map(metrics, function(v) return tonumber(v) end)
  local swaptab = table.zip(headers, metrics)
  swaptab["usage"] = string.format("%.2f%%", (swaptab["used"] * 100 / swaptab["total"]))
  print(string.format("OK - swap usage = %s\r\n", swaptab["usage"]))
  for k,v in pairs(swaptab) do
    print(string.format("metric: %s=%s", k, v))
  end
end

-- usage
function usage() 
  print("Usage: check_swap_free")
end

-- parse arguments
ok, err = pcall(check)
if not ok then
  print("UNKNOWN - plugin internal error\r\n")
  print(err)
end
