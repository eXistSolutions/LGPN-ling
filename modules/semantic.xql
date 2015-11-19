xquery version "3.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

let $semantic-tags :=  <taxonomy xml:id="semanticFields">

    <category xml:id="good" >
         <catDesc xml:lang="en">good</catDesc>
         <catDesc xml:lang="fr">bon</catDesc>
      </category>
      <category xml:id="council">
         <catDesc xml:lang="en">council</catDesc>
         <catDesc xml:lang="fr">Conseil</catDesc>
      </category>
      <category xml:id="advice">
         <catDesc xml:lang="en">advice</catDesc>
         <catDesc xml:lang="fr">conseil</catDesc>
      </category>
      <category xml:id="will">
         <catDesc  xml:lang="en">will</catDesc>
         <catDesc  xml:lang="fr">vouloir</catDesc>
      </category>
      <category xml:id="shameful">
         <catDesc  xml:lang="en">shameful</catDesc>
         <catDesc  xml:lang="fr">honteux</catDesc>
      </category>
      <category xml:id="ugly">
         <catDesc  xml:lang="en">ugly</catDesc>
         <catDesc  xml:lang="fr">laid</catDesc>
      </category>
      <category xml:id="hump">
         <catDesc  xml:lang="en">hump</catDesc>
         <catDesc  xml:lang="fr">bosse</catDesc>
      </category>
</taxonomy>
return $semantic-tags//category/@xml:id