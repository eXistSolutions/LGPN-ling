/* Keep track of semantic tag controls */
/*
 
 
var controls = {};
var tags;


$(document).ready(function () {
    "use strict";
    
    var semanticTags, dialectTags;
    
    $("#h-sem-on-1").change(function() {
        //alert( "Handler for .change() called." );
    });
    $("#h-sem-on-2").change(function() {
        //alert( "Handler for .change() called." );
    });
    $("#h-sem-on-3").change(function() {
        //alert( "Handler for .change() called." );
    });
    $("#h-sem-on-4").change(function() {
        //alert( "Handler for .change() called." );
    });
    
    / *
    $.ajax({
        url: 'resources/json/dialects.json',
        datatype: 'json'
    })
    .done(function( dialects ) {
        var xfControl, xfValue,htmlControl;
        xfControl = $('#x-dialects');
        htmlControl = $('.dialect_tags');
        xfValue = xfControl.find('.xfValue').val();
        htmlControl.val(xfValue);
        
        htmlControl.tagit({
            availableTags: dialects
        }).on('change', function (e) {
            var target = $(e.target)
            fluxProcessor.dispatchEventType('x-dialects', 'callback', {
                dialects: target.val()
            });
        });
    })
    .fail(function() {
        alert("Could not load dialect tags.")
    });
    * /
    $.ajax({
        url: 'modules/semantic.xql',
        dataType: 'json'
    })
    .done(function( sematics ) {
        console.log("sematics: ", sematics);
        tags = sematics;
        initSemantics();
    })
    .fail(function() {
        alert("Could not load sematic tags.")
    });
});

function destroySemantics() {
    for (key in controls) {
        if (controls.hasOwnProperty(key)) {
            if (controls[key] !== undefined) {
                $('#' + key).tagit('destroy');
            }
        }
    }
    
    controls = {};
};

function initSemantics() {
    $(".xfRepeatItem .semantic_tags").each(function () {
        var id, htmlControl, self, xfControl;
        
        self = $(this);
        xfControl = self.find(".xfInput");
        
        htmlControl = self.find(".tags");
        
        id = xfControl.attr('id');
        htmlID = id + 'tags';
        htmlControl.attr('id', htmlID)
        
        if (controls[htmlID] === undefined) {
            var xfValue;
            xfValue = xfControl.find('.xfValue').val();
            console.log('XFVALUE: ', xfValue);
            htmlControl.val(xfValue);
            htmlControl.attr('target', id);
            
            htmlControl.tagit({
                availableTags: tags
            }).on('change', function (e) {
                var target,targetid;
                target = $(e.target);
                targetid = target.attr('target');
                
                fluxProcessor.dispatchEventType(targetid, 'callback', {
                    semantics: target.val()
                });
            });
            controls[htmlID] = htmlID;
        }
    });
}


function clearAndInitSemantics() {
    destroySemantics();
    initSemantics();
}
*/