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
        <div class="row">
            <div class="alert alert-danger col-sm-6">
                {morpheme:delete-entry($delete)}
            </div>
        </div>
    else ()
};

declare
function morpheme:entry-action($node as node(), $model as map(*), $action as xs:string?) {
    let $user := request:get-attribute("org.exist.lgpn-ling.user")
    return
        if ($user) then
    let $entry := $model?entry?data
    let $a:=  if($action='delete') then 
        if ($model?entry?count) then 
            ()
        else
            <a href="?delete={$entry/@baseForm/string()}">
                <button class="btn btn-xs btn-danger" type="button" onClick="return window.confirm('Are you sure you want to delete {data($entry/@baseForm)}?')" data-title="Delete Name {data($entry)}">
                <i class="glyphicon glyphicon-trash"></i> Delete
                </button>
            </a>
        else   
            <a href="editor.xhtml?id={data($entry/@baseForm)}"><span class="glyphicon glyphicon-edit"/></a>
    return 
        <td>{$a}</td>
    else
        ()
};


declare
function morpheme:delete-entry($id as xs:string?) {
    let $del :=
        if (count($config:names-root//TEI:m[@baseForm=$id])) then 
            'fail'
        else
            update delete $config:taxonomies/id('morphemes')//TEI:category[@baseForm=$id]
            
    return 
        if ($del='fail') then 
            ('Failed to delete ', <strong>{$id}</strong>, ', references exist!') 
        else (<strong>{$id}</strong>, ' deleted')
};

declare
    %templates:wrap
function morpheme:entries($node as node(), $model as map(*)) {
    let $entries :=
        for $i in $config:taxonomies/id('morphemes')//TEI:category
        let $base := $i/@baseForm
        let $names := $config:names//TEI:m[@baseForm=$base]
        order by $base collation "?lang=gr-GR"
            return map {"data" := $i, "count" := count($names), "names" := $names}
    
    return
        map { "entries" := $entries }
};


declare
 %templates:wrap
function morpheme:morpheme-baseForm($node as node(), $model as map(*)) {
    let $entry := $model?entry?data
    return data($entry/@baseForm)
};
declare
 %templates:wrap
function morpheme:morpheme($node as node(), $model as map(*)) {
    let $entry := $model?entry?data
    return data($entry)
};

declare
    %templates:wrap
    %templates:default("lang", 'en')
function morpheme:meanings($node as node(), $model as map(*), $lang as xs:string?) {
(:            morpheme:semantics($model?entry, 0, $lang):)
    let $entry := $model?entry?data
    let $concepts :=
    for $m in tokenize($entry/@ana, '\s*#')
        return $config:taxonomies/id('ontology')/id($m)/TEI:catDesc[@xml:lang=$lang]
    return string-join($concepts, ', ')
};

declare
    %templates:wrap
    %templates:default("lang", 'en')
function morpheme:list-names($node as node(), $model as map(*), $lang as xs:string?) {
    
    for $n in $model?entry?names
        let $entry := $n/ancestor::TEI:entry
        order by $entry//TEI:orth[@type='greek']   collation "?lang=gr-GR"
        
        return <a href="editor.xhtml?id={$entry/@xml:id}">{$entry//TEI:orth[@type='greek']}</a>
};

declare
 %templates:wrap
function morpheme:count($node as node(), $model as map(*)) {
    $model?entry?count
};