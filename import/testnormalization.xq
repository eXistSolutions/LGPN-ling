xquery version "3.0";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";
     
declare function local:normalize($input as item()*) as item()* {
for $node in $input
   return 
      typeswitch($node)
        (: normalize-space and normalize-unicode for all text nodes :)
        case text()
            return normalize-unicode(normalize-space($node), 'NFC')
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
                   return local:normalize($child/node())
              }
        (: otherwise pass it through.  Used for comments, and PIs :)
        default return $node
};

let $test := <text type="mytype">
                    <p>
                        <!-- comment -->
a) "Βαβύριος"
b) "Βαβύριος"
                        <ala>ala</ala>
                        <makota> blah </makota>
                    </p>
            </text>

    return local:normalize($test)