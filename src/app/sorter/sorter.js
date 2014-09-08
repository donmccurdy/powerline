angular.module( 'app.sorter', [
	'app.services'
])

.controller('SorterController', function SorterController ($scope, twitterService) {
	var self = this;

	self.followers = [];
	self.following = [];
	self.friends = [];
	self.lists = [];

	self.targets = [
		{source: 'following'},
		{source: 'following', ui: true},
		{source: 'following'}
	];
	self.focused = self.targets[1];
	
	var init = function () {
		// todo
	};

	$scope.$on('keydown', function ($e, e) {
		if (self.focused && [37, 38, 39, 40].indexOf(e.keyCode) >= 0) {
			e.preventDefault();
			$scope.$apply(function () {
				self.focused.trigger(e);
			});
		}
	});




	if (twitterService.isReady()) {
		init();
	} else {
		twitterService.on('ready', init);
	}

	self.move = function (source, direction, uid) {

	};

	self.focus = function (target) {
		self.focused = target;
		self.targets.forEach(function (other) {
			if (other !== self.focused) {
				other.ctrl.blur();
			}
		});
	};
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