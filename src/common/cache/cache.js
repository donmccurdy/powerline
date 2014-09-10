/**
 * Cache Service
 *
 * Basic implementation of an in-memory + LocalStorage cache.
 *
 * TODO This is a pretty naïve approach. A production-ready
 * 	implementation will probably need to involve expiration
 * 	times and clear functions.
 */
angular.module('common.cache', []).factory('cacheService', function($q) {
	return {
		cache: {},
		get: function (key) {
			var json;
			if (this.cache[key]) {
				return this.cache[key];
			} else if ((json = localStorage.getItem(key))) {
				return JSON.parse(json);
			}
			return null;
		},
		set: function (key, value) {
			this.cache[key] = value;
			localStorage.setItem(key, JSON.stringify(value));
		},
		bind: function (key, fetch) {
			var cache = this,
				deferred = $q.defer(),
				data = this.get(key);
			if (data) {
				deferred.resolve(data);
			} else {
				fetch(deferred);
				deferred.promise.then(function (data) {
					cache.set(key, data);
				});
			}
			return deferred.promise;
		}
	};  
});
