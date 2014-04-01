// History and navigation management
( function( window, undefined ) {
		// Establish Variables
		var History = window.History;
		History.debug.enable = true;

		// Bind to State Change
		History.Adapter.bind( window, 'statechange', function( ) {
			var state = History.getState( );
			autoSearch( );
		} );
	}( window ) );

var showAdditionalResults = function( obj, resultSelector ) {
	var ontAcronym = jQuery( obj ).attr( "data-bp_ont" );
	jQuery( resultSelector + ontAcronym ).toggleClass( "not_visible" );
	jQuery( obj ).children( ".hide_link" ).toggleClass( "not_visible" );
	jQuery( obj ).toggleClass( "not_underlined" );
};

var showAdditionalOntResults = function( event ) {
	event.preventDefault( );
	showAdditionalResults( this, "#additional_ont_results_" );
};

var showAdditionalClsResults = function( event ) {
	event.preventDefault( );
	showAdditionalResults( this, "#additional_cls_results_" );
};

jQuery( document ).ready( function( ) {
	// Wire advanced search categories
	jQuery( "#search_categories" ).chosen( {
		search_contains: true
	} );
	jQuery( "#search_button" ).button( {
		search_contains: true
	} );
	jQuery( "#search_button" ).click( function( event ) {
		ajax_process_halt( );
	} );
	jQuery( "#search_keywords" ).click( function( event ) {
		ajax_process_halt( );
	} );

	// Put cursor in search box by default
	jQuery( "#search_keywords" ).focus( );

	// Show/hide on refresh
	if( advancedOptionsSelected( ) ) {
		jQuery( "#search_options" ).removeClass( "not_visible" );
	}

	jQuery( "#search_select_ontologies" ).change( function( ) {
		if( jQuery( this ).is( ":checked" ) ) {
			jQuery( "#ontology_picker_options" ).removeClass( "not_visible" );
		} else {
			jQuery( "#ontology_picker_options" ).addClass( "not_visible" );
			jQuery( "#ontology_ontologyId" ).val( "" );
			jQuery( "#ontology_ontologyId" ).trigger( "liszt:updated" );
		}
	} );

	// jQuery(".search_result
	// .additional_ont_results_title").live("click", function(event){
	// event.preventDefault();
	// var ontAcronym = jQuery(this).attr("data-bp_ont");
	// jQuery("#additional_ont_results_" +
	// ontAcronym).toggleClass("not_visible");
	// var searchResult = jQuery(this).parents(".search_result")[0];
	// var additionalOntResultsLink =
	// searchResult.children(".additional_ont_results_link")[0];
	// additionalOntResultsLink.children(".hide_link").toggleClass("not_visible");
	// additionalOntResultsLink.children(".search_link").toggleClass("not_underlined");
	// });

	jQuery( "#search_results a.additional_ont_results_link" ).live( "click", showAdditionalOntResults );
	jQuery( "#search_results a.additional_cls_results_link" ).live( "click", showAdditionalClsResults );

	// Show advanced options
	jQuery( "#advanced_options" ).click( function( event ) {
		jQuery( "#search_options" ).toggleClass( "not_visible" );
		jQuery( "#hide_advanced_options" ).toggleClass( "not_visible" );
	} );

	// Events to run whenever search results are updated (mainly counts)
	jQuery( document ).live( "search_results_updated", function( ) {
		// Update count
		jQuery( "#ontologies_count_total" ).html( currentOntologiesCount( ) );

		// Tooltip for ontology counts
		updatePopupCounts( );
		jQuery( "#ont_tooltip" ).tooltip( {
			position: "bottom right",
			opacity: "90%",
			offset: [ -18, 5 ]
		} );
	} );

	// Perform search
	jQuery( "#search_button" ).click( function( event ) {
		event.preventDefault( );
		History.pushState( currentSearchParams( ), document.title, "/search?" + objToQueryString( currentSearchParams( ) ) );
	} );

	// Search on enter
	jQuery( "#search_keywords" ).bind( "keyup", function( event ) {
		if( event.which == 13 ) {
			jQuery( "#search_button" ).click( );
		}
	} );

	// Details/visualize link to show details pane and visualize biomixer
	jQuery.facebox.settings.closeImage = '/javascripts/JqueryPlugins/facebox/closelabel.png';
	jQuery.facebox.settings.loadingImage = '/javascripts/JqueryPlugins/facebox/loading.gif';

	// Position of popup for details
	jQuery( document ).bind( "reveal.facebox", function( ) {
		if( jQuery( "div.class_details_pop" ).is( ":visible" ) ) {
			jQuery( "#facebox" ).css( "max-height", jQuery( window ).height( ) - ( jQuery( "#facebox" ).offset( ).top - jQuery( window ).scrollTop( ) ) * 2 + "px" );
		}
	} );

	// Use pop-up with flex via an iframe for "visualize" link
	jQuery( "a.class_visualize" ).live( "click", ( function( ) {
		var acronym = jQuery( this ).attr( "data-bp_ontologyid" );
		var conceptid = jQuery( this ).attr( "data-bp_conceptid" );

		jQuery( "#biomixer" ).html( '<iframe src="/ajax/biomixer/?ontology=' + acronym + '&conceptid=' + conceptid + '" frameborder=0 height="500px" width="500px" scrolling="no"></iframe>' ).show( );
		jQuery.facebox( {
			div: '#biomixer'
		} );
	} ) );

	autoSearch( );
} );

// Automatically perform search based on input parameters
function autoSearch( ) {
	// Check for existing parameters/queries and update UI accordingly
	var params = BP_queryString( );

	if( "q" in params || "query" in params ) {
		var query = params[ "query" ] || params[ "q" ];
		jQuery( "#search_keywords" ).val( query );

		if( params[ "exactmatch" ] == "true" || params[ "exact_match" ] == "true" ) {
			if( !jQuery( "#search_exact_match" ).is( ":checked" ) ) {
				jQuery( "#search_exact_match" ).attr( "checked", true );
			}
		} else {
			jQuery( "#search_exact_match" ).attr( "checked", false );
		}

		if( params[ "searchproperties" ] == "true" || params[ "include_properties" ] == "true" ) {
			if( !jQuery( "#search_include_properties" ).is( ":checked" ) ) {
				jQuery( "#search_include_properties" ).attr( "checked", true );
			}
		} else {
			jQuery( "#search_include_properties" ).attr( "checked", false );
		}

		if( params[ "require_definition" ] == "true" ) {
			if( !jQuery( "#search_require_definition" ).is( ":checked" ) ) {
				jQuery( "#search_require_definition" ).attr( "checked", true );
			}
		} else {
			jQuery( "#search_require_definition" ).attr( "checked", false );
		}

		if( params[ "include_views" ] == "true" ) {
			if( !jQuery( "#search_include_views" ).is( ":checked" ) ) {
				jQuery( "#search_include_views" ).attr( "checked", true );
			}
		} else {
			jQuery( "#search_include_views" ).attr( "checked", false );
		}

		if( "ontologyids" in params || "ontologies" in params ) {
			var ontologyIds = params[ "ontologies" ] || params[ "ontologyids" ] || "";
			ontologyIds = ontologyIds.split( "," );
			jQuery( "#ontology_ontologyId" ).val( ontologyIds );
			jQuery( "#ontology_ontologyId" ).trigger( "liszt:updated" );
		}

		if( "categories" in params ) {
			var categories = params[ "categories" ] || "";
			categories = categories.split( "," );
			jQuery( "#search_categories" ).val( categories );
			jQuery( "#search_categories" ).trigger( "liszt:updated" );
		}
	}

	// Show/hide on refresh
	if( advancedOptionsSelected( ) ) {
		jQuery( "#search_options" ).removeClass( "not_visible" );
	}

	if( jQuery( "#search_keywords" ).val( ) !== "" ) {
		performSearch( );
	}
}

function currentSearchParams( ) {
	var params = {};
	// Search query
	params.q = jQuery( "#search_keywords" ).val( );
	// Ontologies
	var ont_val = jQuery( "#ontology_ontologyId" ).val( );
	params.ontologies = ( ont_val === null ) ? "" : ont_val.join( "," );
	// Advanced options
	params.include_properties = jQuery( "#search_include_properties" ).is( ":checked" );
	params.include_views = jQuery( "#search_include_views" ).is( ":checked" );
	params.includeObsolete = jQuery( "#search_include_obsolete" ).is( ":checked" );
	// params.includeNonProduction =
	// jQuery("#search_include_non_production").is(":checked");
	params.require_definition = jQuery( "#search_require_definition" ).is( ":checked" );
	params.exact_match = jQuery( "#search_exact_match" ).is( ":checked" );
	params.categories = jQuery( "#search_categories" ).val( ) || "";
	return params;
}

function objToQueryString( obj ) {
	var str = [ ];
	for( var p in obj )
	str.push( encodeURIComponent( p ) + "=" + encodeURIComponent( obj[ p ] ) );
	return str.join( "&" );
}

function performSearch( ) {
	jQuery( "#search_spinner" ).show( );
	jQuery( "#search_messages" ).html( "" );
	jQuery( "#search_results" ).html( "" );
	jQuery( "#result_stats" ).html( "" );

	var ont_val = jQuery( "#ontology_ontologyId" ).val( );

	var onts = ( ont_val === null ) ? "" : ont_val.join( "," );
	var query = jQuery( "#search_keywords" ).val( );

	// Advanced options
	var includeProps = jQuery( "#search_include_properties" ).is( ":checked" );
	var includeViews = jQuery( "#search_include_views" ).is( ":checked" );
	var includeObsolete = jQuery( "#search_include_obsolete" ).is( ":checked" );
	var includeNonProduction = jQuery( "#search_include_non_production" ).is( ":checked" );
	var includeOnlyDefinitions = jQuery( "#search_require_definition" ).is( ":checked" );
	var exactMatch = jQuery( "#search_exact_match" ).is( ":checked" );
	var categories = jQuery( "#search_categories" ).val( ) || "";

	jQuery.ajax( {
		url: determineHTTPS( jQuery( document ).data( ).bp.config.rest_url ) + "/search",
		data: {
			q: query,
			include_properties: includeProps,
			include_views: includeViews,
			obsolete: includeObsolete,
			include_non_production: includeNonProduction,
			require_definition: includeOnlyDefinitions,
			exact_match: exactMatch,
			categories: categories,
			ontologies: onts,
			pagesize: 150,
			apikey: jQuery( document ).data( ).bp.config.apikey,
			userapikey: jQuery( document ).data( ).bp.config.userapikey,
			format: "jsonp"
		},
		dataType: "jsonp",
		success: function( data ) {
			var results = [ ];
			var ontologies = {};
			var groupedResults;
			if( categories.length > 0 ) {
				data.collection = filterCategories( data.collection, categories );
			}
			if( !jQuery.isEmptyObject( data ) ) {
				groupedResults = aggregateResults( data.collection );
				jQuery( groupedResults ).each( function( ) {
					results.push( formatSearchResults( this ) );
				} );
			}
			// Display error message if no results found
			var result_count = jQuery( "#result_stats" );
			if( data.collection.length === 0 ) {
				result_count.html( "" );
				jQuery( "#search_results" ).html( "<h2 style='padding-top: 1em;'>No matches found</h2>" );
			} else {
				var results_by_ont = jQuery( "#ontology_ontologyId" ).val( ) === null ? "<a id='ont_tooltip' href='javascript:void(0);'>Matches in <span id='ontologies_count_total'>" + groupedResults.length + "</span> ontologies</a><div id='ontology_counts' class='ontology_counts_tooltip'/>" : "";
				result_count.html( results_by_ont );
				jQuery( "#search_results" ).html( results.join( "" ) );
			}
			jQuery( "a[rel*=facebox]" ).facebox( );
			jQuery( "#search_results" ).show( );
			jQuery( "#search_spinner" ).hide( );
		},
		error: function( ) {
			jQuery( "#search_spinner" ).hide( );
			jQuery( "#search_results" ).hide( );
			jQuery( "#search_messages" ).html( "<span style='color: red'>Problem searching, please try again" );
		}
	} );
}

function aggregateResults( results ) {
	// class URI aggregation, promotes a class that belongs to 'owning' ontology,
	// e.g. /search?q=cancer returns several hits for
	// 'http://purl.obolibrary.org/obo/DOID_162'
	// those results should be aggregated below the DOID ontology.
	var classes = aggregateResultsByClassURI( results );
	var ontologies = aggregateResultsByOntology( results );
	// var ontologies = aggregateResultsByOntologyWithClasses(ontologies, classes);
	ontologies = aggregateResultsWithoutDuplicateClasses( ontologies, classes );
	return ontologies;
}

function aggregateResultsWithoutDuplicateClasses( ontologies, classes ) {
	var resultsWithoutDuplicateClasses = [ ];
	for( var i = 0; i < ontologies.length; i++ ) {
		var ont = ontologies[ i ];
		var ontResults = ont.same_ont.slice( 0 );
		// clone the results
		// Try to find a class in the ontology results that should be displayed
		// at the top level.  There might be many results that are 'subordinate'
		// classes, which should be demoted to the bottom of the ontology results.
		var ontDisplay = false;
		var tmpResults = ontResults.slice( 0 );
		// clone the results
		while( tmpResults.length > 0 ) {
			var result = tmpResults.shift( );
			// pull the first result
			var classResults = classes[ result[ "@id" ] ];
			// Must be at least 1 entry.
			if( classResults[ 0 ].links.ontology === result.links.ontology ) {
				// This is an ontology with at least one top level class to display.
				ontDisplay = true;
				break;
				// Note: alternate algorithm to remove subordinate classes cannot stop here.
			} else {
				// Note: alternate algorithm could remove the 'subordinate' class
				//       from the results for this ontology.
				// Push the first result to the end of the array (using ontResults).
				if( ontResults.length > 1 ) {
					var firstResult = ontResults.shift( );
					ontResults.push( firstResult );
				} else {
					// There's nothing to manipulate, we're done.
					break;
				}
			}
		}
		if( ontDisplay ) {
			// update original array with reordered array.
			ont.same_ont = ontResults;
			resultsWithoutDuplicateClasses.push( ont );
		}
	}
	return resultsWithoutDuplicateClasses;
}

function aggregateResultsByOntologyWithClasses( results, classes ) {
	// NOTE: Cannot rely on the order of hash keys (obj properties) to preserve
	// the order of the results, see
	// http://stackoverflow.com/questions/280713/elements-order-in-a-for-in-loop
	var ontologies = {
		"list": [ ], // used to ensure we have ordered ontologies
		"hash": {}
	};
	var ont = null, cls = null, res = null;
	for( var i in results ) {
		res = results[ i ];
		cls = res[ '@id' ];
		ont = res.links.ontology;
		if( typeof ontologies.hash[ ont ] === "undefined" ) {
			ontologies.hash[ ont ] = {
				"same_cls": [ ], // list of classes with same URI, from non 'owner' ontologies
				"same_ont": [ ] // list of other classes from the same ontology
			};
			// Manage an ordered set of ontologies (no duplicates)
			ontologies.list.push( ont );
		}
		ontologies.hash[ ont ].same_ont.push( res );
		// Determine whether this result has the same ontology as the first entry in
		// classes[cls]. If it is not, skip this result because it will be listed below
		// the 'owner' ontology. This means that aggregation for classes with the same
		// URI will override aggregation for different classes in the same ontology.
		var ont_owner = ( classes[cls][ 0 ].links.ontology === ont );
		// if (! ont_owner) {
		// continue;
		// }
		if( ont_owner && classes[ cls ].length > 1 ) {
			// This result must be a class in an 'owner' ontology (or there are no
			// 'owner' ontologies for this class). Now aggregate the same class from
			// other ontologies within this result (skip the first entry).
			ontologies.hash[ ont ].same_cls = classes[ cls ].slice( 1 );
		}
	}
	// iterate the ordered ontologies, not the hash keys
	var resultsByOntology = [ ];
	for( var i = 0; i < ontologies.list.length; i++ ) {
		var ont = ontologies.list[ i ];
		resultsByOntology.push( ontologies.hash[ ont ] );
	}
	return resultsByOntology;
}

function aggregateResultsByOntology( results ) {
	// NOTE: Cannot rely on the order of hash keys (obj properties) to preserve
	// the order of the results, see
	// http://stackoverflow.com/questions/280713/elements-order-in-a-for-in-loop
	var ontologies = {
		"list": [ ], // used to ensure we have ordered ontologies
		"hash": {}
	};
	var res = null, ont = null;
	for( var i in results ) {
		res = results[ i ];
		ont = res.links.ontology;
		if( typeof ontologies.hash[ ont ] === "undefined" ) {
			ontologies.hash[ ont ] = {
				"same_cls": [ ], // list of classes with same URI, from non 'owner' ontologies
				"same_ont": [ ] // list of other classes from the same ontology
			};
			// Manage an ordered set of ontologies (no duplicates)
			ontologies.list.push( ont );
		}
		ontologies.hash[ ont ].same_ont.push( res );
	}
	// iterate the ordered ontologies, not the hash keys
	var resultsByOntology = [ ];
	for( var o in ontologies.list ) {
		ont = ontologies.list[ o ];
		resultsByOntology.push( ontologies.hash[ ont ] );
	}
	return resultsByOntology;
}

function aggregateResultsByClassURI( results ) {
	var cls_hash = {};
	for( var i in results ) {
		var res = results[ i ];
		var cls_id = res[ '@id' ];
		if( typeof cls_hash[ cls_id ] === "undefined" ) {
			cls_hash[ cls_id ] = [ ];
		}
		cls_hash[ cls_id ].push( res );
	}
	// Detect and 'promote' the class with an 'owner' ontology.
	for( var cls_id in cls_hash ) {
		var ont_owner_acronym = "";
		var ont_owner_index = 0;
		var cls_list = cls_hash[ cls_id ];
		// console.log("Before owner, cls: " + cls_id +
		// ", ont: " + ontologyIdToAcronym(cls_list[0].links.ontology) +
		// ", #results: " + cls_list.length);
		if( cls_list.length > 1 ) {
			// Find the class in the 'owner' ontology (cf. ontologies that import the
			// class, or views).
			for( var c in cls_list ) {
				var c_ont_acronym = ontologyIdToAcronym( cls_list[ c ].links.ontology );
				// Does the cls_id contain the ont acronym?
				// If so, the result is a potential ontology owner.
				// Update the ontology owner, if the ontology acronym
				// matches and it is longer than any previous ontology owner.
				if( ( cls_id.indexOf( c_ont_acronym ) > -1 ) && ( c_ont_acronym.length > ont_owner_acronym.length ) ) {
					ont_owner_acronym = c_ont_acronym;
					ont_owner_index = c;
					// console.log("Detected owner: index = " + ont_owner_index + ", ont =
					// " + ont_owner_acronym);
				}
			}
			// Only promote the class result if the ontology owner is not already in
			// the first position.
			if( ont_owner_index > 0 ) {
				// pop the owner and shift it to the top of the list, everything else
				// can stay put
				var ont_owner_result = cls_list.splice(ont_owner_index, 1)[ 0 ];
				cls_list.unshift( ont_owner_result );
				// console.log("Promoted owner: index = " + ont_owner_index + ", ont = "
				// + ont_owner_acronym);
			}
		}
	}
	return cls_hash;
}


var sortStringFunction = function( a, b ) {
	// See http://www.sitepoint.com/sophisticated-sorting-in-javascript/
	var x = String( a ).toLowerCase( );
	var y = String( b ).toLowerCase( );
	return x < y ? -1 : x > y ? 1 : 0;
};


function sortResultsByOntology( results ) {
	// See http://www.sitepoint.com/sophisticated-sorting-in-javascript/
	return results.sort( function( a, b ) {
		var ontA = String( a.links.ontology ).toLowerCase( );
		var ontB = String( b.links.ontology ).toLowerCase( );
		return ontA < ontB ? -1 : ontA > ontB ? 1 : 0;
	} );
}

function formatSearchResults( aggOntologyResults ) {
	var ontResults = aggOntologyResults.same_ont;
	var clsResults = aggOntologyResults.same_cls;
	var res = ontResults.shift( );
	var ontAcronym = ontologyIdToAcronym( res.links.ontology );
	var clsID = res[ "@id" ];
	var clsCode = encodeURIComponent( clsID );
	var label_html = classLabelSpan( res );

	var searchResultDiv = jQuery( "<div>" );
	searchResultDiv.addClass( "search_result" );
	searchResultDiv.attr( "data-bp_ont_id", res.links.ontology );
	searchResultDiv.append( classDiv( res, label_html, true ) );
	searchResultDiv.append( definitionDiv( res ) );

	var additionalResultsSpan = jQuery( "<span>" );
	additionalResultsSpan.addClass( "additional_results_link" );
	additionalResultsSpan.addClass( "search_result_link" );

	var additionalResultsHide = jQuery( "<span>" );
	additionalResultsHide.addClass( "not_visible" );
	additionalResultsHide.addClass( "hide_link" );
	additionalResultsHide.text( "[hide]" );

	// Process additional ontology results
	var additionalOntResults = "";
	if( ontResults.length > 0 ) {
		var additionalOntResultsAttr = {
			"href": "#additional_ont_results",
			"data-bp_ont": ontAcronym,
			"data-bp_cls": clsID
		};
		var additionalOntResultsAnchor = jQuery( "<a>" );
		additionalOntResultsAnchor.addClass( "additional_ont_results_link" );
		additionalOntResultsAnchor.addClass( "search_result_link" );
		additionalOntResultsAnchor.attr( additionalOntResultsAttr );
		additionalOntResultsAnchor.append( ontResults.length + " more from this ontology" );
		additionalOntResultsAnchor.append( additionalResultsHide.clone( ) );
		additionalResultsSpan.append( " - " );
		additionalResultsSpan.append( additionalOntResultsAnchor );
		additionalOntResults = formatAdditionalOntResults( ontResults, ontAcronym );
	}

	// Process additional clsResults
	var additionalClsResults = "";
	if( clsResults.length > 0 ) {
		var additionalClsResultsAttr = {
			"href": "#additional_cls_results",
			"data-bp_ont": ontAcronym,
			"data-bp_cls": clsID
		};
		var additionalClsResultsAnchor = jQuery( "<a>" );
		additionalClsResultsAnchor.addClass( "additional_cls_results_link" );
		additionalClsResultsAnchor.addClass( "search_result_link" );
		additionalClsResultsAnchor.attr( additionalClsResultsAttr );
		additionalClsResultsAnchor.append( clsResults.length + " more for this class" );
		additionalClsResultsAnchor.append( additionalResultsHide.clone( ) );
		additionalResultsSpan.append( " - " );
		additionalResultsSpan.append( additionalClsResultsAnchor );
		additionalClsResults = formatAdditionalClsResults( clsResults, ontAcronym );
	}

	var searchResultLinks = jQuery( "<div>" );
	searchResultLinks.addClass( "search_result_links" );
	searchResultLinks.append( resultLinksSpan( res ) );
	searchResultLinks.append( additionalResultsSpan );

	searchResultDiv.append( searchResultLinks );
	searchResultDiv.append( additionalOntResults );
	searchResultDiv.append( additionalClsResults );
	return searchResultDiv.prop( "outerHTML" );
}


function formatAdditionalClsResults( clsResults, ontAcronym ) {
	var additionalClsTitle = jQuery( "<h3>" );
	additionalClsTitle.addClass( "additional_cls_results_title" );
	additionalClsTitle.text( "Same Class URI - Other Ontologies" );
	var clsResultsFormatted = jQuery( "<div>" );
	clsResultsFormatted.attr( "id", "additional_cls_results_" + ontAcronym );
	clsResultsFormatted.addClass( "additional_cls_results" );
	clsResultsFormatted.addClass( "not_visible" );
	clsResultsFormatted.append( additionalClsTitle );
	jQuery( clsResults ).each( function( ) {
		var searchResultDiv = jQuery( "<div>" );
		searchResultDiv.addClass( "search_result_links" );
		searchResultDiv.append( resultLinksSpan( this ) );
		// class prefLabel with ontology name
		var classLabelDiv = classDiv( this, classLabelSpan( this ), true );
		var classDetailsDiv = jQuery( "<div>" );
		classDetailsDiv.addClass( "search_result_additional" );
		classDetailsDiv.append( classLabelDiv );
		classDetailsDiv.append( definitionDiv( this, "additional_def_container" ) );
		classDetailsDiv.append( searchResultDiv );
		clsResultsFormatted.append( classDetailsDiv );
	} );
	return clsResultsFormatted;
}


function formatAdditionalOntResults( ontResults, ontAcronym ) {
	var additionalOntTitle = jQuery( "<span>" );
	additionalOntTitle.addClass( "additional_ont_results_title" );
	additionalOntTitle.addClass( "search_result_link" );
	additionalOntTitle.attr( "data-bp_ont", ontAcronym );
	additionalOntTitle.text( "Same Ontology - Other Classes" );
	var ontResultsFormatted = jQuery( "<div>" );
	ontResultsFormatted.attr( "id", "additional_ont_results_" + ontAcronym );
	ontResultsFormatted.addClass( "not_visible" );
	// ontResultsFormatted.addClass( "additional_ont_results" );
	// ontResultsFormatted.append( additionalOntTitle );
	jQuery( ontResults ).each( function( ) {
		var searchResultDiv = jQuery( "<div>" );
		searchResultDiv.addClass( "search_result_links" );
		searchResultDiv.append( resultLinksSpan( this ) );
		// class prefLabel without ontology name
		var classLabelDiv = classDiv( this, classLabelSpan( this ), false );
		var classDetailsDiv = jQuery( "<div>" );
		classDetailsDiv.addClass( "search_result_additional" );
		classDetailsDiv.append( classLabelDiv );
		classDetailsDiv.append( definitionDiv( this, "additional_def_container" ) );
		classDetailsDiv.append( searchResultDiv );
		ontResultsFormatted.append( classDetailsDiv );
	} );
	return ontResultsFormatted;
}


function updatePopupCounts( ) {
	var ontologies = [ ];
	jQuery( "#search_results div.search_result" ).each( function( ) {
		var result = jQuery( this );
		// Add one to the additional results to get total count (1 is for the primary
		// result)
		var resultsCount = result.children( "div.additional_ont_results" ).find( "div.search_result_additional" ).length + 1;
		ontologies.push( result.attr( "data-bp_ont_name" ) + " <span class='popup_counts'>" + resultsCount + "</span><br/>" );
	} );
	// Sort using case insensitive sorting
	ontologies.sort( sortStringFunction );
	jQuery( "#ontology_counts" ).html( ontologies.join( "" ) );
}


function classLabelSpan( cls ) {
	// Wrap the class prefLabel in a span, indicating that the  class is obsolete
	// if necessary.
	var max_word_length = 60;
	var label_text = ( cls.prefLabel.length > max_word_length ) ? cls.prefLabel.substring( 0, max_word_length ) + "..." : cls.prefLabel;
	var labelSpan = jQuery( "<span>" ).addClass( 'prefLabel' ).text( label_text );
	if( cls.obsolete === true ) {
		labelSpan.removeClass( 'prefLabel' );
		labelSpan.addClass( 'obsolete_class' );
		labelSpan.attr( 'title', 'obsolete class' );
	}
	return labelSpan;
	// returns a jQuery object; use .prop('outerHTML') to get markup.
}

function filterCategories( results, filterCats ) {
	var newResults = [ ];
	jQuery( results ).each( function( ) {
		var result = this;
		var acronym = ontologyIdToAcronym( result.links.ontology );
		jQuery( filterCats ).each( function( ) {
			if( categoriesMap[ this ].indexOf( acronym ) > -1 ) {
				newResults.push( result );
			}
		} );
	} );
	return newResults;
}

function shortenDefinition( def ) {
	var defLimit = 210;
	if( typeof def !== "undefined" && def !== null && def.length > 0 ) {
		// Make sure definitions isn't an array
		def = ( typeof def === "string" ) ? def : def.join( ". " );
		// Strip out xml elements and/or html
		def = jQuery( "<div/>" ).html( def ).text( );
		if( def.length > defLimit ) {
			var defWords = def.slice( 0, defLimit ).split( " " );
			// Remove the last word in case we got one partway through
			defWords.pop( );
			def = defWords.join( " " ) + " ...";
		}
	}
	jQuery( document ).trigger( "search_results_updated" );
	return def || "";
}

function advancedOptionsSelected( ) {
	if( document.URL.indexOf( "opt=advanced" ) >= 0 ) {
		return true;
	}
	var check = [
	function( ) {
		return jQuery( "#search_include_properties" ).is( ":checked" );
	},
	function( ) {
		return jQuery( "#search_include_views" ).is( ":checked" );
	},
	function( ) {
		return jQuery( "#search_include_non_production" ).is( ":checked" );
	},
	function( ) {
		return jQuery( "#search_include_obsolete" ).is( ":checked" );
	},
	function( ) {
		return jQuery( "#search_only_definitions" ).is( ":checked" );
	},
	function( ) {
		return jQuery( "#search_exact_match" ).is( ":checked" );
	},
	function( ) {
		return jQuery( "#search_categories" ).val( ) !== null && jQuery( "#search_categories" ).val( ).length > 0;
	},
	function( ) {
		return jQuery( "#ontology_ontologyId" ).val( ) !== null && jQuery( "#ontology_ontologyId" ).val( ).length > 0;
	} ];
	var length = check.length;
	for( var i = 0; i < length; i++ ) {
		var selected = check[i]( );
		if( selected )
			return true;
	}
	return false;
}

function ontologyIdToAcronym( id ) {
	return id.split("/").slice(-1)[ 0 ];
}

function getOntologyName( cls ) {
	var ont = jQuery(document).data().bp.ontologies[ cls.links.ontology ];
	if( typeof ont === 'undefined' )
		return "";
	return " - " + ont.name + " (" + ont.acronym + ")";
}

function currentResultsCount( ) {
	return jQuery( ".search_result" ).length + jQuery( ".search_result_additional" ).length;
}

function currentOntologiesCount( ) {
	return jQuery( ".search_result" ).length;
}

function classDiv( res, classLabel, displayOntologyName ) {
	var classCode = encodeURIComponent( res[ "@id" ] );
	var classURI = "/ontologies/" + ontologyIdToAcronym( res.links.ontology ) + "?p=classes&conceptid=" + classCode;
	var ontologyName = displayOntologyName ? getOntologyName( res ) : "";
	var classAnchor = jQuery( "<a>" ).attr( {
		"title": res.prefLabel,
		"data-bp_conceptid": classCode,
		"data-exact_match": res.exactMatch,
		"href": classURI
	} ).append( classLabel ).append( ontologyName );
	var classIdDiv = jQuery( "<div>" ).addClass( "concept_uri" ).text( res[ "@id" ] );
	return jQuery( "<div>" ).addClass( "class_link" ).append( classAnchor ).append( classIdDiv );
}

function resultLinksSpan( res ) {
	var ont_acronym = ontologyIdToAcronym( res.links.ontology );
	var cls_id_encode = encodeURIComponent( res[ "@id" ] );
	// construct link for class 'details' in facebox
	var details_href = "/ajax/class_details?ontology=" + ont_acronym + "&conceptid=" + cls_id_encode + "&styled=false";
	var details_anchor = jQuery( "<a>" ).attr( {
		"href": details_href,
		"rel": "facebox[.class_details_pop]"
	} ).addClass( "class_details" ).addClass( "search_result_link" ).text( "details" );
	// construct link for class 'visualizer' in facebox
	var viz_anchor = jQuery( "<a>" ).attr( {
		"href": "javascript:void(0);",
		"data-bp_conceptid": cls_id_encode,
		"data-bp_ontologyid": ont_acronym
	} ).addClass( "class_visualize" ).addClass( "search_result_link" ).text( "visualize" );
	return jQuery( "<span>" ).addClass( "additional" ).append( details_anchor ).append( " - " ).append( viz_anchor );
}

function definitionDiv( res, defClass ) {
	defClass = typeof defClass === "undefined" ? "def_container" : defClass;
	return jQuery( "<div>" ).addClass( defClass ).text( shortenDefinition( res.definition ) );
}

function determineHTTPS( url ) {
	return url.replace( "http:", ( 'https:' == document.location.protocol ? 'https:' : 'http:' ) );
}

