xquery version "3.0";

module namespace normalization="http://www.existsolutions.com/apps/lgpn/normalization";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace i18n="http://exist-db.org/xquery/i18n/templates" at "i18n-templates.xql"; 
import module namespace functx = "http://www.functx.com";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare function normalization:normalize($input as item()*) as item()* {
for $node in $input
   return 
      typeswitch($node)
        (: normalize-space and normalize-unicode for all text nodes :)
        case text()
            return normalize-unicode(normalize-space($node), 'NFC')
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