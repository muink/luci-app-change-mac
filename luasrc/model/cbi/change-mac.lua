-- Copyright 2020 muink <https://github.com/muink>
-- Licensed to the public under the MIT License

local uci	= require "luci.model.uci".cursor()
local fs	= require("nixio.fs")
local sys	= require("luci.sys")
local util	= require("luci.util")
local packageName = "change-mac"
local conf = packageName
local config = "/etc/config/" .. conf


m = Map(conf, "MAC address randomizer", "Assign a random MAC address to the designated interface on every time boot")


s = m:section(TypedSection, "change-mac")
s.anonymous = true

genabled = s:option(Flag, "enabled", translate("Enable MAC randomization"))


return m
