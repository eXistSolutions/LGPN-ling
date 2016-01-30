xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
<taxonomy>
    {
for $i in doc("/db/apps/lgpn-ling/import/ATEI.xml")//tei:entry//tei:m[@type='radical']
group by $bf := $i/@baseForm
order by $bf
return 
    <category>
        {attribute baseForm {translate($i[1]/@baseForm, '()', '')}}
        {attribute ana {$i[1]/@ana}}
        <catDesc>{$i[1]/@baseForm/string()}</catDesc>
    </category>
    }
    </taxonomy>