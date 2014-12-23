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
      $http({
        method: "GET",
        url: "/api/likes"
      }).success(function(data, status, headers, config) {
        var total_category = [];
        var cate;
        var index;
        _.each(data,function(like){
          cate = _.findWhere(total_category, {name: like.category})
          if( cate !== undefined){
            index = _.indexOf(total_category,cate)
            total_category[index].y = total_category[index].y+1;
          }else{
            total_category.push({
              name: like.category,
              y: 1
            })
          }
        })
        $scope.chartConfig = {
          options: {
              chart: {
                  type: 'pie'
              }
          },
          series: [{
              data: total_category
          }],
          title: {
              text: 'Hello'
          }
        }
      })
    }
  ])
