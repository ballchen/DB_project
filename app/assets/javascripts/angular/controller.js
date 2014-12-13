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
      var handler = Gmaps.build('Google', {
        markers: {
          clusterer: undefined
        }
      });
      var markers;

      $http({
        method: "GET",
        url: "/api/locations"
      }).success(function(data, status, headers, config) {
        $scope.locations = data;
        var markerInfos = _.map($scope.locations, function(location) {
          return {
            //"infowindow": "<h3>" + location.name + "</h3>" + '<img src="' + location.image_url + '" style="width:100px;height:75px;">' + "<p>" + location.abstract + "</p>",
            "picture": {
              url: location.image_url,
              width: 36,
              height: 36
            },
            "lat": (location.latitude) ? (location.latitude) : (26.0 + location.id * 0.001),
            "lng": (location.longitude) ? (location.longitude) : (123.0 + location.id * 0.001),
            "id": location.id
          };
        })
        handler.buildMap({
          provider: {},
          internal: {
            id: 'map'
          }
        }, function() {
          markers = markerInfos.map(function(m) {
            var marker = handler.addMarker(m);
            marker.serviceObject.id = m.id;

            google.maps.event.addListener(marker.serviceObject, 'click', function() {
              $scope.location = _.find($scope.locations, function(location) {
                return location.id == marker.serviceObject.id
              });
              $scope.$apply();
            });
            return marker;
          });

          handler.bounds.extendWith(markers);
          handler.fitMapToBounds();
        });
      })
    }
  ])
