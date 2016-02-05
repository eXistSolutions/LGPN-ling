xquery version "3.0";

module namespace app="http://www.existsolutions.com/apps/lgpn/templates";

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
declare %templates:wrap  function app:title($node as node(), $model as map(*)) {
    "LGPN-Ling"
};

declare function app:lang($node as node(), $model as map(*), $lang as xs:string?) {
        session:create(),
        let $lang := session:set-attribute('lang', $lang)
(:        let $c := console:log('lang aft ' || session:get-attribute('lang')):)
        return $model
};

declare function app:entries($node as node(), $model as map(*)) {
    let $entries :=
    for $i in collection($config:names-root)//TEI:TEI
    order by $i//TEI:entry//TEI:orth[@type='greek']
        return $i
    
    return
    map { "entries" := $entries }
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
function app:entry-form($node as node(), $model as map(*), $langId as xs:string) {
    let $entry := $model("entry")
    return 
        if($langId="greek") then
        <td><b>{data($entry//TEI:entry//TEI:orth[@type=$langId])}</b></td>
        else 
        <td>{data($entry//TEI:entry//TEI:orth[@type=$langId])}</td>
};


(:  :U+0300 – U+036F :)
declare
function app:entry-stripped($node as node(), $model as map(*), $lang as xs:string) {
    let $entry := $model("entry")
    return <td>{replace(normalize-unicode($entry//TEI:entry//TEI:orth[@type=$lang]/string(), 'NFD'), '[\p{M}]', '')}</td>
};

declare
    %templates:wrap
    %templates:default("lang", 'en')
function app:entry-dialect($node as node(), $model as map(*), $lang as xs:string?) {
    let $labels := tokenize($model?entry//TEI:usg, '\s+')
    let $dialects :=
    
        for $e in doc($config:taxonomies-root || "/dialects.xml")//TEI:category[@xml:id=$labels]/TEI:catDesc[@ana="full"][@xml:lang=$lang]
        return $e
    
    return string-join($dialects, ', ')
};

declare
function app:entry-period($node as node(), $model as map(*)) {
    let $entry := $model("entry")
    return <td>period</td>
};


declare
function app:entry-gender($node as node(), $model as map(*)) {
    let $entry := $model("entry")
    return <td>[m/f]</td>
};

declare
function app:entry-morpheme($node as node(), $model as map(*), $type as xs:string, $position as xs:integer?) {
    let $entry := $model("entry")
        let $subentries : = count($entry//TEI:entry//TEI:gramGrp)
        let $bold := if ($type='radical' or $position=1) then 'font-weight: bold;' else ()
    return <td>
        {attribute style {$bold}}
        {if($subentries > 1) then 
            <table>
                {
                    for $se in $entry//TEI:gramGrp
                    let $m := 
                        if($type="radical") then 
                            data(doc($config:taxonomies-root || "/morphemes.xml")//TEI:category[@baseForm=$se//TEI:m[@type=$type][@n=$position]/@baseForm]/TEI:catDesc) 
                        else data($se//TEI:m[@type=$type][@n=$position])
                    return <tr><td>{$m}&#160;</td></tr>

                }
            </table>
            else 
                    if($type="radical") then 
                        data(doc($config:taxonomies-root || "/morphemes.xml")//TEI:category[@baseForm=$entry//TEI:m[@type=$type][@n=$position]/@baseForm]/TEI:catDesc) 
                    else data($entry//TEI:m[@type=$type][@n=$position])
        }
        </td>
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
    let $entry := $model("entry")//TEI:gramGrp
                let $c := console:log($model?entry//TEI:orth[@type="latin"])
    let $functions := 
        for $se in $entry
            let $morph :=
            for $bf in $se//TEI:m[@type='radical']/@baseForm[string(.)]
                let $labels := tokenize(doc($config:taxonomies-root || "/morphemes.xml")//TEI:category[@baseForm=$bf]/TEI:catDesc/@ana, '\s*#')
            return  string-join($labels, ';') 
        return string-join($morph, '+')
    return 
        <td>
            {
                if (count($functions)>1) 
                then 
                    <table> 
                        {
                            for $f in $functions 
                            return <tr><td>{$f}</td></tr>
                        }
                    </table> 
                else $functions
            }
        </td>
};

declare
    %templates:default("lang", 'en')
function app:entry-semantics($node as node(), $model as map(*), $lang as xs:string?) {
    let $entry := $model("entry")//TEI:gramGrp
    let $functions := 
        for $se in $entry
            let $morph :=
            for $bf in $se//TEI:m[@type='radical']/@baseForm[string(.)]
                let $labels := tokenize(doc($config:taxonomies-root || "/morphemes.xml")//TEI:category[@baseForm=$bf]/@ana, '\s*#')

                let $concept :=
                    for $m in doc($config:taxonomies-root || "/ontology.xml")//TEI:category[@xml:id=$labels]/TEI:catDesc[@xml:lang=$lang]
                    order by $m
                    return $m
            return string-join($concept, ', ')
        return string-join($morph, '+')
    return 
        <td>
            {
                if (count($functions)>1) 
                then 
                    <table> 
                        {
                            for $f in $functions 
                            return <tr><td style="border: 0px solid black;">{$f}</td></tr>
                        }
                    </table> 
                else $functions
            }
        </td>
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
          let $rest := $e/TEI:span/string()
          let $source := if ($e/TEI:ref/string(@target)) then <a href="{$e/TEI:ref/@target}">{$ref} {$rest}</a> else ($ref, $rest)
        return <p>{$source}</p>
    return <td style="max-width: 200px;">{$sources} {if(not(empty($lexicographic))) then  ('Cf. also ', $lexicographic) else ()}</td>
};

declare
function app:entry-bibl($node as node(), $model as map(*), $type as xs:string) {
    let $entry := $model("entry")
    let $linguistic := 
        for $e in $entry//TEI:entry//TEI:bibl[@type='linguistic']
          let $ref := <i style="margin-right: 0.5em;">{$e/TEI:ref/string()}</i>
          let $rest := $e/TEI:span/string()
          let $source := if ($e/TEI:ref/string(@target)) then <a href="{$e/TEI:ref/@target}">{$ref} {$rest}</a> else ($ref, $rest)
        return <p>{$source}</p>
    return <td>{$linguistic}</td>
};

declare
function app:entry-action($node as node(), $model as map(*)) {
    let $entry := $model("entry")
    let $subentries : = count($entry//TEI:entry/TEI:gramGrp)
    return <td>
        <a href="editor.xhtml?id={data($entry//TEI:entry[1]/@xml:id)}"><span class="glyphicon glyphicon-edit"/></a>
        </td>
};


(:  LOGIN :)
declare function app:form-action-to-current-url($node as node(), $model as map(*)) {
    <form action="{request:get-url()}">{
        $node/attribute()[not(name(.) = 'action')], 
        $node/node()
    }</form>
};


declare function app:generate-dropdown-menu($node as node(), $model as map(*), $list as xs:string, $link as xs:string) {
    <ul class="dropdown-menu">
        {
            for $letter in functx:chars($list)
            return 
                <li>
                <a>
                    {attribute href {$link || '.html?letter=' || $letter }}
                    {$letter} 
                </a>
                </li>
        }
    </ul>  
};