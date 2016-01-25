xquery version "3.0";

(: This script is used to load ontology ("meanings") data based on a baseForm.
 :)

declare namespace loc="http://www.existsolutions.com/apps/lgpn/reload-meanings";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";

let $data := request:get-data()
let $baseForm := string($data/*/@baseForm)
let $morphemes := doc($config:taxonomies-root || '/morphemes.xml')
let $ontology := doc($config:taxonomies-root || '/ontology.xml')
return
<tei:taxonomy xml:id="ontology">
{
    for $attr in $morphemes//tei:category[@baseForm=$baseForm]/@ana
    for $category-id in tokenize($attr, '\s*#')
    return
        $ontology//tei:category[@xml:id=$category-id]
}
</tei:taxonomy>
