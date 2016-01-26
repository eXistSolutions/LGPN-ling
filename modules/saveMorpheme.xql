xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

let $data := request:get-data()
let $id := $data//TEI:category/@baseForm
(:let $id := 'δωρ':)

let $log := util:log("INFO", "data: " || $data)
let $morphemes := doc($config:taxonomies-root || "/morphemes.xml")
let $ontology := doc($config:taxonomies-root || "/ontology.xml")

let $ana := for $meaning in $data//TEI:category/TEI:meaning
            return string-join('#' || $meaning/@label/string(), ' ')
            
let $replacement := <category baseForm="{$id}" ana="{$ana}" xmlns="http://www.tei-c.org/ns/1.0"/>
return 
(
(:  insert/update morpheme  :)
    if($morphemes//TEI:category[@baseForm=$id]) then
        update replace $morphemes//TEI:taxonomy/TEI:category[@baseForm=$id] with $replacement
    else
        update insert $replacement into $morphemes//TEI:taxonomy
,
(: insert/update meanings :)
    for $meaning in $data//TEI:category/TEI:meaning
    let $meaningReplacement := 
        <category xml:id="{$meaning/@label}" xmlns="http://www.tei-c.org/ns/1.0">
            <catDesc xml:lang="en">{$meaning/TEI:translation[@xml:lang='en']/string()}</catDesc>
            <catDesc xml:lang="fr">{$meaning/TEI:translation[@xml:lang='fr']/string()}</catDesc>
        </category>

    return
    if($ontology//TEI:category[@xml:id=$meaning/@label]) then
            (
                let $c := console:log('update' || $meaningReplacement)
                return update replace $ontology//TEI:taxonomy/TEI:category[@xml:id=$meaning/@label] with $meaningReplacement
            )
        else
            (
                let $c := console:log('insert' || $meaningReplacement)
                
(:let $c := console:log('data id' || $id || ' all ' || $data ):)

                return    update insert $meaningReplacement into $ontology//TEI:taxonomy
            )
)