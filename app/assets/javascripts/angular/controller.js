angular.module('app.controller', [])
  .controller("index", [
    '$scope',
    '$http',
    '$window',
    function(
      $scope,
      $http,
      $window
    ) {
      console.log('index')
    }
  ])
