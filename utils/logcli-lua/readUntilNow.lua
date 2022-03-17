local JSON = (loadfile "JSON.lua")() -- one-time load of the routines
local redis = require'redis'
local client = redis.connect('127.0.0.1', 6379)

-- command options
local initial_logcli_params = "query '{filename=\"/home/app/dyneth/data/geth.log\"}' --forward --output jsonl --limit 10000"

client:del("logcli:timestamp")
client:del("logcli:connections")
local logcli_params = initial_logcli_params .. " --since=360h"

local any_lines = true
while any_lines do
  any_lines = false
  local handle = io.popen("logcli " .. logcli_params .. " 2>/dev/null")

  -- The first line could be a duplicate I have already read
  handle:read("*l")
  while true do -- contains one (and only one) break
    local line = handle:read("*l")
    if line == nil then break end -- the loop exits here ----------------------
    any_lines = true
    local result = JSON:decode(line)
    local connectionIP = string.match(result.line, "conn=(%d+\.%d+\.%d+\.%d+)")
    if connectionIP then
      client:hincrby("logcli:connections", connectionIP, 1)
    end
    client:set("logcli:timestamp", result.timestamp)
  end
  -- start a new request with the current timestamp
  if any_lines then
    local timestamp = client:get("logcli:timestamp")
    logcli_params = initial_logcli_params .. " --from=\"" .. timestamp .. "\""
  end
end
