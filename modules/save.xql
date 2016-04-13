xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace login="http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";
import module namespace normalization="http://www.existsolutions.com/apps/lgpn/normalization" at "normalization.xql";

let $setuser :=  login:set-user("org.exist.lgpn-ling", (), false())
let $user := "#" || request:get-attribute("org.exist.lgpn-ling.user")
let $date := substring-before(xs:string(current-dateTime()), "T")
let $change := <change xmlns="http://www.tei-c.org/ns/1.0" when="{$date}" resp="{$user}">Edit entry via LGPN-ling interface</change>
let $data := normalization:normalize(request:get-data()//TEI:TEI)
let $name := normalize-unicode($data//TEI:orth[@type ="latin"]/string(), 'NFD')
let $log := util:log("INFO", "data: " || count($data))
let $doc := doc(xmldb:store($config:names-root, concat($name , ".xml"), $data))
return 
    update insert $change into $doc//TEI:listChange
(:                    update replace $doc//TEI:orth[@type ="latin"] with $name):)
 