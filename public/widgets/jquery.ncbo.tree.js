/*
* jQuery SimpleTree Drag&Drop plugin
* Update on 22th May 2008
* Version 0.3
*
* Licensed under BSD <http://en.wikipedia.org/wiki/BSD_License>
* Copyright (c) 2008, Peter Panov <panov@elcat.kg>, IKEEN Group http://www.ikeen.com
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the Peter Panov, IKEEN Group nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY Peter Panov, IKEEN Group ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL Peter Panov, IKEEN Group BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

(function($) {
  $.fn.NCBOTree = function(opt) {
    var ROOT_ID = "roots";
    var TREE_CONTAINER = this;
    var TREE = $("<ul>").append($("<li>").addClass("root"));
    var ROOT;
    var mousePressed = false;

    TREE.option = {
      autoclose:         false,
      beforeExpand:      false,
      afterExpand:       false,
      afterExpandError:  false,
      afterSelect:       false,
      afterJumpToClass:  false,
      timeout:           999999,
      treeClass:         "ncboTree",
      autocompleteClass: "ncboAutocomplete",
      width:             350,
      ncboAPIURL:        "http://data.bioontology.org",
      ncboUIURL:         "http://bioportal.bioontology.org",
      apikey:            null,
      ontology:          null,
      startingClass:     null,
      startingRoot:      ROOT_ID,
      defaultRoot:       ROOT_ID
    };

    TREE.option = $.extend(TREE.option, opt);

    // Required options
    if (TREE.option.apikey == null)
      throw new Error("You must provide an API Key for NCBO Tree Widget to operate");

    if (TREE.option.ontology == null)
      throw new Error("You must provide an ontology id for NCBO Tree Widget to operate");

    // These methods will be added to the tree object
    // they are essentially "public". Doing the following
    // gives you a handle to inspect the tree from:
    // var tree = $("#my_div").NCBOTree(opts);
    // And then you can do: tree.selectedClass()
    $.extend(this, {
      selectedClass: function(){
        var cls = $($(this).find("a.active")[0]);
        if (cls.length == 0) {
          return null;
        } else {
          return {
            id: decodeURIComponent(cls.data("id")),
            prefLabel: cls.html(),
            URL: cls.attr("href")
          };
        }
      },

      selectClass: function(cls){
        var foundClass = $($(this).find("a[data-id='" + encodeURIComponent(cls) + "']"));
        $($(this).find("a.active")[0]).removeClass("active");
        foundClass.addClass("active");
      },

      jumpToClass: function(cls, callback){
        TREE.jumpToClass(cls, callback);
      },

      changeOntology: function(ont){
        var newTree = $("<ul>").append($("<li>").addClass("root"));
        setupTree(TREE_CONTAINER, newTree, TREE.option);
        TREE.option.ontology = ont;
        TREE.init();
      }
    });

    setupTree = function(container, tree, option) {
      TREE = tree;
      TREE.option = option;
      ROOT = $('.root', TREE);
      TREE.css("width", TREE.option.width);

      // Empty out the tree container
      $(TREE_CONTAINER).html("")

      // Only set starting root when something other than roots is selected
      var startingRoot = (TREE.option.startingRoot == TREE.option.defaultRoot) ? null : TREE.option.startingRoot;

      // Add the autocomplete
      var autocompleteContainer = $("<div>").addClass(TREE.option.autocompleteClass).addClass("ncboTree");
      var input = $("<input>")
        .addClass(TREE.option.autocompleteClass)
        .css("width", TREE.option.width)
        .attr("placeholder", "Search for class...");
      autocompleteContainer.append(input);
      input.NCBOAutocomplete({
        url: TREE.option.ncboAPIURL + "/search",
        searchParameter: "q",
        resultAttribute: "collection",
        property: "prefLabel",
        searchTextSuffix: "*",
        searchFromRoot: startingRoot,
        onSelect: function(item, searchInput) {
          TREE.jumpToClass(item["@id"]);
          searchInput.val("");
        },
        minCharacters: 3,
        additionalParameters: {
          apikey: TREE.option.apikey,
          no_context: true,
          ontologies: TREE.option.ontology
        }
      });
      $(TREE_CONTAINER).append(autocompleteContainer);

      // Add the actual tree
      $(TREE_CONTAINER).append(TREE);

      // Add provided class
      TREE.addClass(TREE.option.treeClass);

      // format the nodes to match what simpleTree is expecting
      TREE.formatNodes = function(nodes) {
        var holder = $("<span>");
        var ul = $("<ul>")

        // Sort by prefLabel
        nodes.sort(function(a, b){
          var aName = a.prefLabel.toLowerCase();
          var bName = b.prefLabel.toLowerCase();
          return ((aName < bName) ? -1 : ((aName > bName) ? 1 : 0));
        });

        $.each(nodes, function(index, node){
          var li = $("<li>");
          var a = $("<a>").attr("href", node.links.self).html(node.prefLabel);
          a.attr("data-id", encodeURIComponent(node["@id"]));

          ul.append(li.append(a));

          var hasChildrenNotExpanded = typeof node.children !== 'undefined' && node.childrenCount > 0 && node.children.length == 0;
          if (node.childrenCount > 0 && typeof node.children === 'undefined' || hasChildrenNotExpanded) {
            var ajax_ul = $("<ul>").addClass("ajax");
            var ajax_li = $("<li>");
            var ajax_a = $("<a>").attr("href", node.links.children);
            li.append(ajax_ul.append(ajax_li.append(ajax_a)));
          } else if (typeof node.children !== 'undefined' && node.children.length > 0) {
            var child_ul = TREE.formatNodes(node.children);
            li.attr("class", "folder-open")
            li.append(child_ul);
          }
        });

        holder.append(ul)
        return holder.html();
      }

      TREE.findRootNode = function(nodes) {
        var startingRoot = (TREE.option.startingRoot == TREE.option.defaultRoot) ? null : TREE.option.startingRoot;
        if (startingRoot == null) {return nodes;}

        var foundNode = false;
        var searchQueue = nodes;

        while (searchQueue.length > 0 || foundNode == false) {
          var node = searchQueue.shift();
          if (node["@id"] == startingRoot) {
            foundNode = [node];
          } else if (typeof node.children !== 'undefined' && node.children.length > 0) {
            searchQueue = searchQueue.concat(node.children);
          }
        }

        return foundNode;
      }

      TREE.jumpToClass = function(cls, callback) {
        ROOT.html($("<span>").html("Loading...").css("font-size", "smaller"));
        $.ajax({
          url: TREE.option.ncboAPIURL + "/ontologies/" + TREE.option.ontology + "/classes/" + encodeURIComponent(cls) + "/tree",
          data: {apikey: TREE.option.apikey, include: "prefLabel,childrenCount", no_context: true},
          contentType: 'json',
          crossDomain: true,
          success: function(roots){
            roots = TREE.findRootNode(roots);
            ROOT.html(TREE.formatNodes(roots));
            TREE.setTreeNodes(ROOT, false);

            if (typeof callback == 'function') {
              callback();
            }

            TREE_CONTAINER.selectClass(cls);
            if (typeof TREE.option.afterJumpToClass == 'function') {
              TREE.option.afterJumpToClass(cls);
            }
            TREE_CONTAINER.trigger("afterJumpToClass", cls);
          }
        });
      }

      TREE.closeNearby = function(obj) {
        $(obj).siblings().filter('.folder-open, .folder-open-last').each(function(){
          var childUl = $('>ul',this);
          var className = this.className;
          this.className = className.replace('open', 'close');
          childUl.hide();
        });
      };

      TREE.nodeToggle = function(obj) {
        var childUl = $('>ul',obj);
        if (childUl.is(':visible')) {
          obj.className = obj.className.replace('open','close');
          childUl.hide();
        } else {
          obj.className = obj.className.replace('close','open');
          childUl.show();
          if (TREE.option.autoclose)
            TREE.closeNearby(obj);
          if (childUl.is('.ajax'))
            TREE.setAjaxNodes(childUl, obj.id);
        }
      };

      TREE.setAjaxNodes = function(node, parentId, successCallback, errorCallback) {
        if (typeof TREE.option.beforeExpand == 'function') {
          TREE.option.beforeExpand(node);
        }
        TREE_CONTAINER.trigger("beforeExpand", node);

        var url = $.trim($('a', node).attr("href"));
        if (url) {
          $.ajax({
            type: "GET",
            url: url,
            data: {apikey: TREE.option.apikey, include: "prefLabel,childrenCount", no_context: true},
            crossDomain: true,
            contentType: 'json',
            timeout: TREE.option.timeout,
            success: function(response) {
              var nodes = TREE.formatNodes(response.collection)
              node.removeAttr('class');
              node.html(nodes);
              $.extend(node, {url:url});
              TREE.setTreeNodes(node, true);
              if (typeof TREE.option.afterExpand == 'function') {
                TREE.option.afterExpand(node);
              }
              TREE_CONTAINER.trigger("afterExpand", node);
              if (typeof successCallback == 'function') {
                successCallback(node);
              }
            },
            error: function(response) {
              if (typeof TREE.option.afterExpandError == 'function') {
                TREE.option.afterExpandError(node);
              }
              if (typeof errorCallback == 'function') {
                errorCallback(node);
              }
              TREE_CONTAINER.trigger("afterExpandError", node);
            }
          });
        }
      };

      TREE.setTreeNodes = function(obj, useParent) {
        obj = useParent ? obj.parent() : obj;
        $('li>a', obj).addClass('text').bind('selectstart', function() {
          return false;
        }).click(function(){
          var parent = $(this).parent();
          var selectedNode = $(this);
          $('.active', TREE).attr('class', 'text');
          if (this.className == 'text') {
            this.className = 'active';
          }
          if (typeof TREE.option.afterSelect == 'function') {
            TREE.option.afterSelect(decodeURIComponent(selectedNode.data("id")), selectedNode.text(), selectedNode);
          }
          TREE_CONTAINER.trigger("afterSelect", [decodeURIComponent(selectedNode.data("id")), selectedNode.text(), selectedNode]);
          return false;
        }).bind("contextmenu",function(){
          $('.active', TREE).attr('class', 'text');
          if (this.className == 'text') {
            this.className = 'active';
          }
          if (typeof TREE.option.afterContextMenu == 'function') {
            TREE.option.afterContextMenu(parent);
          }
          return false;
        }).mousedown(function(event) {
          mousePressed = true;
          cloneNode = $(this).parent().clone();
          var LI = $(this).parent();
          return false;
        });

        $('li', obj).each(function(i) {
          var className = this.className;
          var open = false;
          var cloneNode=false;
          var LI = this;
          var childNode = $('>ul',this);
          if (childNode.size() > 0){
            var setClassName = 'folder-';
            if (className && className.indexOf('open') >= 0) {
              setClassName = setClassName + 'open';
              open = true;
            } else {
              setClassName = setClassName+'close';
            }
            this.className = setClassName + ($(this).is(':last-child') ? '-last' : '');

            if (!open || className.indexOf('ajax') >= 0)
              childNode.hide();

            TREE.setTrigger(this);
          } else {
            var setClassName = 'doc';
            this.className = setClassName + ($(this).is(':last-child') ? '-last' : '');
          }
        }).before('<li class="line">&nbsp;</li>')
          .filter(':last-child')
          .after('<li class="line-last"></li>');
      };

      TREE.setTrigger = function(node) {
        $('>a',node).before('<img class="trigger" src="data:image/gif;base64,R0lGODlhAQABAID/AMDAwAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==" border=0>');
        var trigger = $('>.trigger', node);
        trigger.click(function(event){
          TREE.nodeToggle(node);
        });
        // TODO: $.browser was removed in jQuery 1.9, check IE compatability
        // if (!$.browser.msie) {
        //   trigger.css('float','left');
        // }
      };

      TREE.checkNodeIsLast = function(node) {
        if (node.className.indexOf('last')>=0) {
          node.className = node.className.replace('-last','');
        }
      };

      TREE.checkLineIsLast = function(line) {
        if (line.className.indexOf('last')>=0) {
          var prev = $(line).prev();
          if (prev.size() > 0) {
            prev[0].className = prev[0].className.replace('-last','');
          }
          dragNode_source[0].className+='-last';
        }
      };

      TREE.convertToFolder = function(node) {
        node[0].className = node[0].className.replace('doc','folder-open');
        node.append('<ul><li class="line-last"></li></ul>');
        TREE.setTrigger(node[0]);
        TREE.setEventLine($('.line, .line-last', node));
      };

      TREE.convertToDoc = function(node) {
        $('>ul', node).remove();
        $('img', node).remove();
        node[0].className = node[0].className.replace(/folder-(open|close)/gi , 'doc');
      };

      TREE.addNode = function(id, text, link, callback) {
        var temp_node = $('<li><ul><li id="'+id+'"><a href="'+link+'">'+text+'</a></li></ul></li>');
        TREE.setTreeNodes(temp_node);
        dragNode_destination = TREE.getSelected();
        dragNode_source = $('.doc-last',temp_node);
        TREE.moveNodeToFolder(dragNode_destination);
        temp_node.remove();
        if (typeof(callback) == 'function') {
          callback(dragNode_destination, dragNode_source);
        }
      };

      TREE.delNode = function(callback) {
        dragNode_source = TREE.getSelected();
        TREE.checkNodeIsLast(dragNode_source[0]);
        dragNode_source.prev().remove();
        dragNode_source.remove();
        if (typeof(callback) == 'function') {
          callback(dragNode_destination);
        }
      };

      // Populate roots and init tree
      TREE.init = function() {
        if (TREE.option.startingClass !== null) {
          TREE.jumpToClass(TREE.option.startingClass);
          TREE.option.startingClass = null;
        } else {
          $.ajax({
            url: TREE.option.ncboAPIURL + "/ontologies/" + TREE.option.ontology + "/classes/" + encodeURIComponent(TREE.option.startingRoot),
            data: {apikey: TREE.option.apikey, include: "prefLabel,childrenCount", no_context: true},
            contentType: 'json',
            crossDomain: true,
            success: function(roots){
              // Flatten potentially nested arrays
              roots = $.map([roots], function(n){
                return n;
              });
              ROOT.append(TREE.formatNodes(roots));
              TREE.setTreeNodes(ROOT, false);
            }
          });
        }
      };
    }

    // Returns the original object(s) so they can be chained
    return this.each(function() {
      var $this = this;

      // Add the autocomplete code
      $.ajax({
        url: TREE.option.ncboUIURL.replace("http:", ('https:' == document.location.protocol ? 'https:' : 'http:')) + "/widgets/jquery.ncbo.autocomplete.js",
        type: "GET",
        crossDomain: true,
        dataType: "script",
        success: function(){
          setupTree($this, TREE, TREE.option);
          TREE.init();
        }
      });
    });
  }
}(jQuery));