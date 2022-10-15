'use strict';
'require view';
'require uci';
'require form';
'require tools.widgets as widgets';

return view.extend({
//	handleSaveApply: null,
//	handleSave: null,
//	handleReset: null,

	render: function() {
		var m, s, o;

		m = new form.Map('change-mac', _('MAC address randomizer'),
			_('Assign a random MAC address to the designated interface on every time boot'));

		s = m.section(form.TypedSection, 'change-mac');
		s.anonymous = true;

		o = s.option(form.Flag, 'enabled', _('Enable MAC randomization'));
		o.rmempty = false;

		o = s.option(widgets.DeviceSelect, 'interface', _('Enabled interfaces'));
		o.multiple = true;
		o.noaliases = true;
		o.nobridges = true;
		o.nocreate = true;

		o = s.option(form.ListValue, 'random_mode', _('Multi-interface MAC random mode'));
		o.value('disorderly', _('Disorderly'));
		o.value('sequence', _('Sequence'));
		o.default = 'disorderly';
		o.rmempty = false;

		o = s.option(form.ListValue, 'mac_type', _('MAC address type'),
			_("Use command 'rgmac --help' to get more information"));
		o.value('locally', _('Locally administered address'));
		o.value('specific', _('Specify OUI'));
		o.value('vendor', _('Vendor name'));
		o.default = 'locally';
		o.rmempty = false;

		o = s.option(form.Value, 'mac_type_specific', _('Specify OUI'));
		o.placeholder = '74:D0:2B';
		//o.depends('mac_type', 'specific');
		o.rmempty = false;

		o = s.option(form.Value, 'mac_type_vendor', _('Vendor name'),
			_("Use command 'rgmac -lrouter' to get valid vendor name"));
		o.placeholder = 'router:Asus';
		//o.depends('mac_type', 'vendor');
		o.rmempty = false;

		o = s.option(form.Button, '_change_now', _('Change MAC now'));
		o.inputtitle = _('Change now');
		o.inputstyle = 'apply';
//	o.write = function()
//		//m.uci:save(conf)
//		m.uci:commit(conf)
//		m.uci:apply()
//
//		sys.call ('/etc/init.d/change-mac start')
//	end

		o = s.option(form.Button, '_restore_sel', _('Restore selected interfaces'));
		o.inputtitle = _('Restore');
		o.inputstyle = 'apply';
//	o.write = function()
//		//m.uci:save(conf)
//		m.uci:commit(conf)
//		m.uci:apply()
//
//		sys.call ('/etc/init.d/change-mac restore')
//	end

		o = s.option(form.Button, '_save_apply', _('Save & Apply'));
		o.inputtitle = _('Save & Apply');
		o.inputstyle = 'apply';
//	o.write = function()
//		//m.uci:save(conf)
//		m.uci:commit(conf)
//		m.uci:apply()
//
//		if tostring(util.trim(sys.exec('uci get ' .. conf .. typeds .. 'enabled'))) == '1' then sys.call ('/etc/init.d/change-mac enable');
//		else sys.call ('/etc/init.d/change-mac disable'); end
//	end

		return m.render();
	}
});
