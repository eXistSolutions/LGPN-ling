xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace login="http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";
import module namespace sanitize="http://www.existsolutions.com/apps/lgpn/sanitize" at "sanitize.xql";

     
declare function local:normalize($input as item()*) as item()* {
for $node in $input
   return 
      typeswitch($node)
        (: normalize-space and normalize-unicode for all text nodes :)
        case text()
            return normalize-space($node)
        case element()
           return
              element {name($node)} {
                (: output each attribute in this element, normalizing unicode :)
                for $att in $node/@*
                   return
                      attribute {name($att)} {normalize-unicode($att, 'NFC')}
                ,
                (: output all the sub-elements of this element recursively :)
                for $child in $node
                   return local:normalize($child/node())
              }
        (: otherwise pass it through.  Used for comments, and PIs :)
        default return $node
};



let $setuser :=         login:set-user("org.exist.lgpn-ling", (), false())
let $user := "#" || request:get-attribute("org.exist.lgpn-ling.user")
let $date := substring-before(xs:string(current-dateTime()), "T")
let $change := <change xmlns="http://www.tei-c.org/ns/1.0" when="{$date}" resp="{$user}">Edit entry via LGPN-ling interface1</change>
let $test := <span>test</span>
let $data := sanitize:normalize(request:get-data())
let $name := $data//TEI:orth[@type ="latin"]
let $log := util:log("INFO", "data: " || count($data))
let $doc := doc(xmldb:store($config:names-root, concat($name , ".xml"), $data))
return 
    update insert $change into $doc//TEI:listChange
(:                    update replace $doc//TEI:orth[@type ="latin"] with $name):)
 