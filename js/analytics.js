if (typeof Object.assign != 'function') {
  Object.assign = function(target, varArgs) {
    'use strict';
    if (target == null) {
      throw new TypeError('Cannot convert undefined or null to object');
    }

    var to = Object(target);

    for (var index = 1; index < arguments.length; index++) {
      var nextSource = arguments[index];

      if (nextSource != null) {
        for (var nextKey in nextSource) {
          if (Object.prototype.hasOwnProperty.call(nextSource, nextKey)) {
            to[nextKey] = nextSource[nextKey];
          }
        }
      }
    }
    return to;
  };
}

// uuid function from https://gist.github.com/jed/982883
function uuid(a){return a?(a^Math.random()*16>>a/4).toString(16):([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g,uuid)}

window.ga = window.ga || function() {
  if (!ga.q) {
    ga.q = [];
  }
  ga.q.push(arguments);
};

var gaCode = document.body.dataset.gaCode;
ga('create', gaCode, 'auto');
ga('set', 'transport', 'beacon');

var dimensions = {
  CLIENT_ID: 'dimension1',
  WINDOW_ID: 'dimension2',
  HIT_ID: 'dimension3',
  HIT_TIME: 'dimension4',
  HIT_TYPE: 'dimension5',
};

var metrics = {
  RESPONSE_END_TIME: 'metric1',
  DOM_LOAD_TIME: 'metric2',
  WINDOW_LOAD_TIME: 'metric3',
};

ga(function(tracker) {
  if (tracker) {
    var clientId = tracker.get('clientId');
    tracker.set(dimensions.CLIENT_ID, clientId);
  }
});

ga('set', dimensions.WINDOW_ID, uuid());

ga(function(tracker) {
  var originalBuildHitTask = tracker.get('buildHitTask');
  tracker.set('buildHitTask', function(model) {
    model.set(dimensions.HIT_ID, uuid(), true);
    model.set(dimensions.HIT_TIME, String(+new Date), true);
    model.set(dimensions.HIT_TYPE, model.get('hitType'), true);
    originalBuildHitTask(model);
  });
});

var trackError = function(error, fieldsObj) {
  ga('send', 'event', Object.assign({
    eventCategory: 'Script',
    eventAction: 'error',
    eventLabel: (error && error.stack) || '(not set)',
    nonInteraction: true,
  }, fieldsObj));
};

var loadErrorEvents = window.__e && window.__e.q || [],
    fieldsObj = { eventAction: 'uncaught error' };

for (var i = 0; i < loadErrorEvents.length; i++) {
  var event = loadErrorEvents[i];
  trackError(event.error, fieldsObj);
}

window.addEventListener('error', function(event) {
  trackError(event.error, fieldsObj);
});

var sendNavigationTimingMetrics = function() {
  if (!(window.performance && window.performance.timing)) {
    return;
  }

  if (document.readyState !== 'complete') {
    window.addEventListener('load', sendNavigationTimingMetrics);
    return;
  }
  var performanceTiming = performance.timing,
      navStart = performanceTiming.navigationStart,
      responseEnd = Math.round(performanceTiming.responseEnd - navStart),
      domLoaded = Math.round(performanceTiming.domContentLoadedEventStart - navStart),
      windowLoaded = Math.round(performanceTiming.loadEventStart - navStart);

  var _valueIsValid = function(value) {
    return value > 0 && value < 1e6;
  };

  if (_valueIsValid(responseEnd) && _valueIsValid(domLoaded) && _valueIsValid(windowLoaded)) {
    var eventData = {
      eventCategory: 'Navigation Timing',
      eventAction: 'track',
      nonInteraction: true
    };

    eventData[metrics.RESPONSE_END_TIME] = responseEnd;
    eventData[metrics.DOM_LOAD_TIME] = domLoaded;
    eventData[metrics.WINDOW_LOAD_TIME] = windowLoaded;

    ga('send', 'event', eventData);
  }
};

sendNavigationTimingMetrics();

ga('send', 'pageview');
