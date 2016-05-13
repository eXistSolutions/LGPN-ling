xquery version "3.0";

module namespace normalization="http://www.existsolutions.com/apps/lgpn/normalization";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace functx = "http://www.functx.com";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

declare function normalization:normalize-greek($input as xs:string?) as xs:string? {
    let $from := 	('῾Α', '῞Α')
    let $to := 	('Ἁ', 'Ἄ')

return

functx:replace-multi($input,$from,$to)
};

declare function normalization:normalize($input as item()*) as item()* {
for $node in $input
   return 
      typeswitch($node)
        (: normalize-space and normalize-unicode for all text nodes :)
        case text()
(:            return:)
(:                let $c :=console:log('normalize'):)
            return if($node/parent::TEI:orth) then normalize-unicode(normalization:normalize-greek(normalize-space($node)), 'NFC') else normalize-unicode(normalize-space($node), 'NFC')
            
        case element()
           return
              element {node-name($node)} {
                (: normalize unicode for attributes :)
                for $att in $node/@*
                   return
                      attribute {name($att)} {normalize-unicode($att, 'NFC')}
                ,
                for $child in $node
                   return normalization:normalize($child/node())
              }
        (: all the rest pass it through :)
        default 
            return $node
};