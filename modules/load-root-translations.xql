xquery version "3.0";

(: This script is used to load translations of root (aka base) forms into the `meanings` subform.
 :)

declare namespace loc="http://www.existsolutions.com/apps/lgpn/load-root-translations";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";

let $data := request:get-data()
let $ontology := doc($config:taxonomies-root || '/ontology.xml')
let $old := $data/tei:meaning
let $label := string($old/@label)
let $foundMeaning := $ontology//tei:category[@xml:id=$label]
return
    <tei:meaning label="{$label}"> {
        for $translation in $old/tei:translation
        let $lang := string($translation/@xml:lang)
        let $foundTranslation := $foundMeaning/tei:catDesc[@xml:lang=$lang]/text()
        return
            if($foundTranslation)
            then <tei:translation xml:lang="{$lang}">{$foundTranslation}</tei:translation>
            else $translation
    }
    </tei:meaning>
