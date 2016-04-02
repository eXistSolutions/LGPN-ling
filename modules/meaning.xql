xquery version "3.0";

module namespace meaning="http://www.existsolutions.com/apps/lgpn/meaning";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace i18n="http://exist-db.org/xquery/i18n/templates" at "i18n-templates.xql"; 
import module namespace functx = "http://www.functx.com";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

(:~
 : This is a module to handle browsing and deletion of ontology entries 
 : representing meanings of morphemes.
 :)

declare
function meaning:delete-status($node as node(), $model as map(*), $delete as xs:string?) {
    if($delete) then 
    <div class="row">
        <div class="alert alert-danger col-sm-6">
            {meaning:delete-entry($delete)}
        </div>
    </div>
    else ()
};

declare
function meaning:entry-action($node as node(), $model as map(*), $action as xs:string?) {
    let $user := request:get-attribute("org.exist.lgpn-ling.user")
    return
        if ($user) then
            let $entry := $model?entry
            let $a:=  
                if($action='delete') then 
                    let $count := count(collection($config:taxonomies-root)//TEI:category[contains(@ana, concat('#', $entry/@xml:id))])
                    return
                        if  ($count) then 
                            <span>{string-join(collection($config:taxonomies-root)//TEI:category[contains(@ana, concat('#', $entry/@xml:id))]/@baseForm, ', ')} ({$count})</span>
                        else
                            <a href="?delete={$entry/@xml:id/string()}">
                                <button class="btn btn-xs btn-danger" type="button" onClick="return window.confirm('Are you sure you want to delete {data($entry/@xml:id)}?')" data-title="Delete meaning {data($entry)}">
                                <i class="glyphicon glyphicon-trash"></i> Delete
                                </button>
                            </a>
                else   
                    ()
            return     <td>{$a}</td>
        else
            ()
};

declare
function meaning:delete-entry($id as xs:string?) {
    let $del :=
        if (count(collection($config:taxonomies-root)//TEI:category[contains(@ana, concat('#', $id))])) 
            then 'fail'
            else
                update delete doc($config:taxonomies-root || "/ontology.xml")//TEI:category[@xml:id=$id]
    return if($del='fail') then ('Failed to delete ', <strong>{$id}</strong>, ', references exist!') else (<strong>{$id}</strong>, ' deleted')
};

declare
    %templates:wrap
function meaning:entries($node as node(), $model as map(*)) {
    let $entries :=
    for $i in doc($config:taxonomies-root || "/ontology.xml")//TEI:category
    order by $i/@xml:id
        return $i
    return
    map { "entries" := $entries }
};


declare
 %templates:wrap
function meaning:meaning-id($node as node(), $model as map(*)) {
    data($model?entry/@xml:id)
};

declare
 %templates:wrap
function meaning:meaning($node as node(), $model as map(*), $language as xs:string?) {
    data($model?entry/TEI:catDesc[@xml:lang=$language])
};
