xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

let $data := request:get-data()
let $id := $data//TEI:category/@baseForm
(:let $id := 'δωρ':)

let $log := util:log("INFO", "data: " || count($data))
let $doc := doc($config:taxonomies-root || "/morph.xml")
let $c := console:log('data id' || $id || ' all ' || $data )
let $replacement := <category baseForm="{$id}" ana="#XYZ #123" xmlns="http://www.tei-c.org/ns/1.0"/>
return 
    if($doc//TEI:category[@baseForm=$id]) then
            (
                    let $c := console:log('update')
 return update replace $doc//TEI:taxonomy/TEI:category[@baseForm=$id] with $replacement
            )
        else
            (
                    let $c := console:log('insert' || $replacement)
                return    update insert $replacement into $doc//TEI:taxonomy
)