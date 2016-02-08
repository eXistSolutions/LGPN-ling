xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare function local:updateMeanings($data) {
    let $ontology := doc($config:taxonomies-root || "/ontology.xml")

    for $meaning in $data//TEI:category/TEI:meaning
    let $meaningReplacement := 
        if($meaning/TEI:translation[@xml:lang='en']/string() and $meaning/TEI:translation[@xml:lang='fr']/string())
            then
                <category xml:id="{$meaning/@label/string()}" xmlns="http://www.tei-c.org/ns/1.0">
                    <catDesc xml:lang="en">{$meaning/TEI:translation[@xml:lang='en']/string()}</catDesc>
                    <catDesc xml:lang="fr">{$meaning/TEI:translation[@xml:lang='fr']/string()}</catDesc>
                </category>
            else ()
    
(:    let $c := console:log('replacement' || $meaningReplacement):)

    return
    if($ontology//TEI:category[@xml:id=$meaning/@label]) 
        then
            if(string($meaningReplacement)) 
                then 
                    update replace $ontology//TEI:taxonomy/TEI:category[@xml:id=$meaning/@label] with $meaningReplacement 
                else ()
        else
            update insert $meaningReplacement into $ontology//TEI:taxonomy
};

declare function local:updateMorpheme($data) {
    let $morphemes := doc($config:taxonomies-root || "/morphemes.xml")
    let $id := $data//TEI:category/@baseForm

    let $ana := for $meaning in $data//TEI:category/TEI:meaning[string(@label)]
            return string-join('#' || $meaning//@label/string(), ' ')
            
    let $replacement := <category baseForm="{$id}" ana="{$ana}" xmlns="http://www.tei-c.org/ns/1.0">
                        {$data//TEI:category/TEI:catDesc}
                    </category>
    
(:    let $c := console:log('replacement' || $replacement):)
    
    return
        if($morphemes//TEI:category[@baseForm=$id]) 
            then
                update replace $morphemes//TEI:taxonomy/TEI:category[@baseForm=$id] with $replacement
            else
                update insert $replacement into $morphemes//TEI:taxonomy
};


let $data := request:get-data()
(:let $log := util:log("INFO", "data: " || $data):)

return (local:updateMorpheme($data), local:updateMeanings($data))