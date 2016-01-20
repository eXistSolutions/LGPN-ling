xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

let $baseForm := 'αγαθ'
let $data := '/db/apps/lgpn-ling/data/taxonomies'
return doc($data || '/ontology.xml')//tei:category[@xml:id=doc($data || '/morphemes.xml')//tei:category[@baseForm=$baseForm]/substring(@ana,2)]
