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
    types: {
      active: ["ontology"],
      ont_property: "type",
      filter: function(ontology) {
        if ($scope.facets.types.active.length == 0)
          return true;
        if ($scope.facets.types.active.indexOf(ontology.type) === -1)
          return false;
        return true;
      },
    },
    formats: {
      active: [],
      filter: function(ontology) {
        if ($scope.facets.formats.active.length == 0)
          return true;
        if ($scope.facets.formats.active.indexOf((ontology.submission || {}).hasOntologyLanguage) === -1)
          return false;
        return true;
      },
    },
    groups: {
      active: [],
      filter: function(ontology) {
        if ($scope.facets.groups.active.length == 0)
          return true;
        if (intersection($scope.facets.groups.active. ontology.groups).length === 0)
          return false;
        return true;
      },
    },
    categories: {
      active: [],
      filter: function(ontology) {
        if ($scope.facets.categories.active.length == 0)
          return true;
        if (intersection($scope.facets.categories.active, ontology.categories).length === 0)
          return false;
        return true;
      },
    },
    artifacts: {
      active: [],
      filter: function(ontology) {
        if ($scope.facets.artifacts.active.length == 0)
          return true;
        if (intersection($scope.facets.artifacts.active, ontology.artifacts).length === 0)
          return false;
        return true;
      },
    }
  }

  // Instantiate object counts
  // This doesn't happen on the facet itself because
  // there is a $watch directive and updating counts
  // on the facets causes an infinite loop.
  $scope.facet_counts = {};
  Object.keys($scope.facets).forEach(function(facet) {$scope.facet_counts[facet] = {}});

  // Default values for facets that aren't definied on the ontologies
  $scope.types = {
    ontology: {enabled: true, sort: 1, id: "ontology"},
    ontology_view: {enabled: true, sort: 2, id: "ontology_view"},
    CIMI_model: {enabled: false, sort: 3, id: "CIMI_model"},
    NLM_value_set: {enabled: false, sort: 4, id: "NLM_value_set"}
  };
  $scope.artifacts = ["notes", "reviews", "projects"];

  // This watches the facets and updates the list depending on which facets are selected
  // All facets are basically ANDed together and return true if no options under the facet are selected.
  $scope.$watch('facets', function() {
    var key, i, ontology, facet, facet_count, show, other_facets;
    $scope.visible_ont_count = 0;

    // Reset facet counts
    Object.keys($scope.facet_counts).forEach(function(key) {
      $scope.facet_counts[key] = {};
    });

    // Filter ontologies
    for (i = 0; i < $scope.ontologies.length; i++) {
      ontology = $scope.ontologies[i];

      // Filter out ontologies based on their filter functions
      ontology.show = Object.keys($scope.facets).map(function(key) {
        return $scope.facets[key].filter(ontology);
      }).every(Boolean);

      Object.keys($scope.facets).forEach(function(key) {
        facet = $scope.facets[key];
        other_facets = Object.keys($scope.facets).filter(function(f){return key != f});
        show = other_facets.map(function(other_facet){return $scope.facets[other_facet].filter(ontology)}).every(Boolean);
        if (show) {
          facet_count = $scope.facet_counts[key];
          facet_count[ontology[facet.ont_property]] = (facet_count[ontology[facet.ont_property]] || 0) + 1;
        }
      });

      if (ontology.show) {$scope.visible_ont_count++};
    }
    console.log($scope.facet_counts);
  }, true);

  var countAllInFacet = function(facet) {
    var active_facets = Object.keys($scope.facets).filter(function(facet) {return $scope.facets[facet].active.length > 0});
    if (active_facets.length == 0 || (active_facets.length == 1 && active_facets[0] == facet)) {
      return true;
    }
    return false;
  }

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