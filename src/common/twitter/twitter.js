/**
 * Twitter Service
 *
 * Handles authorization (through OAuth.io), fetching
 * 	details for the current user, and fetching a list
 * 	of friends.
 *
 * We'll need to support more complicated Twitter API
 * 	interactions, so most of that will probably
 * 	need to be located elsewhere.
 */
angular.module('common.twitter', [
	'common.cache'
]).factory('twitterService', function($q, cacheService) {

	var authorizationResult = false;
	var listeners = {
		ready: []
	};

	var publish = function (event, data) {
		listeners[event].forEach(function (cbk) {
			cbk(data);
		});
	};

	return {
		initialize: function() {
			OAuth.initialize('K7fLOqzxZpGs6BJeSikeQFoSlbc', {cache:true});
			authorizationResult = OAuth.create('twitter');
			if (authorizationResult) {
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
			return cacheService.bind('current-user', function (deferred) {
				authorizationResult.get('/1.1/account/verify_credentials.json').done(function (data) {
					deferred.resolve(data);
				});
			});
		},
		getFriends: function () {
			return cacheService.bind('all-friends', function (deferred) {
				authorizationResult.get('/1.1/friends/list.json').done(function (data) {
					deferred.resolve(data);
				});
			});
		}
	};    
});
