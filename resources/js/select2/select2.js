/*jslint vars: true, plusplus: true, devel: true, nomen: true, indent: 4, maxerr: 50 */
/*global $, window, document */

function _formatResult(term, container, query) {
    var markup = '';
    
    markup += "<table>";
    markup +=   "<tr>";
    markup +=     "<td>" + term.id + "</td>";
    markup +=     "<td>" + term.value + "</td>";
    markup +=   "<tr>";
    markup += "</table>";
    
    return markup;
};

function _termFormatSelection(term) {
    "use strict";
    return term.value;
}

$(document).ready(function () {
    $("input[data-function='autocomplete']").each(function () {
        var autocomplete = $(this);
        var xformsID = autocomplete.prev('.xfInput').attr('id');
        
        console.log("xformsID", xformsID)
        autocomplete.select2({
            handler: undefined,
            name:  meanings,
            placeholder: "Search for a meaning",
            minimumInputLength: 3,
            formatResult: _formatResult,
            formatSelection: _termFormatSelection,
            formatNoMatches: "<div>No matches</div>",
            dropdownCssClass: "bigdrop",
            allowClear: true,
            createSearchChoice: function (term) {
                return {"id": "-1", "value": "Add new entry."};
            },
            id: function (object) {
                return object.id;
            },
            escapeMarkup: function (m) {
                return m;
            },
            ajax: {
                url: "modules/meanings.xq",
                dataType: "json",
                crossDomain: true,
                data: function (term, page) {
                    return {
                        type: 'meanings',
                        query: term,
                        page_limit: 10,
                        page: page
                    };
                },
                results: function (data, page) {
                    var more = (page * 10) < data.total;
                    if (parseInt(data.total, 10) === 0) {
                        return {results: []};
                    }

                    if (Array.isArray(data.term)) {
                        return {results: data.term, more: more};
                    } else {
                        return {results: [data.term], more: more};
                    }
                }
            }
        }).on('change', function (e) {
            if ("" === e.val) {
                fluxProcessor.dispatchEventType(xformsID, 'autocomplete-callback', {
                    termValue: ''
                })
            } else {
                object = null;
                if (e.added !== undefined) {
                    object = e.added;
                }
                if (object !== null) {
                    fluxProcessor.dispatchEventType(xformsID, 'autocomplete-callback', {
                        termValue: object.value
                    });
                }
            }
        });
    });
});