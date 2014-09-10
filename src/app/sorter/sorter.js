angular.module( 'app.sorter', [
	'common.twitter'
])

.controller('SorterController', function SorterController ($scope, twitterService) {
	var self = this;

	self.followers = [];
	self.following = [];
	self.friends = [];
	self.lists = [];

	self.targets = [
		{id: 0, name: 'Left', source: ''},
		{id: 1, name: 'Following', source: 'following', ui: true},
		{id: 2, name: 'Right', source: ''}
	];
	self.focused = self.targets[1];
	
	var init = function () {
		// todo
	};

	if (twitterService.isReady()) {
		init();
	} else {
		twitterService.on('ready', init);
	}

	/**
	 * Moves a user from the source to the next list
	 *	in the given direction.
	 *	@param int list_id
	 * 	@param int direction (+/-1 for right/left)
	 * 	@param object user
	 * 	@return boolean success
	 */
	self.move = function (source, direction, user) {
		var target = self.targets[source + direction],
			ctrl = target.ctrl;
		if (ctrl) {
			ctrl.addUser(user);
			return true;
		}
		return false;
	};

	self.focus = function (target) {
		self.focused = target;
		self.targets.forEach(function (other) {
			if (other !== self.focused) {
				other.ctrl.blur();
			}
		});
	};

	//////////////////// Keypress Delegation
	$scope.$on('keydown', function ($e, e) {
		if (self.focused && [37, 38, 39, 40].indexOf(e.keyCode) >= 0) {
			e.preventDefault();
			$scope.$apply(function () {
				self.focused.trigger(e);
			});
		}
	});
})

.directive('sorterView', function SorterDirective () {
	return {
		restrict: 'E',
		controller: 'SorterController',
		controllerAs: 'sorter',
		templateUrl: 'sorter/sorter.tpl.html'
	};
})

;