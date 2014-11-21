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
  // Default values
  $scope.visible_ont_count = 0;
  $scope.ontology_sort_order = "-popularity";

  // Data transfer from Rails
  $scope.debug = jQuery(document).data().bp.development;
  $scope.admin = jQuery(document).data().bp.admin;
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

  // Default setup for facets
  $scope.facets = {
    types: ["ontology"],
    formats: [],
    groups: [],
    categories: [],
    artifacts: []
  }

  // Default values for facets that aren't definied on the ontologies
  $scope.types = {
    ontology: {enabled: true, count: 0, sort: 1, id: "ontology"},
    ontology_view: {enabled: true, count: 0, sort: 2, id: "ontology_view"},
    CIMI_model: {enabled: false, count: 0, sort: 3, id: "CIMI_model"},
    NLM_value_set: {enabled: false, count: 0, sort: 4, id: "NLM_value_set"}
  };
  $scope.artifacts = ["notes", "reviews", "projects"];

  // Functions for determining whether or not a particular filter applies to a given ontology
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
  // All facets are basically ANDed together and return true if no options under the facet are selected.
  $scope.$watch('facets', function() {
    var key, i, ontology, count = 0;

    // Reset type counts
    Object.keys($scope.types).forEach(function(key) {
      $scope.types[key].count = 0;
    });

    // Filter ontologies
    for (i = 0; i < $scope.ontologies.length; i++) {
      ontology = $scope.ontologies[i];

      // Filter out ontologies based on their filter functions
      ontology.show = Object.keys($scope.facets.filters).map(function(key){
        return $scope.facets.filters[key](ontology);
      }).every(Boolean);

      if (ontology.show) {
        count++;
        $scope.types[ontology.type].count++;
      }
    }
    $scope.visible_ont_count = count;
  }, true);

  var intersection = function(x, y) {
    if (typeof x === 'undefined' || typeof y === 'undefined') {return [];}
    var ret = [];
    for (var i = 0; i < x.length; i++) {
      for (var z = 0; z < y.length; z++) {
        if (x[i] == y[z]) {
          ret.push(i);
          break;
        }
      }
    }
    return ret;
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
})

.filter('humanShortNum', function() {
  return function(input) {
    if (input) {
      var num = parseInt(input);
      if (num < 10000) {return num;}
      if (num > 10000 && num < 1000000) {
        return String(+(Math.round(num / 1000 + "e+1")  + "e-1")) + "k"
      }
      if (num > 1000000) {
        return String(+(Math.round(num / 100000 + "e+1")  + "e-1")) + "M"
      }
      return newInput.join(" ");
    }
  };
})

.filter("toArray", function(){
  return function(obj) {
    var result = [];
    angular.forEach(obj, function(val, key) {
      result.push(val);
    });
    return result;
  };
})
;