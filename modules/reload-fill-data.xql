xquery version "3.0";

(: This script is used to modify "in background" the instance data visible by the editor.
 : It is fired when a user enters some data into fields bound to XForms "submit s-reaload-fill-data" event; currently the "base" field.
 : Current instance is sent via HTTP POST and corrected instance should be returned.
 :)

declare namespace loc="http://www.existsolutions.com/apps/lgpn/reload-fill-data";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";

declare function loc:modify-data($data) {
    $data
};

let $data := request:get-data()
let $name := $data//TEI:orth[@type ="latin"]
(:let $doc := doc(xmldb:store($config:names-root, concat($name , ".xml"), $data)):)
return 
loc:modify-data($data)