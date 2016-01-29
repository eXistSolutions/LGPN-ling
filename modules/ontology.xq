xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
(:import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";:)

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";
let $data := request:get-parameter('query', '')
let $concepts :=  doc($config:taxonomies-root || "/ontology.xml")//tei:category[starts-with(./@xml:id, $data)]
return
<result>
    <total>{count($concepts)}</total>
    { for $m in $concepts
        return 
        <term>
            <value>{$m/@xml:id/string()}</value>
            <id>{string-join($m//text(), '|')}</id>
        </term>
    }
</result>