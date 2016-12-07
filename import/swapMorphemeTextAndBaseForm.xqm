xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
let $id := 'Αgestos'

    for $prefix in collection("/db/apps/lgpn-ling-data/data/names")//tei:m[@type='prefix'][string(.)]

    let $txt := $prefix/string()
    let $base := $prefix/@baseForm
return 
    (
        $txt
        ,
        $base/string(),
        update value $prefix/@baseForm with $txt
)

