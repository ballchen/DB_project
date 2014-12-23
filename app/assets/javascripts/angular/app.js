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
