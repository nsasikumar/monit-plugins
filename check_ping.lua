#!/usr/bin/env lua

-- check ping
-- author: ery.lee@gmail.com from monit.cn

dofile("plugin.lua")

-- do check
function check(opts) 
  output = os.cmd("ping".." -c"..opts["packets"].." -w"..opts["timeout"].." "..opts["host"])
  _,_,pl = string.find(output, "%s(%d+%%) packet loss")
  if pl == "100%" then
      print("CRITICAL - packet loss = "..pl)
  else 
    _,_,rtmin,rta,rtmax=string.find(output, "([0-9]+.[0-9]+)/([0-9]+.[0-9]+)/([0-9]+.[0-9]+)/([0-9]+.[0-9]+) ms")
    if pl == '0%' then
      print("OK - packet loss = "..pl..", rta = "..rta.."ms\r\n")
    else
      print("WARNING - packet loss = "..pl..", rta = "..rta.."ms\r\n")
    end
    print("metric: pl="..pl)
    print("metric: rta="..rta.."ms")
    print("metric: rtmin="..rtmin.."ms")
    print("metric: rtmax="..rtmax.."ms")
  end
end

-- usage
function usage() 
  print("Usage: check_ping --host=Host --packets=Packets --timeout=Timeout")
end

-- parse arguments
opts = getopt(arg, {"host", "packets", "timeout"})
opts["packets"] = opts["packets"] or "4"
opts["timeout"] = opts["timeout"] or "8"
if not opts["host"] then
  print("UNKNOWN - miss argument = 'host'\r\n")
  usage()
  return
end

ok, err = pcall(check, opts)
if not ok then
  print("UNKNOWN - plugin internal error\r\n")
  print(err)
end
