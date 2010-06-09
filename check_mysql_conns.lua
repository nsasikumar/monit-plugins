#!/usr/bin/env lua

-- check mysql connections 
-- author: ery.lee@gmail.com from monit.cn

-- show global status where Variable_name in ('Connections', 'Threads_created', 'Threads_cached', 'Max_used_connections', 'Threads_running', 'Thread_connected')
-- show global variables where Variable_name in ('thread_cache_size', 'max_connections')

dofile("plugin.lua")

-- do check
function check(opts) 
  require "luasql.mysql"
  env = assert (luasql.mysql())
  conn = assert (env:connect("mysql", opts["user"], opts["password"], opts["host"], tonumber(opts["port"])))
  -- retrieve status
  cursor = assert (conn:execute"show global variables where Variable_name in ('thread_cache_size', 'max_connections')")
  variables = {}
  row = curor:fetch ({}, "a")
  while row do
    variables[row.Variable_name] = row.Value
    row = cursor:fetch (row, "a")
  end
  cursor = assert (con:execute"show global status where Variable_name in ('Connections', 'Threads_created', 'Threads_cached', 'Max_used_connections', 'Threads_running', 'Thread_connected')")
  metrics = {}
  while row do
    metric = string.gsub(string.lower(row.Variable_name), "Threads_", "")
    metrics[metric] = row.Value
    row = cursor:fetch(row, "a")
  end
  -- print result
  summary = string.format("thread_cache_size = %s, max_connections = %s", variables["thread_cache_size"], variables["max_connections"])
  print("OK - "..summary)
  print("count-metrics: connections,created\r\n") 
  for k, v in pairs(variables) do
    print(string.format("attr: %s=%s", k, v))
  end
  for k,v in pairs(metrics) do
    print(string.format("metric: %s=%s", k, v))
  end
  -- close everything
  cur:close()
  con:close()
  env:close()
end

-- usage
function usage() 
  print("Usage: check_mysql_conns --host=Host --user=User --password=Password --port=Port")
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

