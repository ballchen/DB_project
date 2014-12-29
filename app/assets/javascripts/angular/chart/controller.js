angular.module('chart.controller', [])
  .controller("chart", [
    '$scope',
    '$http',
    '$window',
    function(
      $scope,
      $http,
      $window
    ) {
      console.log('chart')
      var url = "/api/all/likes"
      $scope.all = false
      if($window.location.pathname==='/charts'){
        $scope.all =true
      }
      $http.get('/api/get_current_user').success(function(data, status, headers, config) {
        $scope.current_user_id = data
        if(!$scope.all){
          url = "/api/likes/" + $scope.current_user_id
        }
        $http({
          method: "GET",
          url: url
        }).success(function(data, status, headers, config) {
          var doughnutData = [];
          var cate;
          var index;
          var colorArray = ["#637b85","#2c9c69","#dbba34","#c62f29","#F38630","#E0E4CC","#69D2E7", '#003399','#3366AA','#FFD700','#FF4500','#FFFF00']
          _.each(data,function(like){
            cate = _.findWhere(doughnutData, {label: like.category})
            if( cate !== undefined){
              index = _.indexOf(doughnutData,cate)
              doughnutData[index].value = doughnutData[index].value+1;
            }else{
              doughnutData.push({
                label: like.category,
                value: 1,
                color: colorArray[doughnutData.length%colorArray.length]
              })
            }
          })
          var ctx = document.getElementById("chart-area").getContext("2d");
          window.myDoughnut = new Chart(ctx).Doughnut(doughnutData, {responsive : true});
        })
      })
    }
  ])
