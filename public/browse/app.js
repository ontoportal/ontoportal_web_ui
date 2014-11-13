'use strict';

// Declare app level module which depends on views, and components
angular.module('FacetedBrowsing', [
  'ngRoute',
  'FacetedBrowsing.view1',
  'FacetedBrowsing.view2',
  'FacetedBrowsing.version'
]).
config( ['$locationProvider', function ($locationProvider) {
  $locationProvider.html5Mode(true);
}])
;
