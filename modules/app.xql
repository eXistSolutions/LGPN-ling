xquery version "3.0";

module namespace app="http://www.existsolutions.com/apps/lgpn/templates";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute data-template="app:test" 
 : or class="app:test" (deprecated). The function has to take at least 2 default
 : parameters. Additional parameters will be mapped to matching request or session parameters.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:title($node as node(), $model as map(*)) {
    "LGPN"
};


declare function app:entries($node as node(), $model as map(*)) {
    map { "entries" := collection($config:data-root)//TEI:TEI }
};

declare
    %templates:wrap
    %templates:default("start", 1)
    %templates:default("max", 10)
function app:entries-paged($node as node(), $model as map(*), $start as xs:integer, $max as xs:integer) {
    let $toDisplay := subsequence($model("entries"), $start, $max)
    return
        templates:process($node/node(), map:new(($model, map { "videos" := $toDisplay })))
};

declare
%templates:wrap
function app:entry-id($node as node(), $model as map(*)) {
    let $entry := $model("entry")
    return <td>{data($entry//TEI:entry/@xml:id)}</td>
};

declare
%templates:wrap
function app:entry-name($node as node(), $model as map(*)) {
    let $entry := $model("entry")
    return <td>{data($entry//TEI:entry/@xml:id)}</td>
};

declare
%templates:wrap
function app:entry-action($node as node(), $model as map(*)) {
    let $entry := $model("entry")
    return <td><a href="editor.xhtml?id={data($entry//TEI:entry[1]/@xml:id)}">EDIT</a></td>
};


(:  LOGIN :)
declare function app:form-action-to-current-url($node as node(), $model as map(*)) {
    <form action="{request:get-url()}">{
        $node/attribute()[not(name(.) = 'action')], 
        $node/node()
    }</form>
};