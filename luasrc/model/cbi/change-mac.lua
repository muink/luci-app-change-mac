-- Copyright 2020 muink <https://github.com/muink>
-- Licensed to the public under the MIT License

local uci	= require "luci.model.uci".cursor()
local fs	= require("nixio.fs")
local sys	= require("luci.sys")
local util	= require("luci.util")
local packageName = "change-mac"
local conf = packageName
local typeds = ".@change-mac[0]."
local config = "/etc/config/" .. conf


m = Map(conf, translate("MAC address randomizer"), translate("Assign a random MAC address to the designated interface on every time boot"))
m.pageaction = false



local _enable
local _crontb
local _iflist
local _ramode
local _matype
local _matype_specific
local _matype_vendor

function getuci()
	_enable = tostring(util.trim(sys.exec("uci get " .. conf .. typeds .. "enabled")))
	_crontb = tostring(util.trim(sys.exec("sed -n '/@reboot \\\/usr\\\/sbin\\\/change-mac.sh/p' /etc/crontabs/root")))
	_iflist = tostring(util.trim(sys.exec("uci get " .. conf .. typeds .. "interface")))
	_ramode = tostring(util.trim(sys.exec("uci get " .. conf .. typeds .. "random_mode")))
	if _ramode == "disorderly" then _ramode = ""; elseif _ramode == "sequence" then _ramode = " -e"; else _ramode = ""; end
	_matype = tostring(util.trim(sys.exec("uci get " .. conf .. typeds .. "mac_type")))
	_matype_specific = tostring(util.trim(sys.exec("uci get " .. conf .. typeds .. "mac_type_specific")))
	_matype_vendor = tostring(util.trim(sys.exec("uci get " .. conf .. typeds .. "mac_type_vendor")))
	if _matype == "locally" then _matype = ""; elseif _matype == "specific" then _matype = " -t" .. _matype_specific; elseif _matype == "vendor" then _matype = " -t" .. _matype_vendor; else _matype = ""; end
end

getuci()

s = m:section(TypedSection, "change-mac")
s.anonymous = true

enabled = s:option(Flag, "enabled", translate("Enable MAC randomization"))
enabled.rmempty = false

interface = s:option(DynamicList, "interface", translate("Enabled interfaces"))
interface.template = "cbi/network_ifacelist"
interface.nobridges = true
interface.noaliases = true
interface.rmempty = false
--interface.network = arg[1]
interface.widget = "checkbox"

save_apply = s:option(Button, "_save_apply", translate("Save & Apply"))
save_apply.inputtitle = translate("Save & Apply")
save_apply.inputstyle = "apply"
save_apply.write = function()
	--m.uci:save(conf)
	m.uci:commit(conf)
	m.uci:apply()
	getuci()

	if _enable == "0" then sys.call ("sed -i '/@reboot \\\/usr\\\/sbin\\\/change-mac.sh/d' /etc/crontabs/root"); end
	if _enable == "1" then
		sys.call ("sed -i '/@reboot \\\/usr\\\/sbin\\\/change-mac.sh/d' /etc/crontabs/root")
		sys.call ("sed -i '1i @reboot \\\/usr\\\/sbin\\\/change-mac.sh" .. _ramode .. _matype .. " " .. _iflist .. "' /etc/crontabs/root")
	end
end

change_now = s:option(Button, "_change_now", translate("Change MAC now"))
change_now.inputtitle = translate("Change MAC now")
change_now.inputstyle = "apply"
change_now.write = function()
	--m.uci:save(conf)
	m.uci:commit(conf)
	m.uci:apply()
	getuci()

	sys.call ("/usr/sbin/change-mac.sh" .. _ramode .. _matype .. " " .. _iflist)
end


random_mode = s:option(ListValue, "random_mode", translate("Multi-interface MAC random mode"))
random_mode:value("disorderly", translate("Disorderly"))
random_mode:value("sequence", translate("Sequence"))
random_mode.default = "disorderly"
random_mode.rmempty = false

mac_type = s:option(ListValue, "mac_type", translate("MAC address type"),
	translate("Use command 'rgmac --help' to get more information"))
mac_type:value("locally", translate("Locally administered address"))
mac_type:value("specific", translate("Specify OUI"))
mac_type:value("vendor", translate("Vendor name"))
mac_type.default = "locally"
mac_type.rmempty = false

mac_type_specific = s:option(Value, "mac_type_specific", translate("Specify OUI"))
mac_type_specific.placeholder = "20:CF:30"
--mac_type_specific:depends("mac_type", "specific")
mac_type_specific.rmempty = false

mac_type_vendor = s:option(Value, "mac_type_vendor", translate("Vendor name"),
	translate("Use command 'rgmac -lrouter' to get valid vendor name"))
mac_type_vendor.placeholder = "router:Asus"
--mac_type_vendor:depends("mac_type", "vendor")
mac_type_vendor.rmempty = false


return m
