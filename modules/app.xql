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

declare
    %templates:default("lang", 'en')

function app:about($node as node(), $model as map(*), $lang as xs:string) {
    let $path:=$config:app-root || "/data/articles/about-" || $lang || ".html"
    return doc($path)
};

declare
function app:column-order($node as node(), $model as map(*)) {
    let $user := request:get-attribute("org.exist.lgpn-ling.user")
    let $number :=
        if ($user) then 18 else 17
    let $otherNumber :=
        if ($user) then 2 else 1

    return        
                <script type="text/javascript">
        var firstSort={$number};
        var secondSort={$otherNumber};
        </script>

};

declare
function app:login-status($node as node(), $model as map(*), $loginStatus as xs:string?) {
    if($loginStatus='failed') then 
    <div class="row" data-template="app:entries">
        <div class="alert alert-danger col-sm-6">
            <strong>Login required</strong> to edit data!
        </div>
    </div>
    else ()
};


declare
function app:delete-name($node as node(), $model as map(*), $delete as xs:string?) {
    if($delete) then 
        <div class="row">
            <div class="alert alert-danger col-sm-6">
                <strong>{app:delete-entry($delete)}</strong>!
            </div>
        </div>
    else ()
};


declare
function app:delete-entry($id as xs:string?) {
    let $entry := collection($config:names-root)//TEI:entry/id($id)[1]
    let $del := if($entry) then xmldb:remove(util:collection-name($entry), util:document-name($entry)) else ('fail')
    return if($del='fail') then ('Failed to delete ', <strong>{$id}</strong>) else (<strong>{$id}</strong>, ' deleted')
};

declare
    %templates:wrap
function app:check-login($node as node(), $model as map(*)) {
    let $user := request:get-attribute("org.exist.lgpn-ling.user")
    return
        if ($user) then
            templates:process($node/*[2], $model)
        else
            templates:process($node/*[1], $model)
};


declare function app:entries-header($node as node(), $model as map(*), $type as xs:string?) {
    let $user := request:get-attribute("org.exist.lgpn-ling.user")
    let $action := if($type='delete') then 
                    <span class="glyphicon glyphicon-trash"/>
                else 
                    <span class="glyphicon glyphicon-edit"/>
    return
        if($user) then
            <th>
                {$action}
            </th>
                else ()
};
declare
    %templates:wrap
function app:current-user($node as node(), $model as map(*)) {
    request:get-attribute("org.exist.lgpn-ling.user")
};

declare
    %templates:wrap
function app:show-if-logged-in($node as node(), $model as map(*)) {
    let $user := request:get-attribute("org.exist.lgpn-ling.user")
    return
        if ($user) then
            templates:process($node/node(), $model)
        else
            ()
};


declare function app:lang($node as node(), $model as map(*), $lang as xs:string?) {
        session:create(),
        let $lang := session:set-attribute('lang', $lang)
(:        let $c := console:log('lang aft ' || session:get-attribute('lang')):)
        return $model
};

declare function app:entries($node as node(), $model as map(*)) {
    let $entries :=
(:    for $i in collection($config:names-root)//TEI:entry[starts-with(.//TEI:orth[@type='latin'], 'A')]//TEI:gramGrp:)
    for $i in collection($config:names-root)//TEI:gramGrp
    order by $i/parent::TEI:entry//TEI:orth[@type='greek'][1]
        return $i
    
    return
    map { "entries" := $entries }
};

declare
    %templates:replace
    %templates:default("start", 1)
    %templates:default("max", 10)
function app:entries-each($node as node(), $model as map(*)) {
    for $entry in $model("entries")
    return 
        <tr>
        {templates:process($node/node(), map:new(($model, map { "entry" := $entry })))}
        </tr>
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
    let $entry := $model?entry
    return data($entry/parent::TEI:entry/@xml:id)
};

declare
 %templates:wrap
function app:entry-updated($node as node(), $model as map(*)) {
    let $entry := $model?entry
    let $updated := if($entry) then xmldb:last-modified(util:collection-name($entry), util:document-name($entry)) else ()
    return <span>{substring-before($updated, 'T')}<span class="invisible">{$updated}</span></span>
(:    return max($entry/ancestor::TEI:TEI//TEI:change/@when/string()):)
};

declare
    %templates:wrap
function app:entry-form($node as node(), $model as map(*), $langId as xs:string) {
    let $entry := $model?entry
    let $pos := count($entry/preceding-sibling::TEI:gramGrp)
    let $bold := if ($langId='greek') then 'font-weight: bold;' else ()
    let $first :=  if ($pos) then 'dimmed' else () 

    let $content := data($entry/parent::TEI:entry//TEI:orth[@type=$langId][1])
    let $variant := if($langId='variant') 
        then 
            <span class="invisible">{replace($entry/parent::TEI:entry//TEI:orth[@type='variant'][1], "(\(\w*\))", "")}</span> 
        else 
            ()

    return 
        <span>
            {attribute style {$bold}}
            {attribute class {$first}}
            {$variant}
            <span class="invisible">{replace(normalize-unicode($content, 'NFD'), '[\p{M}\p{Sk}]', '')}</span>
            {$content}
        </span>
};

declare
    %templates:wrap

function app:entry-stripped($node as node(), $model as map(*), $lang as xs:string) {
    let $entry := $model?entry
    return replace(normalize-unicode($entry/parent::TEI:entry//TEI:orth[@type=$lang]/string(), 'NFD'), '[\p{M}\p{Sk}]', '')
};

declare
    %templates:wrap
    %templates:default("lang", 'en')
function app:entry-dialect($node as node(), $model as map(*), $lang as xs:string?) {
    let $pos := count($model?entry/preceding-sibling::TEI:gramGrp)
    let $labels := tokenize($model?entry/parent::TEI:entry//TEI:usg, '\s+')
    let $dialects :=
    
        for $e in doc($config:taxonomies-root || "/dialects.xml")//id($labels)/TEI:catDesc[@ana="full"][@xml:lang=$lang]
        return $e
    
    let $content:= string-join($dialects, ', ')
    return 
        if($pos) then <span class="invisible">{$content}</span> else $content
};

declare
 %templates:wrap
function app:entry-attestations($node as node(), $model as map(*)) {
    let $pos := count($model?entry/preceding-sibling::TEI:gramGrp)
    let $name := $model?entry/parent::TEI:entry//TEI:orth[@type='greek']
    let $content:= count(doc($config:lgpn-volumes)//TEI:persName[@type="main"][.=$name]/parent::TEI:person)
    return 
        if($pos) then <span class="invisible">{$content}</span> else $content
};

declare
 %templates:wrap
function app:entry-period($node as node(), $model as map(*)) {
    let $pos := count($model?entry/preceding-sibling::TEI:gramGrp)
    let $name := $model?entry/parent::TEI:entry//TEI:orth[@type='greek']
    let $dates :=(
        min(doc($config:lgpn-volumes)//TEI:persName[@type="main"][.=$name]/parent::TEI:person/TEI:birth/@notBefore[string(.)][string(.)!='-0999']),
        max(doc($config:lgpn-volumes)//TEI:persName[@type="main"][.=$name]/parent::TEI:person/TEI:birth/@notAfter[string(.)][string(.)!='0999']))
    let $content := if(count($dates)) then string-join($dates, '/') else '?'
    return 
        if($pos) then <span class="invisible">{$content}</span> else $content
};

declare
 %templates:wrap
function app:entry-gender($node as node(), $model as map(*)) {
    let $pos := count($model?entry/preceding-sibling::TEI:gramGrp)
    let $name := $model?entry/parent::TEI:entry//TEI:orth[@type='greek']
    let $genders :=
        for $g in distinct-values(doc($config:lgpn-volumes)//TEI:persName[@type="main"][.=$name]/parent::TEI:person/TEI:sex/@value/string())
        return if (number($g)=2) then "f." else "m."
    let $content:= string-join($genders, '|')
    return 
        if($pos) then <span class="invisible">{$content}</span> else $content
};

declare
    %templates:wrap
function app:entry-morpheme($node as node(), $model as map(*), $type as xs:string, $position as xs:integer?) {
           (:  content of preceding/following gramGrp made invisible to make
           sure even after sorting/filtering the rows from same name stay together:)
        (
            for $e in $model?entry/preceding-sibling::TEI:gramGrp
            return app:morpheme($e, 1, $type, $position)
        ,
            app:morpheme($model?entry, 0, $type, $position)
        ,
            for $e in $model?entry/following-sibling::TEI:gramGrp
            return app:morpheme($e, 1, $type, $position)
        )
};

declare function app:morpheme($entry as node(), $invisible as xs:integer, $type as xs:string, $position as xs:integer?) {
        let $bold := if ($type='radical' or $position=1) then 'font-weight: bold;' else ()
        let $first :=  if (count($entry/preceding-sibling::TEI:gramGrp)) then 'dimmed' else () 
    
        let $class := if ($invisible) then 'invisible' else $first
    return <span>
        {attribute style {$bold}}
        {attribute class {$class}}
        {
            if($type!="suffix") then 
                data(doc($config:taxonomies-root || "/morphemes.xml")//TEI:category[@baseForm=$entry//TEI:m[@type=$type][@n=$position]/@baseForm]/TEI:catDesc) 
            else 
                data($entry//TEI:m[@type=$type][@n=$position])
        }
        </span>
};

declare
    %templates:wrap
function app:entry-morpheme-functions($node as node(), $model as map(*), $type as xs:string) {
           (:  content of preceding/following gramGrp made invisible to make
           sure even after sorting/filtering the rows from same name stay together:)
        (
            for $e in $model?entry/preceding-sibling::TEI:gramGrp
            return app:morpheme-functions($e, 1, $type)
        ,
            app:morpheme-functions($model?entry, 0, $type)
        ,
            for $e in $model?entry/following-sibling::TEI:gramGrp
            return app:morpheme-functions($e, 1, $type)
        )
};

declare function app:morpheme-functions($entry as node(), $invisible as xs:integer, $type as xs:string) {
    let $first :=  if (count($entry/preceding-sibling::TEI:gramGrp)) then 'dimmed' else () 
    let $class := if ($invisible) then 'invisible' else $first
(:   combining following two lines into one results in false positives returned, see low hypothesis for Alketēs,
 : https://github.com/eXistSolutions/LGPN-ling/issues/300
     let $typeMorphemes:= $entry/descendant-or-self::TEI:m[@type='radical']
: 	:)
    let $typeMorphemes := $entry//TEI:m
    let $typeMorphemes:= $typeMorphemes/descendant-or-self::TEI:m[@type=('prefix', 'radical')]
    let $functions := 
                for $e in $typeMorphemes/@function[string(.)]
                order by $e/@n
                return $e
    
    let $labels := doc($config:dictionaries-root || '/classification.xml')
    let $morphemes := for $m in $typeMorphemes return 
        ($m/@subtype, if(string($m/@ana)) then $m/@ana else ())
    let $headedness := string-join(($morphemes , $labels//id($entry/@type)), '')
    let $other := $entry/@ana
    let $parens := if(string($headedness) or string($other)) then '(' || string-join(($headedness, if(string($other)) then $other else ()), ' ') || ')' else ()
    return 
        <span>
            {attribute class {$class}}
            {string-join($functions, '-')}
            {if($parens) then (<br/>, $parens) else ()}
        </span>
};

declare
    %templates:wrap
    %templates:default("lang", 'en')
function app:entry-semantics($node as node(), $model as map(*), $lang as xs:string?) {
           (:  content of preceding/following gramGrp made invisible to make
           sure even after sorting/filtering the rows from same name stay together:)
        (
            for $e in $model?entry/preceding-sibling::TEI:gramGrp
            return app:semantics($e, 1, $lang)
        ,
            app:semantics($model?entry, 0, $lang)
        ,
            for $e in $model?entry/following-sibling::TEI:gramGrp
            return app:semantics($e, 1, $lang)
        )
};

declare function app:semantics($entry as node(), $invisible as xs:integer, $lang as xs:string) {
    let $first :=  if (count($entry/preceding-sibling::TEI:gramGrp)) then 'dimmed' else () 

    let $class := if ($invisible) then 'invisible' else $first
    let $functions := 
            for $bf in $entry//TEI:m[@type=('radical', 'prefix')]/@baseForm[string(.)]
                let $concept :=
                    for $m in tokenize(doc($config:taxonomies-root || "/morphemes.xml")//TEI:category[@baseForm=$bf]/@ana, '\s*#')
                    return doc($config:taxonomies-root || "/ontology.xml")//TEI:category[@xml:id=$m]/TEI:catDesc[@xml:lang=$lang]
            return string-join($concept, ', ')
    return
        <span>
            {attribute class {$class}}
            {string-join($functions, '+')}
        </span>
};

declare function app:reference-entry($entry, $type) {
    let $q := if($type='cit')
        then <i style="margin-right: 0.5em;">{$entry/TEI:quote/string()}</i>
        else ()

    let $author := if ($entry//TEI:author/string()) then $entry//TEI:author/string() || ' ' else ()
    let $ref := <i style="margin-right: 0.5em;">{$entry/TEI:ref/string()}</i>
    let $rest := $entry/TEI:span/string()
    let $source := 
        if ($entry/TEI:ref/string(@target)) 
            then <a href="{$entry/TEI:ref/@target}">{$author}{$ref} {$rest}</a> 
            else ($author, $ref, $rest)
    return ($q, $source)    
};

declare
%templates:wrap
function app:entry-bibl($node as node(), $model as map(*), $type as xs:string) {
    let $pos := count($model?entry/preceding-sibling::TEI:gramGrp)
    let $content := 
        for $e in $model?entry/parent::TEI:entry//TEI:bibl
(:        [@type='linguistic']:)
            let $source := app:reference-entry($e, 'bibl')
        return if ($e/@type='linguistic') then <p>{$source}</p> else ()
    return 
        if($pos) then <span class="invisible">{$content}</span> else $content
};

declare
%templates:wrap
function app:entry-sources($node as node(), $model as map(*), $type as xs:string) {
    let $pos := count($model?entry/preceding-sibling::TEI:gramGrp)

    (: sources :)
    let $sources := 
        for $e in $model?entry/parent::TEI:entry//TEI:cit[string(.)]
        let $source := app:reference-entry($e, 'cit')
        return <p>{$source}</p>

    (: lexicographic references :)
    let $lexicographic := 
        for $e in $model?entry/parent::TEI:entry//TEI:bibl[string(.)]
(:        [@type='auxiliary']:)
            let $source := app:reference-entry($e, 'bibl')
        return if ($e/@type='auxiliary') then <p>{$source}</p> else ()
    let $cf := if(not(empty($sources))) then 'Cf. ' else ()
    let $content := ($sources, if(not(empty($lexicographic))) then  ($cf, $lexicographic) else ())
    return 
        if($pos) then <span class="invisible">{$content}</span> else $content
};


declare
function app:entry-action($node as node(), $model as map(*), $action as xs:string?) {
    let $user := request:get-attribute("org.exist.lgpn-ling.user")
    return
        if ($user) then
    
    let $entry := $model?entry
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
            <form method="POST" action="">
                <input type="hidden" name="delete" value="{data($entry/parent::TEI:entry/@xml:id)}"/>
                <button class="btn btn-xs btn-danger" type="submit" onClick="return window.confirm('Are you sure you want to delete {data($entry/parent::TEI:entry//TEI:orth[@type="greek"])}?')" data-title="Delete Name {data($entry/parent::TEI:entry//TEI:orth[@type="greek"])}">
                <i class="glyphicon glyphicon-trash"></i> Delete
                </button>
            </form>
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