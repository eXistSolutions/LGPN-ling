xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace names="http://www.existsolutions.com/apps/lgpn/names" at "names.xql";
import module namespace login="http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

(:draw=37:)
(:columns%5B0%5D%5Bdata%5D=0:)
(:columns%5B0%5D%5Bname%5D=:)
(:columns%5B0%5D%5Bsearchable%5D=true:)
(:columns%5B0%5D%5Borderable%5D=true:)
(:columns%5B0%5D%5Bsearch%5D%5Bvalue%5D=:)
(:columns%5B0%5D%5Bsearch%5D%5Bregex%5D=false:)
(:order%5B0%5D%5Bcolumn%5D=2:)
(:order%5B0%5D%5Bdir%5D=asc:)
(:start=0:)
(:length=50:)
declare function local:orderBy($index, $dir) {
    let $direction := if ($dir='desc') then ' descending' else ()
let $c:= console:log($index)

    let $orderBy :=
    switch($index)
    case 1
        return "$i/parent::tei:entry//tei:orth[@type='latin'][1]"
(:    case 8:)
(:        return "$i/parent::tei:entry//tei:m[@type='radical'][@n='1'][1]":)
    case 18
        return "root($i)//tei:change[last()]/@when"
    default
        return "root($i)//tei:change[last()]/@when"
(:        return 'replace($i/parent::tei:entry//tei:orth[@type="greek"][1],  "[\p{M}\p{Sk}]", "")' :)

let $c:= console:log($orderBy)

    let $collation:= 
        switch($index)
            case '2'
            case '8'
            case '9'
                return ' collation "?lang=el-grc&amp;amp;strength=primary&amp;amp;decomposition=standard"' 
            default 
                return ()
        
    return $orderBy || $direction || $collation
    
    
};

let $setuser :=  login:set-user("org.exist.lgpn-ling", (), false())
(:let $setuser := 'edouard':)

(:let $search := request:get-parameter('search', ''):)
let $search := if (request:get-parameter('search[value]', '')) then request:get-parameter('search[value]', '') else ''

let $recordsTotal := count(collection($config:names-root)//tei:gramGrp)

let $start := number(request:get-parameter('start', ''))
let $length := number(request:get-parameter('length', ''))

let $end := if($length>0) then ($start + $length) else $recordsTotal

let $ordInd := request:get-parameter('order[0][column]', '1')
let $ordDir := request:get-parameter('order[0][dir]', 'asc')

let $draw := request:get-parameter('draw', '1')

(:let $offset :=     if (request:get-attribute("org.exist.lgpn-ling.user")) then 0 else -1:)
let $offset := 0

let $c:=console:log('offset ' || $offset)

let $qs := normalize-unicode($search, "NFD")
let $collection := 'collection($config:names-root)//tei:orth[
        contains(normalize-unicode(., "NFD"), "'|| $qs || '") 
            or 
        contains(replace(normalize-unicode(., "NFD"), "[\p{M}\p{Sk}]", ""), "'|| $qs || '")
        ]/ancestor::tei:entry//tei:gramGrp'


let $roff:=$offset+number($ordInd)
let $c:=console:log($roff)
let $orderby := local:orderBy($offset+number($ordInd), $ordDir)

(:  let $c:= console:log($ordInd || ' ' || $ordDir):)


    let $query :=
    'for $i in ' || $collection ||
    ' order by ' || $orderby ||
    ' return $i'
  
  let $c:= console:log($query)
    
    let $selection := util:eval($query)
    let $lang:=request:get-parameter('lang', 'fr')
    
    let $results :=
    for $i in subsequence($selection, $start, $end)
        return 
    map:new( 
            (
                if($offset=0) then map:entry(0, names:entry-action($i, '')) else (),
                map:entry($offset+1, names:entry-form($i, 'h-variant')),
                map:entry($offset+2, names:entry-form($i, 'greek')),
                map:entry($offset+3, names:entry-attestations($i)),
                map:entry($offset+4, names:entry-gender($i)),
                map:entry($offset+5, names:entry-dialect($i, $lang)),
                map:entry($offset+6, names:entry-period($i)),

(:                map:entry($offset+7, names:entry-period($i)),:)
(:                map:entry($offset+8, names:entry-period($i)),:)
(:                map:entry($offset+9, names:entry-period($i)),:)
(:                map:entry($offset+10, names:entry-period($i)),:)
(:                map:entry($offset+11, names:entry-period($i)),:)
(:                map:entry($offset+12, names:entry-period($i)),:)
(:                map:entry($offset+13, names:entry-period($i)),:)

                
                map:entry($offset+7, names:entry-morpheme($i, 'prefix', 1)),
                map:entry($offset+8, names:entry-morpheme($i, 'radical', 1)),
                map:entry($offset+9, names:entry-morpheme($i, 'radical', 2)),
                map:entry($offset+10, names:entry-morpheme($i, 'suffix', 4)),
                map:entry($offset+11, names:entry-morpheme($i, 'suffix', 3)),
                map:entry($offset+12, names:entry-morpheme($i, 'suffix', 2)),
                map:entry($offset+13, names:entry-morpheme($i, 'suffix', 1)),
                map:entry($offset+14, names:entry-morpheme-functions($i, 'radical')),
                map:entry($offset+15, names:entry-semantics($i, $lang)),
                map:entry($offset+16, names:entry-sources($i)),
                map:entry($offset+17, names:entry-bibl($i)),
                map:entry($offset+18, names:entry-updated($i)),
                if($offset=0) then map:entry($offset+19, names:entry-action($i, 'delete')) else ()
            )
    )

let $recordsFiltered := count($selection)

		return map {
			"draw" := $draw,
			"recordsTotal"    :=  $recordsTotal,
			"recordsFiltered" :=  $recordsFiltered,
			"data"            := if(count($results)>1) then $results else array{$results} 
		}