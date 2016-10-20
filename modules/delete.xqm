xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
(:import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";:)

let $id := request:get-parameter('id', '')
(: let $console := console:log($id):)
let $entry := collection($config:names-root)//TEI:entry/id($id)[1]

let $del := if($entry) then xmldb:remove(util:collection-name($entry), util:document-name($entry)) else ('blah')
 
return $del
