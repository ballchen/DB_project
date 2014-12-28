angular.module('event.controller', [])
  .controller("event", [
    '$scope',
    '$http',
    '$window',
    function(
      $scope,
      $http,
      $window
    ) {
      console.log('event')
      $http.get('/api/get_current_user').success(function(data, status, headers, config) {
        $scope.current_user_id = data
        $http.get('/api/events/'+$scope.current_user_id).success(function(data, status, headers, config) {
          $scope.years = []
          var year
          var event_year
          _.each(data,function(event){
            if(event.start_time!==null){
              event_year= moment(event.start_time).format('YYYY')
              year = _.findWhere($scope.years, {year: event_year})
              if( year !== undefined){
                index = _.indexOf($scope.years,year)
                $scope.years[index].events.push(event)
              }else{
                $scope.years.push({
                  year: event_year,
                  events: [event]
                })
              }
            }
          })
          $scope.years = _.sortBy($scope.years,function(year){
            return -year.year
          })
        })
      })
    }
  ])
