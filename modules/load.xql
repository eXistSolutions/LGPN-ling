xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

let $id := normalize-unicode(request:get-parameter('id', ''), 'NFD')
(:let $id := request:get-parameter('id', 'Habrōnax'):)
 let $console := console:log($id)
(: let $console := console:log(for $i in string-to-codepoints($id) return $i || ' '):)
let $entry := collection($config:names-root)//TEI:entry/id($id)[1]
return $entry/ancestor::TEI:TEI
    