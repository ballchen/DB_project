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
        $scope.places = data;
        console.log(data)
        var location_item;
        var markerInfos = _.map($scope.places, function(place) {
          location_item = place.location
          var street = (location_item.street!==null)? location_item.street: ""
          var city =(location_item.city!==null)? location_item.city: ""
          var country = (location_item.country!==null)? location_item.country: ""
          var where = (street+" "+ city +" "+ country)? street+" "+ city +" "+ country: ""
          console.log(place.name)
          return {
            "infowindow": "<h3>" + place.name + "</h3>" + "<p>" + where + "</p>",
            "picture": {
              url: location_item.image_url,
              width: 36,
              height: 36
            },
            "lat": (location_item.latitude) ? (location_item.latitude) : (26.0 + location_item.id * 0.001),
            "lng": (location_item.longitude) ? (location_item.longitude) : (123.0 + location_item.id * 0.001),
            "id": location_item.id
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
              $scope.location = _.find($scope.places, function(location) {
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
