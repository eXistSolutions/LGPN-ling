xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

<ol>
    
{for $i in collection("/db/apps/lgpn-ling-data/data/names")//tei:gramGrp[@type='classification'][count(tei:usg) = 1]/tei:usg[.='attic']/ancestor::tei:entry
order by $i/@xml:id collation "?lang=gr-GR"

return 
    <li><a target="_blank" href="../editor.xhtml?id={$i/tei:form/tei:orth[@type="greek"]}">
        {$i/tei:form/tei:orth[@type="greek"]}
        /
        {$i/tei:form/tei:orth[@type="latin"]}
        </a>
    </li>
}
</ol>



   
