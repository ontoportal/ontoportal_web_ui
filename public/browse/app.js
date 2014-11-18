'use strict';

// Declare app level module which depends on views, and components
angular.module('FacetedBrowsing', [
  'ngRoute',
  'FacetedBrowsing.OntologyList'
]).
config( ['$locationProvider', function ($locationProvider) {
  $locationProvider.html5Mode(true);
}])
;

var app = angular.module('FacetedBrowsing.OntologyList', ["checklist-model"])

.controller('OntologyList', ['$scope', function($scope) {
  $scope.debug = jQuery(document).data().bp.development;
  $scope.admin = jQuery(document).data().bp.admin;
  $scope.visible_ont_count = 0;
  $scope.facets = {
    types: ["ontology"],
    formats: [],
    groups: [],
    categories: [],
    artifacts: []
  }
  $scope.types = ["ontology", "ontology_view"];
  $scope.artifacts = ["notes", "reviews", "projects"];
  $scope.ontologies = jQuery(document).data().bp.ontologies;
  $scope.formats = jQuery(document).data().bp.formats.sort();
  $scope.categories = jQuery(document).data().bp.categories.sort(function(a, b){
    if (a.name < b.name) return -1;
    if (a.name > b.name) return 1;
    return 0;
  });
  $scope.groups = jQuery(document).data().bp.groups.sort(function(a, b){
    if (a.acronym < b.acronym) return -1;
    if (a.acronym > b.acronym) return 1;
    return 0;
  });

  $scope.facets.filters = {
    types: function(ontology) {
      if ($scope.facets.types.length == 0)
        return true;
      if ($scope.facets.types.indexOf(ontology.type) === -1)
        return false;
      return true;
    },
    formats: function(ontology) {
      if ($scope.facets.formats.length == 0)
        return true;
      if ($scope.facets.formats.indexOf((ontology.submission || {}).hasOntologyLanguage) === -1)
        return false;
      return true;
    },
    groups: function(ontology) {
      if ($scope.facets.groups.length == 0)
        return true;
      console.log(ontology.groups)
      if (intersection($scope.facets.groups, ontology.groups).length === 0)
        return false;
      return true;
    },
    categories: function(ontology) {
      if ($scope.facets.categories.length == 0)
        return true;
      if (intersection($scope.facets.categories, ontology.categories).length === 0)
        return false;
      return true;
    },
    artifacts: function(ontology) {
      if ($scope.facets.artifacts.length == 0)
        return true;
      if (intersection($scope.facets.artifacts, ontology.artifacts).length === 0)
        return false;
      return true;
    }
  }

  // This watches the facets and updates the list depending on which facets are selected
  // The facets cascade
  $scope.$watch('facets', function() {
    var ontology, count = 0;
    for (var i = 0; i < $scope.ontologies.length; i++) {
      ontology = $scope.ontologies[i];

      // Filter out ontologies based on their filter functions
      ontology.show = Object.keys($scope.facets.filters).map(function(key){
        return $scope.facets.filters[key](ontology);
      }).every(Boolean);

      if (ontology.show) {count++;}
    }
    $scope.visible_ont_count = count;
  }, true);

  var intersection = function(a, b) {
    if (typeof a === 'undefined' || typeof b === 'undefined') {return [];}
    var ai = 0, bi = 0;
    var result = [];

    while (ai < a.length && bi < b.length) {
      if      (a[ai] < b[bi] ){ ai++; }
      else if (a[ai] > b[bi] ){ bi++; }
      else {
        /* they're equal */
        result.push(ai);
        ai++;
        bi++;
      }
    }

    return result;
  }

}])

.filter('idToTitle', function() {
  return function(input) {
    if (input) {
      var splitInput = input.replace(/_/g, " ").split(" ");
      var newInput = [];
      var word;
      for (word in splitInput) {
        word = splitInput[word];
        if (word[0].toUpperCase() == word[0]) {
          newInput.push(word);
        } else {
          newInput.push(word[0].toUpperCase() + word.slice(1));
        }

      }
      return newInput.join(" ");
    }
  };
});