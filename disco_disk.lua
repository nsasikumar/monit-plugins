#!/usr/bin/env lua

-- discover linux disks
-- author: ery.lee@gmail.com from monit.cn

dofile("plugin.lua")

function disco()
  output = os.cmd("df")
  lines = output:split("[\r\n]+")
  pat = "^(.-)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%%%s+([/%w_-%d]+)$"
  disks = {}
  for _,line in pairs(lines) do
    disk = {string.match(line, pat)}
    if #disk == 6 then
      table.insert(disks, disk)
    end
  end
  disks = table.filter(disks, function(disk) 
    return not (disk[2] == "0" or disk[3] == "0" or disk[4] == "0") 
  end)
  print("OK - found "..#disks.." disks\r\n")
  for _,disk in pairs(disks) do
    print(string.format("entry:disk: path=%s,fs=%s,total=%sKB", disk[6], disk[1], disk[2]))
    print(string.format("service: name=Disk-%s,command=check_disk_df,params=path=%s", disk[6], disk[6]))
  end
end

-- usage
function usage() 
  print("Usage: disco_disk")
end

ok, err = pcall(disco)
if not ok then
  print("UNKNOWN - plugin internal error\r\n")
  print(err)
end
--
