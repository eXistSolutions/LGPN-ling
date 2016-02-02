xquery version "3.0";

(: Export as CSV.
 :)

declare namespace loc="http://www.existsolutions.com/apps/lgpn/export-csv";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";

import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace app="http://www.existsolutions.com/apps/lgpn/templates" at "app.xql";

declare variable $SEPARATOR := ';';

declare function loc:all-entries() as node()* {
    for $i in collection($config:names-root)//tei:TEI
    order by $i//tei:entry//tei:orth[@type='greek']
        return $i
};

declare function loc:csv-headers() as item()* {
    <row>
        <col>Greek</col>
        <col>Latin</col>
        <col>Gender</col>
        <col>Dialects</col>
        <col>Period</col>
        <col>Base form</col>
        <col>Radical 1</col>
        <col>Radical 2</col>
        <col>Flexional 1</col>
        <col>Flexional 2</col>
        <col>Flexional 3</col>
        <col>Flexional 4</col>
        <col>Lexis</col>
    </row>
};

declare function loc:csvxml-for-entries($doc as node()*) as item()* {
    for $entry in $doc//tei:entry
    for $gramGrp in $entry/tei:gramGrp
    return <row>
        <col>{$entry//tei:orth[@type='greek']/text()}</col>
        <col>{$entry//tei:orth[@type='latin']/text()}</col>
        <col><!--TODO: Gender --></col>
        <col><!--TODO: Dialects --></col>
        <col><!--TODO: Period --></col>
        <col>{string($gramGrp/tei:m[@type='prefix']/@baseForm)}</col>
        <col>{$gramGrp/tei:m[@type='radical' and n='1']/text()}</col>
        <col>{$gramGrp/tei:m[@type='radical' and n='2']/text()}</col>
        <col>{$gramGrp/tei:m[@type='flexional' and n='1']/text()}</col>
        <col>{$gramGrp/tei:m[@type='flexional' and n='2']/text()}</col>
        <col>{$gramGrp/tei:m[@type='flexional' and n='3']/text()}</col>
        <col>{$gramGrp/tei:m[@type='flexional' and n='4']/text()}</col>
        <col>{$entry/tei:cit/tei:quote/text()}</col>
    </row>
};

declare function loc:format-as-csv($xml-rows as node()*) as item()* {
    for $row in $xml-rows
    return (for $col at $i in $row/col
        return (
            if($i > 1) then text{$SEPARATOR} else (),
            loc:csv-field($col)),
        '&#x0A;'
        )
};

declare function loc:csv-field($data as item()*) as xs:string {
    let $txt := string($data)
    let $escaped := replace($txt, '"', '""')
    return
        ('"' || $escaped || '"')
};

(:  For testing, better change to: :)
(:let $_ := response:set-header('content-type', 'text/plain;charset=utf-8'):)
(:let $_ := response:set-header('content-disposition', 'inline;filename="lgpn_data.csv"'):)

let $_ := response:set-header('content-type', 'text/csv;charset=utf-8')
let $_ := response:set-header('content-disposition', 'attachment;filename="lgpn_data.csv"')

let $headers := loc:format-as-csv(loc:csv-headers())
let $docs := loc:all-entries()
let $rows := loc:csvxml-for-entries($docs)
let $formatted := loc:format-as-csv($rows)
return <csv>{
    $headers,
    $formatted
    }</csv>
