/*jslint vars: true, plusplus: true, devel: true, nomen: true, indent: 4, maxerr: 50 */
/*global $, window, document */

var autocompletes = {};
var ontology_autocompletes = {};
var constituent_autocompletes = {};

function _formatResult(term, container, query) {
    var markup = '';

    markup += "<table>";
    markup += "<tr>";
    markup += "<td>" + term.id + " </td>";
    markup += '<td style="padding-left: 10px;"> ' + term.value + "</td>";
    markup += "<tr>";
    markup += "</table>";

    return markup;
}


function _termFormatSelection(term) {
    "use strict";
    return term.value;
}


function destroyAutoComp(autocompletes) {
    
    console.log(autocompletes);
    "use strict";
    var key;
    //console.log("DESTROY");
    for (key in autocompletes) {
        if (autocompletes.hasOwnProperty(key)) {
            if (autocompletes[key] !== undefined) {
                $('#' + key).select2('destroy');
            }
        }
    }

    autocompletes = {};
}


function clearAndInitAutocompletes() {
    "use strict";
    destroyAutoComp(autocompletes);
    destroyAutoComp(ontology_autocompletes);
    destroyAutoComp(constituent_autocompletes);
    initAutoComp('autocomplete', "Search for a root", 'modules/meanings.xq', 'autocomplete-callback', autocompletes);
    initAutoComp('ontology_autocomplete', "Search for a meaning", 'modules/ontology.xq', 'ontology_autocomplete-callback', ontology_autocompletes);
    initAutoComp('constituent_autocomplete', "Search for a constituent", 'modules/constituents.xq', 'constituent_autocomplete-callback', constituent_autocompletes);
}


function initAutoComp(acLabel, phLabel, source, callbackLabel, ac) {
    "use strict";
    var scope = "input[data-function="+acLabel+"]"
    $(scope).each(function () {
        var autocomplete = $(this);
        var xformsID = autocomplete.prev('.xfInput').attr('id');
        var xformsInput = autocomplete.prev('.xfInput');

        
        
        if(xformsID !== undefined) {
            var xformsValue = xformsInput.find(".widgetContainer .xfValue").val();
            console.log("XFORMS-VALUE: " + xformsValue);
            autocomplete.val(xformsValue);

            autocomplete.select2({
                handler: undefined,
                name: meanings,
                placeholder: phLabel,
                minimumInputLength: 1,
                formatResult: _formatResult,
                formatSelection: _termFormatSelection,
                formatNoMatches: "<div>No matches</div>",
                dropdownCssClass: "bigdrop",
                allowClear: true,
                initSelection: function (element, callback) {
                    var term = $(element).val();
                    callback({value: term});
                },
                createSearchChoice: function (term) {
                    return {"id": "Create new entry ", "value": term};
                },
                id: function (object) {
                    return object.id;
                },
                escapeMarkup: function (m) {
                    return m;
                },
                ajax: {
                    url: source,
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
                    fluxProcessor.dispatchEventType(xformsID, callbackLabel, {
                        termValue: ''
                    })
                } else {
                    var thingy = null;
                    if (e.added !== undefined) {
                        console.log("helllo???");
                        thingy = e.added;
                    }
                    if (thingy !== null) {
                        console.log("CALBBACK:", xformsID);
                        fluxProcessor.dispatchEventType(xformsID, callbackLabel, {
                            termValue: thingy.value
                        });
                    }
                }
            });
            var autocomplete_id = xformsID + "AC";
            autocomplete.attr('id', autocomplete_id);
            ac[autocomplete_id] = autocomplete;
            console.log(ac);
        }
    });
}