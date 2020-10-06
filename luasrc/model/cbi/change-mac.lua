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



s = m:section(TypedSection, "change-mac")
s.anonymous = true

enabled = s:option(Flag, "enabled", translate("Enable MAC randomization"))
enabled.rmempty = false

network = s:option(DynamicList, "network", translate("Enabled interfaces"))
network.template = "cbi/network_netlist"
network.novirtual = true --not supported VLAN
network.rmempty = false
network.widget = "checkbox"

merge_physical = s:option(Flag, "merge_physical", translate("Merge the same physical interface"))
merge_physical.rmempty = false

restore_sel = s:option(Button, "_restore_sel", translate("Restore selected interfaces"))
restore_sel.inputtitle = translate("Restore selected interfaces")
restore_sel.inputstyle = "apply"
restore_sel.write = function()
	--m.uci:save(conf)
	m.uci:commit(conf)
	m.uci:apply()

	sys.call ("/etc/init.d/change-mac restore")
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
mac_type_specific.placeholder = "74:D0:2B"
--mac_type_specific:depends("mac_type", "specific")
mac_type_specific.rmempty = false

mac_type_vendor = s:option(Value, "mac_type_vendor", translate("Vendor name"),
	translate("Use command 'rgmac -lrouter' to get valid vendor name"))
mac_type_vendor.placeholder = "router:Asus"
--mac_type_vendor:depends("mac_type", "vendor")
mac_type_vendor.rmempty = false

change_now = s:option(Button, "_change_now", translate("Change MAC now"))
change_now.inputtitle = translate("Change MAC now")
change_now.inputstyle = "apply"
change_now.write = function()
	--m.uci:save(conf)
	m.uci:commit(conf)
	m.uci:apply()

	sys.call ("/etc/init.d/change-mac start")
end

save_apply = s:option(Button, "_save_apply", translate("Save & Apply"))
save_apply.inputtitle = translate("Save & Apply")
save_apply.inputstyle = "apply"
save_apply.write = function()
	--m.uci:save(conf)
	m.uci:commit(conf)
	m.uci:apply()

	if tostring(util.trim(sys.exec("uci get " .. conf .. typeds .. "enabled"))) == "1" then sys.call ("/etc/init.d/change-mac enable");
	else sys.call ("/etc/init.d/change-mac disable"); end
end


return m
