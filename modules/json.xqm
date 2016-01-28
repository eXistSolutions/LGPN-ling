xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

let $case := request:get-parameter('type', 'names')
return
switch ($case)
case 'morphemes'
    return
        let $collection := $config:taxonomies-root || "/morphemes.xml"
        for $n in doc($collection)//tei:category/@baseForm
            return $n/string()
case 'places'
    return
        let $collection := $config:lgpn-places
        for $n in doc($collection)//tei:place/tei:placeName[1]
            return $n/string()
case 'settlements'
    return
        let $collection := $config:lgpn-places
        for $n in doc($collection)//tei:place[@type='settlement']/tei:placeName[1]
            return $n/string()
case 'regions'
    return
        let $collection := $config:lgpn-places
        for $n in doc($collection)//tei:place[@type='region']/tei:placeName[1]
            return $n/string()
default
    return
        let $collection := $config:taxonomies-root || "/ontology.xml"
        for $n in doc($collection)//tei:category/@xml:id
            return $n/string()