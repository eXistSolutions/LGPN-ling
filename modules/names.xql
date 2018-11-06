xquery version "3.0";

module namespace names="http://www.existsolutions.com/apps/lgpn/names";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace i18n="http://exist-db.org/xquery/i18n/templates" at "i18n-templates.xql"; 
import module namespace functx = "http://www.functx.com";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare
function names:delete-name($node as node(), $model as map(*), $delete as xs:string?) {
    if($delete) then 
        <div class="row">
            <div class="alert alert-danger col-sm-6">
                <strong>{names:delete-entry($delete)}</strong>!
            </div>
        </div>
    else ()
};


declare
function names:delete-entry($id as xs:string?) {
    let $entry := collection($config:names-root)//TEI:entry/id($id)
    let $del := if($entry) then xmldb:remove(util:collection-name($entry), util:document-name($entry)) else ('fail')
    return if($del='fail') then ('Failed to delete ', <strong>{$id}</strong>) else (<strong>{$id}</strong>, ' deleted')
};

declare function names:entries($node as node(), $model as map(*)) {
    let $entries :=
    for $i in collection($config:names-root)//TEI:gramGrp[@type='segmentation']
    order by $i/parent::TEI:entry//TEI:orth[@type='greek']
        return $i
    
    return
    map { "entries" := $entries }
};

declare
 %templates:wrap
function names:entry-id($entry as node()) {
    data($entry/parent::TEI:entry/@xml:id)
};

declare
function names:entry-updated($entry as node()) {
    let $updated := if($entry) then xmldb:last-modified(util:collection-name($entry), util:document-name($entry)) else ()
    return <span>{substring-before($updated, 'T')}<span class="invisible">{$updated}</span></span>
(:    return max($entry/ancestor::TEI:TEI//TEI:change/@when/string()):)
};

declare
function names:entry-transliterated($entry as node(), $pos) {
    let $first :=  if ($pos) then 'dimmed' else () 

    let $content := data($entry/parent::TEI:entry//TEI:orth[@type='h-variant'])
    let $gpr := if ($entry/parent::TEI:entry//TEI:gramGrp[@type='classification']/TEI:gram[@type='GPR'][.='GPR']) 
                then
                    <span class="dimmed">GPR </span>
                else
                    ()
    let $fictitious := if ($entry/parent::TEI:entry//TEI:gramGrp[@type='classification']/TEI:gram[@type='fictitious'][.='fictitious']) 
                then
                    <span class="dimmed">fict. </span>
                else
                    ()
    let $relative := 
        for $re in $entry/parent::TEI:entry/TEI:re[string(.)]
            let $relation := $re//TEI:lbl/string() || ' of ' || $re//TEI:orth/string() 
            return <span class="relative"><br/>{$relation}</span>

    return 
        <span>
            {attribute class {$first}}
            {if ($pos) then () else $gpr}
            {$content}
            {if ($pos) then () else $fictitious}
            {if ($pos) then () else $relative}
        </span>
};

declare
function names:entry-nameVariants($entry as node(), $pos) {
    let $first :=  if ($pos) then 'dimmed' else () 

    let $bold := 'font-weight: bold;'

    let $content := data($entry/parent::TEI:entry//TEI:orth[@type='greek'])
    let $lgpn :=  if ($entry/parent::TEI:entry//TEI:orth[@type='lgpn'][string(.)])
        then 
            <span class="dimmed"><br/>{'{' || replace($entry/parent::TEI:entry//TEI:orth[@type='lgpn'], "(\(\w*\))", "") || '}' }</span> 
        else 
            ()

    return 
        <span>
            {attribute class {$first}}
            {attribute style {$bold}}
            {if ($pos <1) then $content else ()}
            {if ($pos <1) then $lgpn else ()}
        </span>
};

(:declare:)
(:function names:entry-stripped($entry as node(), $lang as xs:string) {:)
(:    replace(normalize-unicode($entry/parent::TEI:entry//TEI:orth[@type=$lang]/string(), 'NFD'), '[\p{M}\p{Sk}]', ''):)
(:};:)

declare
function names:entry-dialect($entry as node(), $lang as xs:string?, $pos) {
    let $first :=  if ($pos) then 'dimmed' else () 
    let $labels := $entry/parent::TEI:entry//TEI:gramGrp[@type='classification']/TEI:usg
    let $dialects_document_order := 
    for $l in $labels 
        return string-join((doc($config:taxonomies-root || "/dialects.xml")//TEI:category[@xml:id=$l]/TEI:catDesc[@ana="full"][@xml:lang='en'], if ($l/@cert="low") then '?' else ()), '')
    
(:    let $dialects :=:)
(:        for $e in doc($config:taxonomies-root || "/dialects.xml")//TEI:category[@xml:id=$labels]/TEI:catDesc:)
(:        (: filtering moved to output because otherwise an error occurs :):)
(:        return $e[@ana="full"][@xml:lang='en']:)
    
    return 
        if ($pos < 1) then
        <span>
            {attribute class {$first}}
            {string-join($dialects_document_order, ', ')}
        </span>
(:        if($pos) then <span class="invisible">{$content}</span> else $content:)
        else ()
};

declare
function names:entry-attestations($entry as node(), $pos) {
(:    let $pos := if ($pos > 1) then count($entry/preceding-sibling::TEI:gramGrp[@type='segmentation']) else 0:)

    let $name := $entry/parent::TEI:entry//TEI:orth[@type='greek']
    let $content := if ($name ne '' ) then count($config:persons//TEI:nym[@nymRef=$name]) else ''

    return 
        if($pos) then () else $content
};

declare 
function names:entry($offset, $i as node()) {
    let $lang:=request:get-parameter('lang', 'fr')
    let $pos := count($i/../TEI:gramGrp[@type='segmentation'][. << $i])
    return
        map:new( 
            (
                if($offset=0) then map:entry(0, names:entry-action($i, '', $pos)) else (),
                map:entry($offset+1, names:entry-transliterated($i, $pos)),
                map:entry($offset+2, names:entry-nameVariants($i, $pos)),
                map:entry($offset+3, names:entry-attestations($i, $pos)),
                map:entry($offset+4, names:entry-gender($i, $pos)),
                map:entry($offset+5, names:entry-dialect($i, $lang, $pos)),
                map:entry($offset+6, names:entry-period($i, $pos)),


                map:entry($offset+7, names:entry-morpheme($i, 'prefix', 1)),
                map:entry($offset+8, names:entry-morpheme($i, 'radical', 1)),
                map:entry($offset+9, names:entry-morpheme($i, 'radical', 2)),
                map:entry($offset+10, names:entry-morpheme($i, 'suffix', 4)),
                map:entry($offset+11, names:entry-morpheme($i, 'suffix', 3)),
                map:entry($offset+12, names:entry-morpheme($i, 'suffix', 2)),
                map:entry($offset+13, names:entry-morpheme($i, 'suffix', 1)),
                map:entry($offset+14, names:entry-morpheme-functions($i, 'radical')),
                map:entry($offset+15, names:entry-semantics($i, $lang)),
                map:entry($offset+16, names:entry-bibl($i, ('source', 'auxiliary'))),
                map:entry($offset+17, names:entry-bibl($i, ('linguistic', 'modern'))),
                map:entry($offset+18, names:entry-updated($i)),
                if($offset=0) then map:entry($offset+19, names:entry-action($i, 'delete', $pos)) else ()
            )
    ),
    for $v in $i/parent::TEI:entry//TEI:form[@type='variant']
            let $pos := count($i/../TEI:gramGrp[@type='segmentation'][. >> $i])


        return 
            if ($pos) then 
                (: skip variants for all but last hypothesis :)
                ()
            else
                names:variantEntry($offset, $v)

};

declare 
function names:variantEntry($offset, $i as node()) {
    let $lang:=request:get-parameter('lang', 'fr')
    return
        map:new( 
            (
                if($offset=0) then map:entry(0, '') else (),
                map:entry($offset+1, ''),
                map:entry($offset+2, <span class='dimmed'>{$i/TEI:orth/string()}</span>),
                map:entry($offset+3, ''),
                map:entry($offset+4, <span class='dimmed'>{$i/TEI:gen/string()}</span>),
                map:entry($offset+5, <span class='dimmed'>{
                string-join(
                    concat(doc($config:taxonomies-root || "/dialects.xml")//TEI:category[@xml:id=$i/TEI:usg]/TEI:catDesc[@ana="full"][@xml:lang='en'], if($i/TEI:usg/@cert = 'low') then '?' else '')
                    , ', ')}</span>),
                map:entry($offset+6, ''),


                map:entry($offset+7, ''),
                map:entry($offset+8, ''),
                map:entry($offset+9, ''),
                map:entry($offset+10, ''),
                map:entry($offset+11, ''),
                map:entry($offset+12, ''),
                map:entry($offset+13, ''),
                map:entry($offset+14, ''),
                map:entry($offset+15, ''),
                map:entry($offset+16, ''),
                map:entry($offset+17, ''),
                map:entry($offset+18, ''),
                if($offset=0) then map:entry($offset+19, '') else ()
            )
    )

};

declare
function names:entry-period($entry as node(), $pos) {
    let $name := $entry/parent::TEI:entry//TEI:orth[@type='greek']/string()
    let $dates :=(
        min(doc($config:lgpn-volumes)//TEI:persName[@type="main"][.=$name]/parent::TEI:person/TEI:birth/@notBefore[string(.)]),
        max(doc($config:lgpn-volumes)//TEI:persName[@type="main"][.=$name]/parent::TEI:person/TEI:birth/@notAfter[string(.)]))
    let $content := string-join($dates, '/')
    return 
        if($pos) then () else $content
};

declare
function names:entry-gender($entry as node(), $pos) {
    let $name := $entry/parent::TEI:entry//TEI:orth[@type='greek']
    let $genders :=
        for $g in distinct-values(doc($config:lgpn-volumes)//TEI:persName[@type="main"][.=$name]/parent::TEI:person/TEI:sex/@value/string())
        return if (number($g)=2) then "f." else "m."
    let $content:= string-join($genders, '|')
    return 
        if($pos) then <span class="invisible">{$content}</span> else $content
};

declare
function names:entry-morpheme($entry as node(), $type as xs:string, $position as xs:integer?) {
        let $bold := if ($type='radical') then 'font-weight: bold;' else ()
        let $class :=  if (count($entry/preceding-sibling::TEI:gramGrp[@type='segmentation'])) then 'dimmed' else () 
        let $morpheme := $entry//TEI:m[@type=$type][@n=$position]
        let $baseForm := $morpheme/@baseForm
        let $inflect := 
            if ($type eq 'suffix' and $position eq 1) then
                let $dict := doc($config:dictionaries-root || '/suffixes/suffix-1.xml')//*:option[*:base=$morpheme/string()]
                return 
                    <span>
                        <b><i>{$morpheme/string()} </i></b> <span>{$dict/*:add}</span>
                        <span style="font-size: 0.8em; margin-top: 0.7em; display: block;">{$dict/*:gen}</span>
                    </span>
            else <span>{data($morpheme)}</span>
    return <span>
        {attribute style {$bold}}
        {attribute class {$class}}
        {
            if($type!=("suffix") and $entry//TEI:m[@type=$type][@n=$position] ne '') then 
                data(doc($config:taxonomies-root || "/morphemes.xml")//TEI:category[@baseForm=$entry//TEI:m[@type=$type][@n=$position]/@baseForm]/TEI:catDesc) 
            else if ($type eq "suffix" and $position eq 1) then
                $inflect
            else 
                data($morpheme)

        }
        </span>
};

declare function names:prettyPrint-unattested($param) {
    if ($param = 'unattested') then '*' else ''
};

declare
function names:entry-morpheme-functions($entry as node(), $type as xs:string) {
    let $class :=  if (count($entry/preceding-sibling::TEI:gramGrp[@type='segmentation'])) then 'dimmed' else () 

(:   combining following two lines into one results in false positives returned, see low hypothesis for Alketēs,
 : https://github.com/eXistSolutions/LGPN-ling/issues/300
     let $typeMorphemes:= $entry/descendant-or-self::TEI:m[@type='radical']
: 	:)
    let $typeMorphemes := $entry//TEI:m
    let $typeMorphemes:= $typeMorphemes/descendant-or-self::TEI:m[@type!='suffix']
    let $functions := 
                for $e in $typeMorphemes/@function[string(.)]
                order by $e/@n
                return $e
    
    let $labels := doc($config:dictionaries-root || '/classification.xml')
    let $morphemes := for $m in $typeMorphemes return 
        ($m/@subtype, if (string($m/@ana)) then $m/@ana else ())
    let $headedness := string-join(($morphemes , $labels//id($entry/@type)), '')
    let $other :=  doc("/db/apps/lgpn-ling/resources/xml/classification.xml")//id($entry/@subtype)/string()
    let $parens := if(string($headedness) or string($other)) then string-join(($headedness, if(string($other)) then $other else ()), ' ') else ()
    let $compounds := for $m in $typeMorphemes/descendant-or-self::TEI:m[@corresp ne ''] return names:prettyPrint-unattested($m/@cert/string()) || $m/@corresp
    return 
        <span>
            {attribute class {$class}}
            {if (count($functions)) then <span style="font-weight: bold;">{string-join($functions, codepoints-to-string(8212))}</span> else ()}
            {if($parens) then (<br/>, $parens) else ()}
            {if(exists($compounds)) 
                then 
                    <span style="font-size: 0.8em;"><br/>e.g. {string-join($compounds, ', ')}</span>
                else ()}
        </span>
};


declare
function names:entry-semantics($entry as node(), $lang as xs:string?) {
    let $class :=  if (count($entry/preceding-sibling::TEI:gramGrp[@type='segmentation'])) then 'dimmed' else () 

    let $functions := 
            for $bf in $entry//TEI:m[@type=('radical', 'prefix')]/@baseForm[string(.)]
                let $concept :=
                    for $m in tokenize(doc($config:taxonomies-root || "/morphemes.xml")//TEI:category[@baseForm=$bf]/@ana, '\s*#')
                    return doc($config:taxonomies-root || "/ontology.xml")//TEI:category[@xml:id=$m]/TEI:catDesc[@xml:lang=$lang]
            return string-join($concept, ', ')
    return
        <span>
            {attribute class {$class}}
            {string-join($functions, '-')}
        </span>
};

declare function names:reference-entry($entry) {
    let $quote := $entry/TEI:quote
    let $author := if (string-length($entry//TEI:author)) then $entry//TEI:author else ()
    let $ref := $entry/TEI:ref
    let $rest := $entry/TEI:span

    let $source := 
        if ($entry/TEI:ref/string(@target)) 
            then <a href="{$entry/TEI:ref/@target}">{$author}<i>{$ref}</i> {$rest}</a> 
            else ($author, <i>{$ref}</i>, $rest)

    return <p>{$quote} {$source}</p>
};

declare 
function names:entry-bibl($entry as node(), $types as item()*) {
    let $pos := count($entry/preceding-sibling::TEI:gramGrp[@type='segmentation'])
    let $first :=  if ($pos) then 'dimmed' else () 

    let $refs := 
        for $t in $types
            return $entry//TEI:cit[@type=$t][string(.)]

    return
    <span>
        {attribute class {$first}}
        {
            for $e in $refs return names:reference-entry($e)
        }
    </span>
};


declare
function names:entry-action($entry as node(), $action as xs:string?, $pos) {
    let $user := request:get-attribute("org.exist.lgpn-ling.user")
    return
        if ($user) then
    
    let $action:=  if($action='delete') then 
        <div>
            <form method="POST" action="">
                <input type="hidden" name="delete" value="{data($entry/parent::TEI:entry/@xml:id)}"/>
                <button class="glyphicon glyphicon-trash btn btn-xs btn-danger" type="submit" onClick="return window.confirm('Are you sure you want to delete {data($entry/parent::TEI:entry//TEI:orth[@type="greek"])}?')" data-title="Delete Name {data($entry/parent::TEI:entry//TEI:orth[@type="greek"])}">
                 Delete
                </button>
            </form>
            </div>
        else   
            <a href="editor.xhtml?id={data($entry/parent::TEI:entry/@xml:id)}"><span class="glyphicon glyphicon-edit"/></a>
    return 
        <td>
        {
            if($pos) then
                ()
            else $action
        }
        </td>
    else
        ()
};
