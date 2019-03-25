define('event', [], function() {
	function addEvent(el, eventName, command, named, opts) {
		var named = named || 'undefined';
		el['_event'] = el['_event'] || {};
		el['_event'][eventName] = el['_event'][eventName] || {};
		el['_event'][eventName][named] = el['_event'][eventName][named] || [];
		el['_event'][eventName][named].push({
			command: command,
			opts: opts,
		});
	}

	function removeEvent(el, eventName, named) {
		if (el['_event']) {
			if (named && el['_event'][eventName]) {
				el['_event'][eventName][named] = [];
			} else {
				el['_event'][eventName] = {};
			}
		}
	}

	function eventsCommandsFor(el, eventName, named) {
		if (named) {
			if (el['_event'] && el['_event'][eventName]) {
				return el['_event'][eventName][named] || [];
			}
			return [];
		}
		var commands = [];
		if (el['_event']) {
			for (key in el['_event'][eventName]) {
				commands = commands.concat(el['_event'][eventName][key]);
			}
		}
		return commands;
	}

	function supportsEventOptions() {
		var supportsPassive = false;
		try {
			var opts = Object.defineProperty({}, 'passive', {
				get: function() {
					supportsPassive = true;
				}
			});
			window.addEventListener('testPassive', null, opts);
			window.removeEventListener('testPassive', null, opts);
		} catch (e) {}

		return supportsPassive;
	}

	return {
		addEvent : function(el, eventName, command, namedOrConfigs) {
			var named, opts;
			if (typeof namedOrConfigs === 'string') {
				named = namedOrConfigs;
			} else if (typeof namedOrConfigs === 'object') {
				named = namedOrConfigs.named;
				opts = namedOrConfigs;
			}

			if (el.addEventListener) {
				if (typeof namedOrConfigs === 'object' && supportsEventOptions()) {
					el.addEventListener(eventName, command, namedOrConfigs);
					addEvent(el, eventName, command, named, opts);
				} else {
					el.addEventListener(eventName, command);
					addEvent(el, eventName, command, named);
				}
			} else {
				var newCommand = function() {
					return command.apply(el, arguments);
				};
				el.attachEvent('on' + eventName, newCommand);
				addEvent(el, eventName, newCommand, named);
			}
		},
		removeEvent : function(el, eventName, named) {
			var commands = eventsCommandsFor(el, eventName, named);
			for (var i = 0; i < commands.length; i++) {
				if (el.removeEventListener) {
					if (commands[i].opts) {
						el.removeEventListener(eventName, commands[i].command, commands[i].opts);
					} else {
						el.removeEventListener(eventName, commands[i].command);
					}
				} else {
					el.detachEvent('on' + eventName, commands[i].command);
				}
			}
			removeEvent(el, eventName, named);
		}
	}
});
