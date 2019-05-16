xquery version "3.1";
declare namespace tei="http://www.tei-c.org/ns/1.0";
(: prepare summary name information from the 'old' LGPN data; only used until migration of pre V6 volumes to LGPN-data is complete :)
 
let $persons := doc('/db/apps/lgpn-tei/data/volume0.xml')

let $summary :=
   for $p in $persons//tei:persName[@type='main']
   let $persName := $p/string()
   group by $persName
   
   return 
       let $persons:= 
            for $i in $p
                return $i/ancestor::tei:person 
            
        let $genders := for $i in distinct-values($persons//tei:sex/@value) return <gender>{$i}</gender>

        let $dates :=  (min($persons//tei:birth/@notBefore[string(.)]), max($persons/tei:birth/@notAfter[string(.)]))
      
        let $period :=  string-join($dates, '/')
      
        return
            
        <name>
           <nameform>{$persName}</nameform>
           <attestations>{count($p)}</attestations>
           {$genders}
           <period from="{$dates[1]}" to="{$dates[2]}">{$period}</period>
        </name>

return xmldb:store('/db/apps/lgpn-tei/data', 'names.xml', <listName>{$summary}</listName>)