xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";

let $data :=  <TEI xmlns="http://www.tei-c.org/ns/1.0">
                <text>
                <body>
                    <entry xml:id="Agathoboula">
                        <form type="lemma">
                            <orth type="greek">Ἀγαθοβούλα</orth>
                            <orth type="latin">Agathoboula</orth>
                        </form>
                    </entry>
                </body>
                </text>
            </TEI>
let $data := request:get-data()
let $name := $data//TEI:orth[@type ="latin"] 
return xmldb:store($config:data-root, concat($name , ".xml"), $data)