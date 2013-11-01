local ibs = require("icebergsupport")
local script_path = ibs.join_path(ibs.CONFIG_DIR, "luamodule")
local icon = ibs.join_path(script_path, "ip", "ip.png")

commands["ip"] = { 
  path = function(args) 
    if #args == 0 then return end
    ibs.set_clipboard(args[1])
  end, 
  completion = function(values)
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
  end,
  description = "list current ip addresses",
  icon=icon,
  history=false
}
