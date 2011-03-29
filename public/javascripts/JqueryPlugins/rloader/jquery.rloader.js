//============================================
//	Author:		2basix automatisering
//				http://2basix.nl
// 	Project: 	resource loader
// 	Version:	1.1
// 	license: 	GNU General Public License v3
//	project:	http://code.google.com/p/rloader
//============================================

(function($){
	$.rloader = function(args) {

		var list = [];
		if (args && !(args.propertyIsEnumerable('length')) && typeof args === 'object' && typeof args.length === 'number') {
			list=args;
		} else {list[0]=args;}
		
		$.each(list, function(i,res){
			// is the resource loaded ?
			function checkHist(src) {
				if ($.rloader.track[src].status) {
					return $.rloader.track[src].status;
				} else {
					return 0;
				}
			}
			// Add a CSS file to the document
			function loadCSS(options){
				// Process options
				var callback=null;
				var src	= options.src,
					cache = true,
					arg	= options.arg || {};
				if (options.callback) {callback=options.callback;}

				if (typeof options.cache != 'undefined') {cache=options.cache;}
				if (cache===false) {
					var d=new Date();
					src=src+"?"+d.getTime();
				}
				if (checkHist(options.src)>0) {return true;}
				
				$.rloader.track[options.src].status = 0;
				var node = document.createElement('link');
				node.type = 'text/css';
				node.rel = 'stylesheet';
				node.href = src;
				node.media = 'screen';
				document.getElementsByTagName("head")[0].appendChild(node);
				$.rloader.track[options.src].status = 1;
				if(callback){callback(arg);}	
			}
			
			// Add a JS file to the document
			function loadJS (options){
				// Process options
				var callback=null;
				var src	= options.src,
					async = options.async || false,
					cache = true,
					arg	= options.arg || {};
				if (options.callback) {callback=options.callback;}
				if (typeof options.cache != 'undefined') {cache=options.cache;}
		
				if (checkHist(src)>0) {return true;}		// check status
				$.rloader.track[src].status = 0;

				$.ajax({
					type: "GET",
					url: src,
					async: async,
					cache: cache,
					dataType: "script",
					success: function(){
						$.rloader.track[src].status = 1;
						if(callback) {
							callback(arg);
						}
					}
				});
			}
			if (typeof res.type=='string' && typeof res.src=='string') {
				if (!$.rloader.track[res.src]) {
					$.rloader.track[res.src] = {'status':0};
				}	
				if (res.type=='css') {
					loadCSS(res);
				}
				if (res.type=='js') {
					loadJS(res);
				}
			}
		});
	};
	$.rloader.track = {};
})(jQuery);
