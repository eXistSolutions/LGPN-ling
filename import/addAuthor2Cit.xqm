xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

for $dname in collection("/db/apps/lgpn-data/data/ling/names")//TEI:cit[not(TEI:bibl)]
 let $doc := doc(base-uri($dname))
 let $change := 
                     <bibl xmlns="http://www.tei-c.org/ns/1.0">
                        <author/>
                    </bibl>
 let $date := substring-before(xs:string(current-dateTime()), "T")
 let $change2 := <change xmlns="http://www.tei-c.org/ns/1.0" when="{$date}" resp="#magdalena">add author field to cit entries</change>
 
 return $dname
(:return :)
(:    (update insert $change following $doc//TEI:cit[not(TEI:bibl)]/TEI:quote, :)
(:        update insert $change2 into $doc//TEI:listChange,:)
(:        $doc//TEI:cit:)
(:    ):)