xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";

let $id := request:get-parameter('id', '')
let $entry := collection($config:data-root)//TEI:entry/id($id)[1]
return $entry/ancestor::TEI:TEI
    