xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";

let $user := "#" || xmldb:get-current-user()
let $date := substring-before(xs:string(current-dateTime()), "T")
let $change := <change xmlns="http://www.tei-c.org/ns/1.0" when="{$date}" resp="{$user}">Some changes</change>
let $data := request:get-data()
let $name := $data//TEI:orth[@type ="latin"]
let $log := util:log("INFO", "data: " || count($data))
let $doc := doc(xmldb:store($config:data-root, concat($name , ".xml"), $data))
return 
    update insert $change into $doc//TEI:listChange