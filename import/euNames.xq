xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

for $i in collection('/db/apps/lgpn-ling-data/data/names')//tei:m[starts-with(., 'ευ')][@type='prefix'][../tei:m[@type="radical"][@n='1'][.!='']]
return 
    <li><a target="_blank" href="../editor.xhtml?id={$i/ancestor::tei:entry/@xml:id/string()}">{$i/ancestor::tei:entry/@xml:id/string()}</a></li>
