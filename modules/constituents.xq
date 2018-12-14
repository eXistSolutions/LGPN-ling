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
            let $constituents :=  collection($config:names-root)//tei:m[@type=("radical", "prefix")][starts-with(., $data)]
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