xquery version "3.0";

module namespace sanitize="http://www.existsolutions.com/apps/lgpn/sanitize";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace i18n="http://exist-db.org/xquery/i18n/templates" at "i18n-templates.xql"; 
import module namespace functx = "http://www.functx.com";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare function sanitize:normalize($input as item()*) as item()* {
for $node in $input
   return 
      typeswitch($node)
        (: normalize-space and normalize-unicode for all text nodes :)
        case text()
            return normalize-space($node)
        case element()
           return
              element {name($node)} {
                (: output each attribute in this element, normalizing unicode :)
                for $att in $node/@*
                   return
                      attribute {name($att)} {normalize-unicode($att, 'NFC')}
                ,
                (: output all the sub-elements of this element recursively :)
                for $child in $node
                   return sanitize:normalize($child/node())
              }
        (: otherwise pass it through.  Used for comments, and PIs :)
        default return $node
};
