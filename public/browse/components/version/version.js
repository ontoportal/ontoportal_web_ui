'use strict';

angular.module('FacetedBrowsing.version', [
  'FacetedBrowsing.version.interpolate-filter',
  'FacetedBrowsing.version.version-directive'
])

.value('version', '0.1');
