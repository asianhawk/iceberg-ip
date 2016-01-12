local ibs = require("icebergsupport")
local script_path = ibs.dirname(debug.getinfo(1).source:sub(2,-1))
local icon = ibs.join_path(script_path, "ip.png")

local config = {
  name = "ip",
}
ibs.merge_table(config, plugin_ip or {})

local function ip_windows()
  local candidates = {}
  local ok, stdout, stderr =  ibs.command_output([[ipconfig]])
  if ok then
    local text = ibs.crlf2lf(ibs.local2utf8(stdout))
    local lines = ibs.regex_split("\r?\n", Regex.NONE, text)
    local regname = Regex.new([[([^\s]{1}.*):]], Regex.NONE)
    local regipv4 = Regex.new([[.*IPv4.*:\s*(.*)]], Regex.NONE)
    local name = ""
    for i, line in ipairs(lines) do
      if regname:match(line) then
        name = regname:_1()
      end
      if regipv4:match(line) then
        table.insert(candidates, {value=regipv4:_1(), description=name, icon=icon})
      end
    end
  end
  return candidates
end

local function ip_linux()
  local candidates = {}
  local ok, stdout, stderr =  ibs.command_output([[ip addr show]])
  if ok then
    local text = ibs.crlf2lf(ibs.local2utf8(stdout))
    local lines = ibs.regex_split("\r?\n", Regex.NONE, text)
    local regname = Regex.new([[\d+\s*:\s*([^\s]+)\s*:(.*)]], Regex.NONE)
    local regip = Regex.new([[\s+inet.*]], Regex.I)
    for i, line in ipairs(lines) do
      if regname:match(line) then
        table.insert(candidates, {value=regname:_1(), description=regname:_2(), icon=icon})
      elseif regip:match(line) then
        table.insert(candidates, {value=line})
      end
    end
  else
    ok, stdout, stderr =  ibs.command_output([[/sbin/ifconfig]])
    if ok then
      local text = ibs.crlf2lf(ibs.local2utf8(stdout))
      local lines = ibs.regex_split("\r?\n", Regex.NONE, text)
      local regname = Regex.new([[([^\s]+)\s*(.*)]], Regex.NONE)
      local regip = Regex.new([[\s+inet.*]], Regex.I)
      for i, line in ipairs(lines) do
        if regname:match(line) then
          table.insert(candidates, {value=regname:_1(), description=regname:_2(), icon=icon})
        elseif regip:match(line) then
          table.insert(candidates, {value=line})
        end
      end
    end
  end
  if ok then
  end
  return candidates
end

commands[config.name] = { 
  path = function(args) 
    if #args == 0 then return end
    ibs.set_clipboard(args[1])
  end, 
  completion = function(values)
    local platform = ibs.build_platform()
    if string.find(platform, "win") == 1 then
      return ip_windows()
    else
      return ip_linux()
    end
  end,
  description = "list current ip addresses",
  icon=icon,
  history=false
}
