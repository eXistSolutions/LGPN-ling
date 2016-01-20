xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

let $case := request:get-parameter('type', 'names')
return
switch ($case)
case 'meanings'
    return
        let $collection := "/db/apps/lgpn-ling/data/taxonomies/ontology.xml"
        for $n in doc($collection)//tei:category/@xml:id
            return $n/string()
case 'places'
    return
        let $collection := "/db/apps/lgpn-data/data/volume0.places.xml"
        for $n in doc($collection)//tei:place/tei:placeName[1]
            return $n/string()
case 'settlements'
    return
        let $collection := "/db/apps/lgpn-data/data/volume0.places.xml"
        for $n in doc($collection)//tei:place[@type='settlement']/tei:placeName[1]
            return $n/string()
case 'regions'
    return
        let $collection := "/db/apps/lgpn-data/data/volume0.places.xml"
        for $n in doc($collection)//tei:place[@type='region']/tei:placeName[1]
            return $n/string()
default
    return
        let $collection := "/db/apps/lgpn-data/data/volume0.names.xml"
        for $n in doc($collection)//tei:form[@xml:lang="grc"]
            order by $n
            return $n/string()