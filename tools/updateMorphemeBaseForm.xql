xquery version "3.1";

import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare namespace tei="http://www.tei-c.org/ns/1.0";

let $conv := 
<foo>
    <entry><from>κλεϝεσν</from><to>κλεϝεσνο</to></entry>
    <entry><from>κλεϝετ</from><to>κλεϝετο</to></entry>
</foo>
    
for $entry in $conv//entry
    let $from := $entry/from/string()
    let $to := $entry/to/string()
    
    let $c:= console:log('replace ' || $from || ' with ' ||  $to)
   
    return
    (
           $from, ' into ', $to, ' ', 
        for $i in collection('/db/apps/lgpn-ling-data/data/names')//tei:m/@baseForm[.=$from]
        return
        update replace $i with $to
    ,
        for $m in doc('/db/apps/lgpn-ling-data/data/taxonomies/morphemes.xml')//tei:category[@baseForm=$from]
        return 
        update replace $m/@baseForm with $to
    )