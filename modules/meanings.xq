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

            let $morphemes :=  doc($config:taxonomies-root || "/morphemes.xml")//tei:category[starts-with(replace(normalize-unicode(./@baseForm, 'NFD'), '[\p{M}\p{Sk}]', ''), replace(normalize-unicode($data, 'NFD'), '[\p{M}\p{Sk}]', ''))]

(:            let $morphemes :=  doc($config:taxonomies-root || "/morphemes.xml")//tei:category[starts-with(./@baseForm, $data)]:)
            return
            <result>
                <total>{count($morphemes)}</total>
                { for $m in $morphemes
                    order by $m/@baseForm
                    return 
                    <term>
                        <id>{$m/tei:catDesc/string()}</id>
                        <value>{$m/@baseForm/string()}</value>
                    </term>
                }
            </result>