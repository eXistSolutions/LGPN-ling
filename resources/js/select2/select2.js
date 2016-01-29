/*jslint vars: true, plusplus: true, devel: true, nomen: true, indent: 4, maxerr: 50 */
/*global $, window, document */

var autocompletes = {};
var ontology_autocompletes = {};

function _formatResult(term, container, query) {
    var markup = '';

    markup += "<table>";
    markup += "<tr>";
    markup += "<td>" + term.id + "</td>";
    markup += "<td>" + term.value + "</td>";
    markup += "<tr>";
    markup += "</table>";

    return markup;
}


function _termFormatSelection(term) {
    "use strict";
    return term.value;
}

function destroyAutocompletes() {
    
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

function destroyOntologyAutocompletes() {
    
    console.log(ontology_autocompletes);
    "use strict";
    var key;
    //console.log("DESTROY");
    for (key in ontology_autocompletes) {
        if (ontology_autocompletes.hasOwnProperty(key)) {
            if (ontology_autocompletes[key] !== undefined) {
                $('#' + key).select2('destroy');
            }
        }
    }

    ontology_autocompletes = {};
}


function clearAndInitAutocompletes() {
    "use strict";
    destroyAutocompletes();
    initAutocompletes();
    destroyOntologyAutocompletes();
    initOntologyAutocompletes();
}


function initAutocompletes() {
    "use strict";
    $("input[data-function='autocomplete']").each(function () {
        var autocomplete = $(this);
        var xformsID = autocomplete.prev('.xfInput').attr('id');

        
        if(xformsID !== undefined) {
            autocomplete.select2({
                handler: undefined,
                name: meanings,
                placeholder: "Search for a meaning",
                minimumInputLength: 1,
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
                    var thingy = null;
                    if (e.added !== undefined) {
                        console.log("helllo???");
                        thingy = e.added;
                    }
                    if (thingy !== null) {
                        console.log("CALBBACK:", xformsID);
                        fluxProcessor.dispatchEventType(xformsID, 'autocomplete-callback', {
                            termValue: thingy.value
                        });
                    }
                }
            });
            var autocomplete_id = xformsID + "AC";
            autocomplete.attr('id', autocomplete_id);
            autocompletes[autocomplete_id] = autocomplete;
            console.log(autocompletes);
        }
    });
}

function initOntologyAutocompletes() {
    "use strict";
    $("input[data-function='ontology_autocomplete']").each(function () {
        var autocomplete = $(this);
        var xformsID = autocomplete.prev('.xfInput').attr('id');

        
        if(xformsID !== undefined) {
            autocomplete.select2({
                handler: undefined,
                name: meanings,
                placeholder: "Search for a semantic concept",
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
                    url: "modules/ontology.xq",
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
                    fluxProcessor.dispatchEventType(xformsID, 'ontology_autocomplete-callback', {
                        termValue: ''
                    })
                } else {
                    object = null;
                    if (e.added !== undefined) {
                        object = e.added;
                    }
                    if (object !== null) {
                        fluxProcessor.dispatchEventType(xformsID, 'ontology_autocomplete-callback', {
                            termValue: object.value
                        });
                    }
                }
            });
            var autocomplete_id = xformsID + "AC";
            autocomplete.attr('id', autocomplete_id);
            ontology_autocompletes[autocomplete_id] = autocomplete;
            console.log(ontology_autocompletes);
        }
    });
}