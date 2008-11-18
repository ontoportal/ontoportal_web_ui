// jQuery Cursor Message Plugin
//
// Version 0.1
//
// Tim de Koning
// Kingsquare Information Services (http://www.kingsquare.nl/)
//
// Visit http://www.kingsquare.nl/cursorMessage for usage and more information
//
// Terms of Use
//
// This file is released under the GPL, any version you like
//

if(jQuery) {
	( function($) {
	$.cursorMessageData = {}; // needed for e.g. timeoutId
	//start registring mouse coöridnates from the start!

	$(window).ready(function(e) {
		if ($('#cursorMessageDiv').length==0) {
			  $('body').append('<div id="cursorMessageDiv">&nbsp;</div>');	
			  $('#cursorMessageDiv').hide();
		}

		$('body').mousemove(function(e) {
			$.cursorMessageData.mouseX = e.pageX;
			$.cursorMessageData.mouseY = e.pageY;
			if ($.cursorMessageData.options != undefined) $._showCursorMessage();
		});
	});	
	$.extend({
		cursorMessage: function(message, options) {
			if( options == undefined ) options = {};
			if( options.offsetX == undefined ) options.offsetX = 5;
			if( options.offsetY == undefined ) options.offsetY = 5;
			if( options.hideTimeout == undefined ) options.hideTimeout = 1000;
			
			var hideCursorMessage = function() {
				$('#cursorMessageDiv').html(message).fadeOut('slow');
			};
			
			$('#cursorMessageDiv').html(message).fadeIn('slow');
			if (jQuery.cursorMessageData.hideTimoutId != undefined)  clearTimeout(jQuery.cursorMessageData.hideTimoutId);
			jQuery.cursorMessageData.hideTimoutId = setTimeout(hideCursorMessage,options.hideTimeout);
			jQuery.cursorMessageData.options = options;
			$._showCursorMessage();
		},
		
		_showCursorMessage: function() {
			$('#cursorMessageDiv').css({ top: ($.cursorMessageData.mouseY + $.cursorMessageData.options.offsetY)+'px', left: ($.cursorMessageData.mouseX + $.cursorMessageData.options.offsetX) })
		},
		_hideCursorMessage: function() {
		  
		    $('#cursorMessageDiv').hide();
		}
	});
})(jQuery);
}