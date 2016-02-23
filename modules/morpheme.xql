xquery version "3.0";

module namespace morpheme="http://www.existsolutions.com/apps/lgpn/morpheme";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace i18n="http://exist-db.org/xquery/i18n/templates" at "i18n-templates.xql"; 
import module namespace functx = "http://www.functx.com";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute data-template="app:test" 
 : or class="app:test" (deprecated). The function has to take at least 2 default
 : parameters. Additional parameters will be mapped to matching request or session parameters.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)

declare
function morpheme:delete-status($node as node(), $model as map(*), $delete as xs:string?) {
    if($delete) then 
    (morpheme:delete-entry($delete),    
    <div class="row">
        <div class="alert alert-danger col-sm-6">
            <strong>Deleting </strong> {$delete}!
        </div>
    </div>)
    else ()
};


declare
function morpheme:delete-entry($id as xs:string?) {
(:let $id := request:get-parameter('id', ''):)
(: let $console := console:log($id):)
    let $entry := collection($config:names-root)//TEI:entry/id($id)[1]
    let $del := if($entry) then xmldb:remove(util:collection-name($entry), util:document-name($entry)) else ('failed to delete')
return $del
};

declare
    %templates:wrap
function morpheme:show-if-logged-in($node as node(), $model as map(*)) {
    let $user := request:get-attribute("org.exist.lgpn-ling.user")
    return
        if ($user) then
            templates:process($node/node(), $model)
        else
            ()
};

declare
    %templates:wrap
function morpheme:entries($node as node(), $model as map(*)) {
    let $entries :=
    for $i in doc($config:taxonomies-root || "/morphemes.xml")//TEI:category
    order by $i/@baseForm
        return $i
    return
    map { "entries" := $entries }
};


declare
 %templates:wrap
function morpheme:morpheme-baseForm($node as node(), $model as map(*)) {
    let $entry := $model("entry")
    return data($entry/@baseForm)
};
declare
 %templates:wrap
function morpheme:morpheme($node as node(), $model as map(*)) {
    let $entry := $model("entry")
    return data($entry)
};

declare
    %templates:wrap
    %templates:default("lang", 'en')
function morpheme:meanings($node as node(), $model as map(*), $lang as xs:string?) {
(:            morpheme:semantics($model?entry, 0, $lang):)
    let $entry := $model("entry")
    let $concepts :=
    for $m in tokenize($entry/@ana, '\s*#')
        return doc($config:taxonomies-root || "/ontology.xml")//TEI:category[@xml:id=$m]/TEI:catDesc[@xml:lang=$lang]
    return string-join($concepts, ', ')
};

declare
 %templates:wrap
function morpheme:count($node as node(), $model as map(*)) {
    let $entry := $model("entry")
    return count(collection($config:names-root)//TEI:m[@baseForm=$entry/@baseForm])
};

declare
function morpheme:entry-action($node as node(), $model as map(*), $action as xs:string?) {
    let $user := request:get-attribute("org.exist.lgpn-ling.user")
    return
        if ($user) then
    
    
    let $entry := $model("entry")
    let $pos := count($model?entry/preceding-sibling::TEI:gramGrp)
    let $action:=  if($action='delete') then 
        <div>
<!--
<form method="GET" action="?delete={data($entry/parent::TEI:entry/@xml:id)}" style="display:inline">
                <button class="btn btn-xs btn-danger" type="button" data-toggle="modal" data-target="#confirmDelete" data-title="Delete Name" data-message="Are you sure you want to delete this name?">
                <i class="glyphicon glyphicon-trash"></i> Delete via modal
                </button>
            </form>
<br/>
-->
            <a href="?delete={data($entry/parent::TEI:entry/@xml:id)}">
                <button class="btn btn-xs btn-danger" type="button" onClick="return window.confirm('Are you sure you want to delete {data($entry/parent::TEI:entry//TEI:orth[@type="greek"])}?')" data-title="Delete Name {data($entry/parent::TEI:entry//TEI:orth[@type="greek"])}">
                <i class="glyphicon glyphicon-trash"></i> Delete
                </button>
            </a>
            </div>
        else   
            <a href="editor.xhtml?id={data($entry/parent::TEI:entry/@xml:id)}"><span class="glyphicon glyphicon-edit"/></a>
    return 
        <td>
        {
            if(not($pos)) then
                $action
            else ()
        }
        </td>
    else
        ()
};