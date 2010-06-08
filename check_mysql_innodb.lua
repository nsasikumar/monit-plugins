#!/usr/bin/env lua

-- check mysql innodb by "show status like 'Innodb_%'"

dofile("plugin.lua")

require "luasql.mysql"

-- do check
function check(opts) 
  env = assert (luasql.mysql())
  con = assert (env:connect("mysql", opts["user"], opts["password"], opts["host"], tonumber(opts["port"])))
  cur = assert (con:execute"show global variables where Variable_name = 'innodb_buffer_pool_size'")
  row = cur:fetch ({}, "a")
  print(string.format("OK - Buffer Pool Size = %sM\r\n", row.Value/(1024*1024)))
  -- retrive innodb variables
  cur = assert (con:execute"show global variables like 'innodb_%'")
  row = cur:fetch ({}, "a")
  while row do
    print(string.format("attr: %s=%s", row.Variable_name, row.Value))
    row = cur:fetch (row, "a")
  end
  -- retrieve innodb status
  cur = assert (con:execute"show global status like 'Innodb_%'")
  row = cur:fetch ({}, "a")
  while row do
    metric = string.sub(row.Variable_name, string.len('Innodb_') + 1)
    print(string.format("metric: %s=%s", metric, row.Value))
    row = cur:fetch (row, "a")
  end
  -- close everything
  cur:close()
  con:close()
  env:close()
end

-- usage
function usage() 
  print("usage: check_mysql_innodb --host=Host --user=User --password=Password --port=Port")
end

-- parse arguments
opts = getopt(arg, {"host", "password", "user", "port"})
if not opts["port"] then opts["port"] = "3306" end
for i, o in ipairs({"host", "password", "user"}) do
  if not opts[o] then
    print(string.format("UNKNOWN - miss argument = '%s'\r\n", o))
    usage()
    return
  end
end

status, err = pcall(check, opts) 
if not status then
  print("UNKNOWN - plugin internal error\r\n")
  print(err)
end