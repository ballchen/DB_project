"format global";"deps angular";"deps moment";!function(){"use strict";function a(a,b){return a.module("angularMoment",[]).constant("angularMomentConfig",{preprocess:null,timezone:"",format:null,statefulFilters:!0}).constant("moment",b).constant("amTimeAgoConfig",{withoutSuffix:!1,serverTime:null,titleFormat:null}).directive("amTimeAgo",["$window","moment","amMoment","amTimeAgoConfig","angularMomentConfig",function(b,c,d,e,f){return function(g,h,i){function j(){var a;if(e.serverTime){var b=(new Date).getTime(),d=b-u+e.serverTime;a=c(d)}else a=c();return a}function k(){q&&(b.clearTimeout(q),q=null)}function l(a){if(h.text(a.from(j(),s)),t&&!h.attr("title")&&h.attr("title",a.local().format(t)),!x){var c=Math.abs(j().diff(a,"minute")),d=3600;1>c?d=1:60>c?d=30:180>c&&(d=300),q=b.setTimeout(function(){l(a)},1e3*d)}}function m(a){y&&h.attr("datetime",a)}function n(){if(k(),o){var a=d.preprocessDate(o,v,r);l(a),m(a.toISOString())}}var o,p,q=null,r=f.format,s=e.withoutSuffix,t=e.titleFormat,u=(new Date).getTime(),v=f.preprocess,w=i.amTimeAgo.replace(/^::/,""),x=0===i.amTimeAgo.indexOf("::"),y="TIME"===h[0].nodeName.toUpperCase();p=g.$watch(w,function(a){return"undefined"==typeof a||null===a||""===a?(k(),void(o&&(h.text(""),m(""),o=null))):(o=a,n(),void(void 0!==a&&x&&p()))}),a.isDefined(i.amWithoutSuffix)&&g.$watch(i.amWithoutSuffix,function(a){"boolean"==typeof a?(s=a,n()):s=e.withoutSuffix}),i.$observe("amFormat",function(a){"undefined"!=typeof a&&(r=a,n())}),i.$observe("amPreprocess",function(a){v=a,n()}),g.$on("$destroy",function(){k()}),g.$on("amMoment:localeChanged",function(){n()})}}]).service("amMoment",["moment","$rootScope","$log","angularMomentConfig",function(b,c,d,e){var f=this;this.preprocessors={utc:b.utc,unix:b.unix},this.changeLocale=function(d){var e=(b.locale||b.lang)(d);return a.isDefined(d)&&(c.$broadcast("amMoment:localeChanged"),c.$broadcast("amMoment:languageChange")),e},this.changeLanguage=function(a){return d.warn("angular-moment: Usage of amMoment.changeLanguage() is deprecated. Please use changeLocale()"),f.changeLocale(a)},this.preprocessDate=function(c,f,g){return a.isUndefined(f)&&(f=e.preprocess),this.preprocessors[f]?this.preprocessors[f](c,g):(f&&d.warn("angular-moment: Ignoring unsupported value for preprocess: "+f),!isNaN(parseFloat(c))&&isFinite(c)?b(parseInt(c,10)):b(c,g))},this.applyTimezone=function(a){var b=e.timezone;return a&&b&&(a.tz?a=a.tz(b):d.warn("angular-moment: timezone specified but moment.tz() is undefined. Did you forget to include moment-timezone.js?")),a}}]).filter("amCalendar",["moment","amMoment","angularMomentConfig",function(a,b,c){function d(c,d){if("undefined"==typeof c||null===c)return"";c=b.preprocessDate(c,d);var e=a(c);return e.isValid()?b.applyTimezone(e).calendar():""}return d.$stateful=c.statefulFilters,d}]).filter("amDateFormat",["moment","amMoment","angularMomentConfig",function(a,b,c){function d(c,d,e){if("undefined"==typeof c||null===c)return"";c=b.preprocessDate(c,e);var f=a(c);return f.isValid()?b.applyTimezone(f).format(d):""}return d.$stateful=c.statefulFilters,d}]).filter("amDurationFormat",["moment","angularMomentConfig",function(a,b){function c(b,c,d){return"undefined"==typeof b||null===b?"":a.duration(b,c).humanize(d)}return c.$stateful=b.statefulFilters,c}]).filter("amTimeAgo",["moment","amMoment","angularMomentConfig",function(a,b,c){function d(c,d,e){if("undefined"==typeof c||null===c)return"";c=b.preprocessDate(c,d);var f=a(c);return f.isValid()?b.applyTimezone(f).fromNow(e):""}return d.$stateful=c.statefulFilters,d}])}"function"==typeof define&&define.amd?define("angular-moment",["angular","moment"],a):"undefined"!=typeof module&&module&&module.exports?a(angular,require("moment")):a(angular,window.moment)}();
angular.module('app', [
  'ui.bootstrap',
  'ui.select2',
  'angular-underscore',
  'highcharts-ng',
  'angularMoment',

  'map',
  'chart',
  'event',
  'app.controller'
  ])
.run(function(amMoment) {
    amMoment.changeLocale('zh-tw');
})
.constant('angularMomentConfig', {
    preprocess: 'unix', // optional
    timezone: 'Asia/Taipei' // optional
});
angular.module('chart', [
  'chart.controller'
  ]);


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
;
angular.module('app.controller', [])
  .controller("index", [
    '$scope',
    function(
      $scope
    ) {
      console.log('index')
    }
  ])
;
angular.module('event', [
  'event.controller'
  ]);


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
      $http.get('/api/events').success(function(data, status, headers, config) {
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
      })
    }
  ])
;
angular.module('map', [
  'map.controller'
  ]);


angular.module('map.controller', [])
  .controller("map", [
    '$scope',
    '$http',
    '$window',
    function(
      $scope,
      $http,
      $window
    ) {
      console.log('map')
      var handler = Gmaps.build('Google', {
        markers: {
          clusterer: undefined
        }
      });
      var markers;
      $http({
        method: "GET",
        url: "/api/places"
      }).success(function(data, status, headers, config) {
        $scope.places = data;
        var location_item;
        var markerInfos = _.map($scope.places, function(place) {
          location_item = place.location
          var street = (location_item.street!==null)? location_item.street: ""
          var city =(location_item.city!==null)? location_item.city: ""
          var country = (location_item.country!==null)? location_item.country: ""
          var where = (street+" "+ city +" "+ country)? street+" "+ city +" "+ country: ""
          var info = "<h3>" + place.name + "</h3>" + "<p>" + where + "</p>"
          _.each(place.tagged_user,function(user){
            info = info + '<img width="200" src="'+ user.user.pic+ '">' + '<h4>'+user.user.name+'</h4>'
          })
          return {
            "infowindow": info,
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
;
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//

;
