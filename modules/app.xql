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
function app:entry-id($node as node(), $model as map(*)) {
    let $entry := $model("entry")
    return <td>{data($entry//TEI:entry/@xml:id)}</td>
};

declare
function app:entry-form($node as node(), $model as map(*), $lang as xs:string) {
    let $entry := $model("entry")
    return <td>{data($entry//TEI:entry//TEI:orth[@type=$lang])}</td>
};

declare
function app:entry-dialect($node as node(), $model as map(*)) {
    let $entry := $model("entry")
    return <td>{data($entry//TEI:entry/TEI:usg)}</td>
};


declare
function app:entry-morpheme($node as node(), $model as map(*), $type as xs:string, $position as xs:integer?) {
    let $entry := $model("entry")
    return <td>{data($entry//TEI:entry//TEI:m[@type=$type][@n=$position])}</td>
};


declare
function app:entry-morphemes($node as node(), $model as map(*), $type as xs:string) {
    let $entry := $model("entry")
    let $t := 
        for $e in $entry//TEI:entry//TEI:m[@type=$type]
        order by $e/@n
        return $e
    return <td>{string-join($t, ' - ')}</td>
};

declare
function app:entry-morpheme-functions($node as node(), $model as map(*), $type as xs:string) {
    let $entry := $model("entry")
    let $t := 
        for $e in $entry//TEI:entry//TEI:m[@type=$type]/@function
        order by $e/@n
        return $e
    return <td>{string-join($t, '+')}</td>
};


declare
function app:entry-semantics($node as node(), $model as map(*)) {
    let $entry := $model("entry")
    let $t := 
        for $e in $entry//TEI:entry//TEI:m[@type='radical']
        order by $e/@n
        return $e/@ana
    return <td>{string-join($t, '+')}</td>
};

declare
function app:entry-sources($node as node(), $model as map(*), $type as xs:string) {
    let $entry := $model("entry")
    (: sources :)
    let $sources := 
        for $e in $entry//TEI:entry//TEI:cit
          let $q := <i style="margin-right: 0.5em;">{$e/TEI:quote/string()}</i>
          let $s := $e/TEI:ref/string()
          let $source := if ($e/TEI:ref/string(@target)) then <a href="{$e/TEI:ref/@target}">{$s}</a> else $s
        return <p>{$q}  {$source}</p>
    (: lexicographic references :)
    let $lexicographic := 
        for $e in $entry//TEI:entry//TEI:bibl[@type='auxiliary']
          let $ref := <i style="margin-right: 0.5em;">{$e/TEI:ref/string()}</i>
          let $rest := $e/text()
          let $source := if ($e/TEI:ref/string(@target)) then <a href="{$e/TEI:ref/@target}">{$ref} {$rest}</a> else ($ref, $rest)
        return <p>{$source}</p>
    return <td>{$sources} {if(not(empty($lexicographic))) then  ('Cf. also ', $lexicographic) else ()}</td>
};

declare
function app:entry-bibl($node as node(), $model as map(*), $type as xs:string) {
    let $entry := $model("entry")
    let $linguistic := 
        for $e in $entry//TEI:entry//TEI:bibl[@type='linguistic']
          let $ref := <i style="margin-right: 0.5em;">{$e/TEI:ref/string()}</i>
          let $rest := $e/text()
          let $source := if ($e/TEI:ref/string(@target)) then <a href="{$e/TEI:ref/@target}">{$ref} {$rest}</a> else ($ref, $rest)
        return <p>{$source}</p>
    return <td>{$linguistic}</td>
};

declare
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