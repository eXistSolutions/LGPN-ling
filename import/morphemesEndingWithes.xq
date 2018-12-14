xquery version "3.1";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

(:for $i in collection('/db/apps/lgpn-ling-data/data/names')//tei:m[ends-with(@baseForm, '(εσ)')]:)
(:return $i:)

let $m :=
for $i in doc('/db/apps/lgpn-ling-data/data/taxonomies/morphemes.xml')//tei:category[ends-with(tei:catDesc, '(εσ)')]
order by $i/tei:catDesc collation '?lang=gr-GR'
return $i

return
    <table>
        {

for $i in $m
return <tr><td>{$i/tei:catDesc/string()}</td><td> {$i/@baseForm/string()}</td> </tr>

 
        }
        </table>



