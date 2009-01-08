// actions for interacting with the graph

// gets the flash application
function getApp() {
	// first try the basic flexviz
	var app = document.getElementById("BasicFlexoViz");
	if (app == null) {
		// try the full version
		app = document.getElementById("FlexoViz");
	}
	return app;
}

/** 
 * Selects on the node with the given id
 * @param id the id of the node to focus on
 */
function selectNodeByID(id) {
	var app = getApp();
	if (app) {
		if (app.selectNodeByID) {
			app.selectNodeByID(id);
		} else {
			alert("Could not select the concept with ID '" + id + "'.");
		}
	} else {
		alert("Could not get Flash object, JavaScript/Flex communication failed.");
	}
}

/** 
 * Focusses on the node with the given id
 * @param id the id of the node to focus on
 * @param option the graph view setting (optional), one of "Neighborhood", "Hierarchy To Root", "Parents", or "Children"
 *		defaults to "Neighborhood"
 */
function searchByID(id, option) {
	var app = getApp();
	if (app) {
		if (app.searchByID) {
			app.searchByID(id);
		} else {
			alert("Could not search for the concept with ID '" + id + "'.");
		}
	} else {
		alert("Could not get Flash object, JavaScript/Flex communication failed.");
	}
}

/** 
 * Performs a search on the given text and shows
 * the appropriate graph - either the neighborhood, or the hierarchy to root
 * @param searchText the text to search for
 * @param option the graph view setting (optional), one of "Neighborhood", "Hierarchy To Root", "Parents", or "Children"
 *		defaults to "Neighborhood"
 */
function searchByName(searchText, option) {
	var app = getApp();
	if (app) {
		if (app.searchByName) {
			app.searchByName(searchText);
		} else {
			alert("Could not search for the concept with nane '" + id + "'.");
		}
	} else {
		alert("Could not get Flash object, JavaScript/Flex communication failed.");
	}
}

/**
 * The basic version of FlexViz calls this function when a node is double clicked.
 */
function nodeSelectedInFlex(id) {
	//alert("Node selected in flex: " + id);
}
