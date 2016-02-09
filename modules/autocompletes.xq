xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace tei="http://www.tei-c.org/ns/1.0";
(:import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";:)
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";
let $case := request:get-parameter('type', '')
let $data := request:get-parameter('query', '')

return
switch ($case)
    case 'meanings'
        return
            let $morphemes :=  doc($config:taxonomies-root || "/morphemes.xml")//tei:category[starts-with(./@baseForm, $data)]
            return
            <result>
                <total>{count($morphemes)}</total>
                { for $m in $morphemes
                    return 
                    <term>
                        <id>{$m/tei:catDesc/string()}</id>
                        <value>{$m/@baseForm/string()}</value>
                    </term>
                }
            </result>
    case 'ontology'
        return
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
    default
        return
            let $constituents :=  collection($config:names-root)//tei:m[@type="radical"][starts-with(., $data)]
            return
            <result>
                <total>{count($constituents)}</total>
                { for $m in distinct-values($constituents)
                    return 
                    <term>
                        <value>{$m}</value>
                        <id>{$m}</id>
                    </term>
                }
            </result>