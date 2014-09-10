angular.module( 'app.list', [
	'common.twitter'
])

.controller('ListController', function ListController ($scope, twitterService) {
	var self = this;

	self.name = 'Following';
	self.ui = $scope.spec.ui;
	self.users = [];
	self.selected = -1;
	self.hasFocus = false;
	
	var source = $scope.spec.source;
	var next_cursor = 0;
	var previous_cursor = 0;

	var sorter = $scope.sorter;
	
	var init = function () {
		twitterService.getFriends().then(function (data) {
			self.users = data.users;
			next_cursor = data.next_cursor;
			previous_cursor = data.previous_cursor;
		});
	};

	if (twitterService.isReady()) {
		init();
	} else {
		twitterService.on('ready', init);
	}

	self.select = function (index) {
		if (!self.hasFocus) {
			sorter.focus(self);
		}
		if (index < 0) {
			index += self.users.length;
		} else if (index >= self.users.length) {
			index -= self.users.length; 
		}
		self.selected = index;
		self.hasFocus = true;
	};

	self.blur = function () {
		self.selected = -1;
		self.hasFocus = false;
	};

	self.trigger = function (event) {
		switch (event.keyCode) {
			case 37:
				// move left
				break;
			case 38: 
				self.select(self.selected - 1);
				break;
			case 39:
				// move right
				break;
			case 40:
				self.select(self.selected + 1);
				break;

		}
	};

	self.addUser = function (user) {

	};

	self.removeUser = function (user) {

	};

	self.getUser = function (user) {

	};

	$scope.spec.ctrl = self;
})

.directive('listView', function ListDirective () {
	return {
		restrict: 'E',
		scope: {
			sorter: '=sorter',
			spec: '=listSpec'
		},
		controller: 'ListController',
		controllerAs: 'list',
		templateUrl: 'list/list.tpl.html'
	};
})

;