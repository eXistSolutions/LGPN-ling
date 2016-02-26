xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

for $dname in collection("/db/apps/lgpn-data/data/ling/names")//TEI:orth[@type='latin']
 let $doc := doc(base-uri($dname))
 let $variant := $dname/normalize-space()
 let $change := <orth type="variant" xmlns="http://www.tei-c.org/ns/1.0">{$variant}</orth>
 let $date := substring-before(xs:string(current-dateTime()), "T")
 let $change2 := <change xmlns="http://www.tei-c.org/ns/1.0" when="{$date}" resp="magdalena">add orth[@type="variant] field</change>
return 
    (update insert $change following $doc//TEI:orth[@type='latin'], 
        update insert $change2 into $doc//TEI:listChange
    )