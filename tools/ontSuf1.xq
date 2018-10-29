xquery version "3.1";


declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

<ol>
    
{
    for $i in distinct-values(collection('/db/apps/lgpn-ling-data/data/names')//tei:m/@baseForm[ends-with(., 'οντ')]/string())
    let $suf1 := collection('/db/apps/lgpn-ling-data/data/names')//tei:m[@baseForm = $i]/following-sibling::tei:m[@type='suffix'][@n='1']
    order by $i
    return <li>{$i}: {string-join($suf1, ', ')}
    </li>
}
</ol>

