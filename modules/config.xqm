xquery version "3.0";

(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace config="http://www.existsolutions.com/apps/lgpn/config";

declare namespace templates="http://exist-db.org/xquery/templates";

declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace expath="http://expath.org/ns/pkg";

declare variable $config:dba-credentials := ("admin", "");
(: 
    Determine the application root collection from the current module load path.
:)
declare variable $config:app-root := 
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    return
        substring-before($modulePath, "/modules")
;

(:all data to be stored in lgpn-ling-data app:)
declare variable $config:ling-data-root := "/db/apps/lgpn-ling-data/data";

declare variable $config:names-root := $config:ling-data-root || "/names";
declare variable $config:names := collection($config:names-root);


declare variable $config:taxonomies-root := $config:ling-data-root || "/taxonomies";
declare variable $config:taxonomies := collection($config:taxonomies-root);


declare variable $config:dictionaries-root := $config:app-root || "/resources/xml";

 (:prosopographical database data:)
declare variable $config:data-root := "/db/apps/lgpn-data/data";
declare variable $config:persons-root := $config:data-root || "/persons";
declare variable $config:persons := collection($config:persons-root);

(: old lgpn data (pre-exist) :)
 declare variable $config:lgpn-tei := "/db/apps/lgpn-tei/data";
declare variable $config:lgpn-places := $config:lgpn-tei || "/volume0.places.xml";
declare variable $config:lgpn-names := $config:lgpn-tei || "/volume0.names.xml";
declare variable $config:lgpn-volumes := $config:lgpn-tei || "/volume0.xml";

 (:i18n catalogues stay here so far:)
declare variable $config:i18n-root := $config:app-root || "/data/i18n";

declare variable $config:repo-descriptor := doc(concat($config:app-root, "/repo.xml"))/repo:meta;

declare variable $config:expath-descriptor := doc(concat($config:app-root, "/expath-pkg.xml"))/expath:package;

(:~
 : Resolve the given path using the current application context.
 : If the app resides in the file system,
 :)
declare function config:resolve($relPath as xs:string) {
    if (starts-with($config:app-root, "/db")) then
        doc(concat($config:app-root, "/", $relPath))
    else
        doc(concat("file://", $config:app-root, "/", $relPath))
};

(:~
 : Returns the repo.xml descriptor for the current application.
 :)
declare function config:repo-descriptor() as element(repo:meta) {
    $config:repo-descriptor
};

(:~
 : Returns the expath-pkg.xml descriptor for the current application.
 :)
declare function config:expath-descriptor() as element(expath:package) {
    $config:expath-descriptor
};

declare %templates:wrap function config:app-title($node as node(), $model as map(*)) as text() {
    $config:expath-descriptor/expath:title/text()
};

declare function config:app-meta($node as node(), $model as map(*)) as element()* {
    <meta xmlns="http://www.w3.org/1999/xhtml" name="description" content="{$config:repo-descriptor/repo:description/text()}"/>,
    for $author in $config:repo-descriptor/repo:author
    return
        <meta xmlns="http://www.w3.org/1999/xhtml" name="creator" content="{$author/text()}"/>
};

(:~
 : For debugging: generates a table showing all properties defined
 : in the application descriptors.
 :)
declare function config:app-info($node as node(), $model as map(*)) {
    let $expath := config:expath-descriptor()
    let $repo := config:repo-descriptor()
    return
        <table class="app-info">
            <tr>
                <td>app collection:</td>
                <td>{$config:app-root}</td>
            </tr>
            {
                for $attr in ($expath/@*, $expath/*, $repo/*)
                return
                    <tr>
                        <td>{node-name($attr)}:</td>
                        <td>{$attr/string()}</td>
                    </tr>
            }
            <tr>
                <td>Controller:</td>
                <td>{ request:get-attribute("$exist:controller") }</td>
            </tr>
        </table>
};