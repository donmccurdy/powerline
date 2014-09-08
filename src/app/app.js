angular.module( 'app', [
  'templates-app',
  'templates-common',
  'app.home',
  'app.about',
  'app.list',
  'app.sorter',
  'app.services',
  'ui.router'
])

.config(function myAppConfig ($stateProvider, $urlRouterProvider) {
  $urlRouterProvider.otherwise( '/home' );
})

.run(function run () {})

.controller( 'AppCtrl', function AppCtrl ($scope, $q, twitterService) {
  // Router
  $scope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState, fromParams){
    if ( angular.isDefined( toState.data.pageTitle ) ) {
      $scope.pageTitle = toState.data.pageTitle + ' | TweetCupboard' ;
    }
  });

  var attemptInit = function () {
    $scope.logged_in = twitterService.isReady();
    if ($scope.logged_in) {
      twitterService.getCurrentUser().then(function (user) {
        $scope.user = user;
      });
    }
  };

  twitterService.initialize();

  // Connect
  $scope.connectButton = function () {
      twitterService.connectTwitter().then(attemptInit);
  };

  // Sign out
  $scope.signOut = function () {
      twitterService.clearCache();
      $scope.logged_in = false;
      $scope.user = {};
  };

  // Log in automatically, if possible
  attemptInit();
})

.directive('keypressEvents', [
  '$document',
  '$rootScope',
  function ($document, $rootScope) {
    return {
      restrict: 'A',
      link: function() {
        $document.bind('keydown', function(e) {
          $rootScope.$broadcast('keydown', e);
        });
      }
    };
  }
])

;

