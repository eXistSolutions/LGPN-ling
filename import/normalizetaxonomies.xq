xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "../modules/config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace normalization="http://www.existsolutions.com/apps/lgpn/normalization" at "../modules/normalization.xql";

let $doc := doc($config:taxonomies-root || "/morphemes.xml")

let $data := normalization:normalize($doc//TEI:taxonomy)
return        xmldb:store($config:taxonomies-root, "morphemes.xml", $data)
