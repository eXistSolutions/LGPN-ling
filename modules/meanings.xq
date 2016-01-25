xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

let $morphemes :=  doc("/db/apps/lgpn-ling/data/taxonomies/morphemes.xml")//tei:category
return
<result>
    <total>{count($morphemes)}</total>
    { for $m in $morphemes
        return 
        <term>
            <id>{$m/@baseForm/string()}</id>
            <value>{$m/@baseForm/string()}</value>
        </term>
    }
</result>