-- Copyright 2020 muink <https://github.com/muink>
-- Licensed to the public under the Apache License 2.0

module("luci.controller.change-mac", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/change-mac") then
		return
	end

--	entry({"admin", "network", "change-mac"}, firstchild(), _("MAC address randomizer"), 11).dependent = false
--	entry({"admin", "network", "change-mac", "dashboard"}, cbi("change-mac"), _("Dashboard"), 1)
	entry({"admin", "network", "change-mac"}, cbi("change-mac"), _("MAC address randomizer"), 11).dependent = false

end


