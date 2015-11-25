xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

let $doc := doc("/db/apps/lgpn/import/ATEI.xml")
let $header := $doc//TEI:teiHeader/*
return 
    for $entry in $doc//TEI:entry
    let $date := substring-before(xs:string(current-dateTime()), "T")
    let $name := data($entry/@xml:id)
    let $data :=    <TEI xmlns="http://www.tei-c.org/ns/1.0">
                        <teiHeader>
                            <revisionDesc>
                                <listChange>
                                    <change date="{$date}" resp="#auto">Inital Import</change>
                                </listChange>
                            </revisionDesc>
                            {$header}
                        </teiHeader>
                        <text>
                            <body>
                                {$entry}
                            </body>
                        </text>
                    </TEI>
    return
        xmldb:store('/db/apps/lgpn/data', $name || '.xml', $data)