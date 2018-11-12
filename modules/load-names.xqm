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

declare function local:orderBy($index, $dir) {
    let $direction := if ($dir='desc') then ' descending' else ()
    (:let $c:= console:log($index):)

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

    (:let $c:= console:log($orderBy):)

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

let $search := request:get-parameter('search[value]', '')

let $search := if ($search ne '') then $search else ''
let $searchOptions := '<options><leading-wildcard>yes</leading-wildcard></options>'
let $recordsTotal := count(collection($config:names-root)//tei:gramGrp[@type='segmentation'])

let $start := number(request:get-parameter('start', 1))
let $length := number(request:get-parameter('length', 50))

let $end := if($length>0) then ($start + $length) else $recordsTotal

let $ordInd := request:get-parameter('order[0][column]', '1')
let $ordDir := request:get-parameter('order[0][dir]', 'asc')

let $draw := request:get-parameter('draw', '1')

let $offset := 0

let $qs := $search
(:replace(normalize-unicode($search, 'NFD'), "[\p{M}\p{Sk}]", ""):)

let $collection := if (string($qs)) then 
                        'collection($config:names-root)//tei:orth[ft:query(., "' || $qs || '*", ' || $searchOptions || ')]/ancestor::tei:entry//tei:gramGrp[@type="segmentation"]'
                    else 
                        'collection($config:names-root)//tei:gramGrp[@type="segmentation"]'

let $roff:=$offset+number($ordInd)
let $orderby := local:orderBy($offset+number($ordInd), $ordDir)

    let $query :=
    'for $i in ' || $collection ||
    ' order by ' || $orderby ||
    ' return $i'
  
(:  let $c:= console:log($query):)
    
    let $selection := util:eval($query)
    let $lang:=request:get-parameter('lang', 'fr')
    
    let $results :=
    for $i in subsequence($selection, $start, $end)
        return 
            names:entry($offset, $i)

    let $recordsFiltered := count($selection)

		return map {
			"draw" := $draw,
			"recordsTotal"    :=  $recordsTotal,
			"recordsFiltered" :=  $recordsFiltered,
			"data"            := if(count($results)>1) then $results else array{$results} 
		}