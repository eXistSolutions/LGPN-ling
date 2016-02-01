xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

let $id := normalize-unicode(request:get-parameter('id', ''), 'NFD')
let $entry := collection($config:names-root)//TEI:entry/id($id)[1]
let $c := console:log($id ||  ' ' || $entry)
let $d := string-to-codepoints($id)
let $e :=
for $i in $d
    let $e := $i || ' '
    return $e
let $f := console:log($e)

return $entry/ancestor::TEI:TEI
    