xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

(: returns non-TEI structure combining morphemes & their meanings for the purposes of editing both at once,
 :  gets separated and turned into proper TEI on save :)
declare function local:newMorpheme($id) {
        <category xmlns="http://www.tei-c.org/ns/1.0" baseForm="{$id}">
            <catDesc>{$id}</catDesc>
            {local:padMeanings(3)}
        </category>
};

declare function local:padMeanings($number) {
    let $c := console:log('pad meaning' || $number)
    for $i in (1 to $number)
        return 
            <meaning label="" xmlns="http://www.tei-c.org/ns/1.0" >
                <translation xml:lang="fr"/>
                <translation xml:lang="en"/>
            </meaning>
};

let $id := request:get-parameter('id', '')
let $c := console:log('load ' || $id )
let $entry := collection($config:taxonomies-root)//TEI:taxonomy[@xml:id="morphemes"]/TEI:category[@baseForm=$id][1]

return    
    if ($entry) then
        <category xmlns="http://www.tei-c.org/ns/1.0" baseForm="{$id}">
            {$entry/TEI:catDesc}
            {
                let $meanings := tokenize($entry/@ana, '\s*#')
                return 
            (for $meaning at $i in collection($config:taxonomies-root)//TEI:taxonomy[@xml:id="ontology"]/TEI:category[@xml:id=$meanings]
                return
                    <meaning label="{$meaning/@xml:id/string()}">
                        <translation xml:lang="fr">{$meaning/TEI:catDesc[@xml:lang="fr"]/string()}</translation>
                        <translation xml:lang="en">{$meaning/TEI:catDesc[@xml:lang="en"]/string()}</translation>
                    </meaning>
                    ,
                    local:padMeanings(3+count($meanings)))
            }
        </category>
    else 
        local:newMorpheme($id)