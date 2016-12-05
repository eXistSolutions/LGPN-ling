xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
let $id := 'Αgestos'

    for $name in collection("/db/apps/lgpn-ling-data/data/names")//tei:entry
(:    /tei:entry[@xml:id=$id]:)
    let $fname := 'function'

    let $preroot := $name//tei:m[@type='prefix']
    let $prerootV := $name//tei:m[@type='prefix']/string()
    let $root := $name//tei:m[@type='radical']
    let $gramGrp := $name//tei:gramGrp

return 
    (
        $name
        ,
        update insert attribute {$fname} {''} into $preroot,
        update insert attribute ana {''} into $preroot,
        update insert attribute subtype {''} into $preroot,
        update insert attribute ana {''} into $root,
        update insert attribute subtype {''} into $root,
        update insert attribute ana {''} into $gramGrp,
        update insert attribute type {''} into $gramGrp
)

