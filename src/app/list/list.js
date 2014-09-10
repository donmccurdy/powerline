angular.module( 'app.list', [
	'common.twitter'
])

.controller('ListController', function ListController ($scope, twitterService) {
	var self = this;

	self.name = $scope.spec.name;
	self.ui = $scope.spec.ui;
	self.id = $scope.spec.id;
	self.users = [];
	self.selected = -1;
	self.hasFocus = false;
	
	var source = $scope.spec.source;
	var next_cursor = 0;
	var previous_cursor = 0;

	var sorter = $scope.sorter;
	
	var init = function () {
		if (source === 'following') {
			twitterService.getFriends().then(function (data) {
				self.users = data.users;
				next_cursor = data.next_cursor;
				previous_cursor = data.previous_cursor;
			});
		} else {
			// TODO other things
		}
	};

	if (twitterService.isReady()) {
		init();
	} else {
		twitterService.on('ready', init);
	}

	/**
	 * Focuses the current controller, if it isn't
	 * 	already, and selects the user at the given index.
	 * @param  {int} index
	 */
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

	/**
	 * Informs this controller that focus has been lost.
	 */
	self.blur = function () {
		self.selected = -1;
		self.hasFocus = false;
	};

	/**
	 * Add a user to this list.
	 * @param {object} user
	 */
	self.addUser = function (user) {
		self.users.push(user);
	};

	/**
	 * Remove a user, specified by index, from
	 * 	this list.
	 * @param  {int} index
	 * @return {object} user
	 */
	self.removeUser = function (index) {
		if (self.users[index]) {
			return self.users.splice(index, 1)[0];
		}
	};

	/**
	 * Move user at the specified index
	 * in a given direction.
	 * @param  {int} index 
	 * @param  {int} direction (+/-1 for right/left)
	 */
	self.moveUser = function (index, direction) {
		var user = self.getUser(index);
		if (user && sorter.move(self.id, direction, user)) {
			self.removeUser(index);
		}
	};

	/**
	 * Retrieve the user at the given index.
	 * @param  {int} index
	 * @return {object}
	 */
	self.getUser = function (index) {
		return self.users[index];
	};

	/**
	 * Sort the list in a given direction,
	 * according to some property.
	 * @param  {enum} property
	 * @param  {int} direction
	 */
	self.sort = function (property, direction) {

	};

	/**
	 * Local keybindings for this list.
	 * @param  {KeyEvent} event
	 */
	self.trigger = function (event) {
		switch (event.keyCode) {
			case 37: // LEFT
				return self.moveUser(self.selected, -1);
			case 38: // UP
				return self.select(self.selected - 1);
			case 39: // RIGHT
				return self.moveUser(self.selected, 1);
			case 40: // DOWN
				return self.select(self.selected + 1);
		}
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