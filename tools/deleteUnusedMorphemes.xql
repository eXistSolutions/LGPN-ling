xquery version "3.1";

import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";


let $data := collection('/db/apps/lgpn-ling-data/data')
let $morphemes := $data/id('morphemes')/tei:category
        
for $entry in $morphemes
    let $names := $data//tei:m[@baseForm=$entry/@baseForm]
 
return
    if (count($names) > 0) then
       ()
    else 
        (<li>{$entry/@baseForm/string()}</li>
        ,  
            update delete $data/id('morphemes')//tei:category[@baseForm=$entry/@baseForm]
        )
    

