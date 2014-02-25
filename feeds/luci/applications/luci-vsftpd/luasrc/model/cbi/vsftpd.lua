--[[
LuCI - Lua Configuration Interface

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0
]]--

local fs = require "nixio.fs"

local running=(luci.sys.call("pidof vsftpd > /dev/null") == 0)
if running then	
	m = Map("vsftpd", translate("vsftpd"), translate("vsftpd is running"))
else
	m = Map("vsftpd", translate("vsftpd"), translate("vsftpd is not running"))
end

s = m:section(TypedSection, "vsftpd", "")
s.anonymous = true

switch = s:option(Flag, "enabled", translate("Enable"))
switch.rmempty = false

editconf = s:option(Value, "_data", " ")
editconf.template = "cbi/tvalue"
editconf.rows = 25
editconf.wrap = "off"

function editconf.cfgvalue(self, section)
	return fs.readfile("/etc/vsftpd.conf") or ""
end
function editconf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/vsftpd.conf", value)
		if (luci.sys.call("cmp -s /tmp/vsftpd.conf /etc/vsftpd.conf") == 1) then
			fs.writefile("/etc/vsftpd.conf", value)
		end
		fs.remove("/tmp/vsftpd.conf")
	end
end

return m
