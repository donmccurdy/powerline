/**
 * Twitter Service
 */
angular.module('common.twitter', []).factory('twitterService', function($q) {

	var authorizationResult = false;
	var listeners = {
		ready: []
	};

	var publish = function (event, data) {
		listeners[event].forEach(function (cbk) {
			cbk(data);
		});
	};

	// Dead simple localStorage
	// TODO: this will need to be updated periodically.
	var cache = {
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

	return {
		initialize: function() {
			OAuth.initialize('K7fLOqzxZpGs6BJeSikeQFoSlbc', {cache:true});
			authorizationResult = OAuth.create('twitter');
			if (authorizationResult) {
				console.log(authorizationResult);
				publish('ready');
			}
		},
		isReady: function() {
			return (authorizationResult);
		},
		on: function (event, callback) {
			listeners[event].push(callback);
		},
		connectTwitter: function() {
			var deferred = $q.defer();
			OAuth.popup('twitter', {cache:true}, function(error, result) {
				if (error) {
					return;
				}
				authorizationResult = result;
				deferred.resolve();
				publish('ready');
			});
			return deferred.promise;
		},
		clearCache: function() {
			OAuth.clearCache('twitter');
			authorizationResult = false;
		},
		getCurrentUser: function () {
			return cache.bind('current-user', function (deferred) {
				authorizationResult.get('/1.1/account/verify_credentials.json').done(function (data) {
					deferred.resolve(data);
				});
			});
		},
		getFriends: function () {
			return cache.bind('all-friends', function (deferred) {
				authorizationResult.get('/1.1/friends/list.json').done(function (data) {
					deferred.resolve(data);
				});
			});
		}
	};    
});
