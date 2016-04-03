xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

for $dname in collection("/db/apps/lgpn-data/data/ling/names")//TEI:entry/TEI:bibl[not(TEI:author)]
 let $doc := doc(base-uri($dname))
 let $change := 
                     <author xmlns="http://www.tei-c.org/ns/1.0"/>
 let $date := substring-before(xs:string(current-dateTime()), "T")
 let $change2 := <change xmlns="http://www.tei-c.org/ns/1.0" when="{$date}" resp="#magdalena">add author field to entry/bibl entries</change>
 
 return $dname
(:return :)
(:    (update insert $change preceding $doc//TEI:entry/TEI:bibl[not(TEI:author)]/TEI:ref, :)
(:        update insert $change2 into $doc//TEI:listChange,:)
(:        $doc//TEI:entry/TEI:bibl:)
(:    ):)