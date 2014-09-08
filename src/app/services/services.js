/**
 * Twitter Service
 */
angular.module('app.services', []).factory('twitterService', function($q) {

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
			var deferred = $q.defer();
			authorizationResult.get('/1.1/account/verify_credentials.json').done(function (data) {
				console.log(data);
				deferred.resolve(data);
			});
			return deferred.promise;
		},
		getFriends: function () {
			var key = 'all-friends-because-testing';
			var deferred = $q.defer();
			var data = localStorage.getItem(key);

			if (data && (data = JSON.parse(data))) {
				deferred.resolve(data);
			} else {
				authorizationResult.get('/1.1/friends/list.json').done(function (data) {
					deferred.resolve(data);
					localStorage.setItem(key, JSON.stringify(data));
				});
			}	

			return deferred.promise;
		}
	};    
});
