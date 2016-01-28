xquery version "3.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

let $semantic-tags :=  collection($config:taxonomies-root)//tei:taxonomy[@xml:id='ontology']
return $semantic-tags//tei:category/@xml:id/string()