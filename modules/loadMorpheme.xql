xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";

let $id := request:get-parameter('id', '')
let $entry := collection($config:taxonomies-root)//TEI:taxonomy[@xml:id="morphemes"]/TEI:category[@baseForm=$id][1]

return $entry