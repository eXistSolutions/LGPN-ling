xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

(: returns non-TEI structure combining morphemes & their meanings for the purposes of editing both at once,
 :  gets separated and turned into proper TEI on save :)

let $id := request:get-parameter('id', '')
 
let $entry := collection($config:taxonomies-root)//TEI:taxonomy[@xml:id="morphemes"]/TEI:category[@baseForm=$id][1]
let $m := tokenize($entry/@ana, '\s*#')
let $padMeanings :=
 if(count($m) < 4) 
    then
        for $i in (1 to 4-count($m))
        let $c := console:log('pad meaning' || $i)
        return 
            <meaning label="blah">
                <translation xml:lang="fr"/>
                <translation xml:lang="en"/>
            </meaning>
    else
        ()

return    
<category xmlns="http://www.tei-c.org/ns/1.0" baseForm="{$id}">
    {
    for $meaning at $i in collection($config:taxonomies-root)//TEI:taxonomy[@xml:id="ontology"]/TEI:category[@xml:id=tokenize($entry/@ana, '\s*#')]
        return
            <meaning label="{$meaning/@xml:id/string()}">
                <translation xml:lang="fr">{$meaning/TEI:catDesc[@xml:lang="fr"]/string()}</translation>
                <translation xml:lang="en">{$meaning/TEI:catDesc[@xml:lang="en"]/string()}</translation>
            </meaning>
    }
    {for $m in $padMeanings return $m}
</category>