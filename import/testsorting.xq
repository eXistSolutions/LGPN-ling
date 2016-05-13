xquery version "3.0";
import module namespace normalization="http://www.existsolutions.com/apps/lgpn/normalization" at "../modules/normalization.xql";

declare namespace tei="http://www.tei-c.org/ns/1.0";
(:        return 'replace($i/parent::tei:entry//tei:orth[@type="greek"][1],  "\p{M}", "")' :)

let $test := 
<div>
    <p>Ἀβαεόδωρος</p><p>Ἀβαία</p><p>Ἀβαιόκριτος</p><p>Ἀβαῖος</p><p>Ἀβηΐχα</p><p>Ἀβηόδωρος</p><p>῾Αβραγόρα</p><p>῾Αβραγόρας</p><p>῾Αβροκόμας</p><p>῾Αβρόμαχος</p><p>῾Αβροτέλης</p><p>Ἀγάθα</p><p>Ἀγαθαμερίς</p><p>Ἀγαθ-άμερ-ος</p><p>Ἀγάθη</p><p>Ἀγαθ-ημερ-ίς</p><p>Ἀγαθήμερος</p><p>Ἀγαθ-ίας</p><p>Ἀγαθῖνος</p><p>Ἀγαθοβούλα</p><p>Ἀγαθοβούλα</p><p>Ἀγαθοβούλα</p><p>Αἰσχίδιππος</p><p>Αἰσχρύβα</p><p>Αἰσχρυβᾶς</p><p>Αἰσχρύβης</p><p>Αἰσχρύβης</p><p>Αἰσχρύβης</p><p>Αἰσχρυβίων</p><p>Αἰσχυλίς</p><p>῎Αριστις</p><p>᾿Αριστίς</p><p>Ἀστόβουλος</p><p>Ἀστόβουλος</p><p>Βατιάς</p><p>Βωλαγόρας</p><p>Εὐαρχίδαμος</p><p>Ἐχεμένης</p><p>Ἐχέμμας</p><p>Κλεοπᾶς</p><p>Σούρος</p><p>Φιλωνιχίδης</p><p>Ϝαστιούλλει</p>
    </div>
    
    return 
<div>
    {
  for $i in   $test/p
  order by normalization:normalize-greek(normalize-unicode($i, 'NFC')) collation '?lang=el-grc&amp;strength=secondary&amp;decomposition=standard'
  return <p>{$i/string()}</p>
    }
</div>
