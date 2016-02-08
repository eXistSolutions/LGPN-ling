xquery version "3.0";

(: This script is used to load translations of root (aka base) forms into the `meanings` subform.
 :)

declare namespace loc="http://www.existsolutions.com/apps/lgpn/reload-meanings";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";

let $data := request:get-data()
let $old := $data/tei:meaning
let $label := string($old/@label)
return
    <tei:meaning label="{$label}X">
        <tei:translation xml:lang="en">Ala</tei:translation>
        <tei:translation xml:lang="fr">Ola</tei:translation>
    </tei:meaning>
