define('event', [], function() {
	function addEvent(el, eventName, command, named) {
		var named = named || 'undefined';
		el['_event'] = el['_event'] || {};
		el['_event'][eventName] = el['_event'][eventName] || {};
		el['_event'][eventName][named] = el['_event'][eventName][named] || [];
		el['_event'][eventName][named].push(command);
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

	return {
		addEvent : function(el, eventName, command, named) {
			if (el.addEventListener) {
				el.addEventListener(eventName, command);
				addEvent(el, eventName, command, named);
			} else {
				var newCommand = function() {
					return command.apply(el, arguments);
				};
				el.attachEvent("on" + eventName, newCommand);
				addEvent(el, eventName, newCommand, named);
			}
		},
		removeEvent : function(el, eventName, named) {
			var commands = eventsCommandsFor(el, eventName, named);
			for (var i = 0; i < commands.length; i++) {
				if (el.removeEventListener) {
					el.removeEventListener(eventName, commands[i]);
				} else {
					el.detachEvent('on' + eventName, commands[i]);
				}
			}
			removeEvent(el, eventName, named);
		}
	}
});
