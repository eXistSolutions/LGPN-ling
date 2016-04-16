xquery version "3.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.existsolutions.com/apps/lgpn/config" at "config.xqm";
import module namespace names="http://www.existsolutions.com/apps/lgpn/names" at "names.xql";

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

(:http://localhost:8080/exist/apps/lgpn-ling/modules/load-names.xqm?draw=3&columns%5B0%5D%5Bdata%5D=0&columns%5B0%5D%5Bname%5D=&columns%5B0%5D%5Bsearchable%5D=true&columns%5B0%5D%5Borderable%5D=true&columns%5B0%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B0%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B1%5D%5Bdata%5D=1&columns%5B1%5D%5Bname%5D=&columns%5B1%5D%5Bsearchable%5D=true&columns%5B1%5D%5Borderable%5D=true&columns%5B1%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B1%5D%5Bsearch%5D%5Bregex%5D=false&order%5B0%5D%5Bcolumn%5D=0&order%5B0%5D%5Bdir%5D=asc&start=0&length=50&search%5Bvalue%5D=bb&search%5Bregex%5D=false&_=1459939775375:)

(:let $search := request:get-parameter('search', ''):)
let $search := request:get-parameter('search[value]', '')

let $draw := request:get-parameter('draw', '1')
let $recordsTotal := count(collection($config:names-root)//tei:entry)

(:                            <td data-template="app:entry-action"/>:)
(:                            <td data-template="app:entry-form" data-template-langId="variant"/>:)
(:                            <td data-template="app:entry-form" data-template-langId="greek"/>:)
(:                            <td data-template="app:entry-attestations"/>:)
(:                            <td data-template="app:entry-gender"/>:)
(:                            <td data-template="app:entry-dialect"/>:)
(:                            <td data-template="app:entry-period"/>:)
(:                            <td data-template="app:entry-morpheme" data-template-position="1" data-template-type="prefix"/>:)
(:                            <td data-template="app:entry-morpheme" data-template-position="1" data-template-type="radical"/>:)
(:                            <td data-template="app:entry-morpheme" data-template-position="2" data-template-type="radical"/>:)
(:                            <td data-template="app:entry-morpheme" data-template-position="4" data-template-type="suffix"/>:)
(:                            <td data-template="app:entry-morpheme" data-template-position="3" data-template-type="suffix"/>:)
(:                            <td data-template="app:entry-morpheme" data-template-position="2" data-template-type="suffix"/>:)
(:                            <td data-template="app:entry-morpheme" data-template-position="1" data-template-type="suffix"/>:)
(:                            <td data-template="app:entry-morpheme-functions" data-template-type="radical"/>:)
(:                            <td data-template="app:entry-semantics" data-template-type="radical"/>:)
(:                            <td data-template="app:entry-sources" data-template-type="radical"/>:)
(:                            <td data-template="app:entry-bibl" data-template-type="radical"/>:)
(:                            <td data-template="app:entry-updated"/>:)
(:                            <td data-template="app:entry-action" data-template-action="delete"/>:)
(:      :)

    let $results :=
    for $i in collection($config:names-root)//tei:gramGrp
    order by $i/parent::tei:entry//tei:orth[@type='greek'][1]
        return map {
            "0" := names:entry-form($i, 'greek'),
            "1" := names:entry-form($i, 'variant'),
            "2" := names:entry-attestations($i),
            "3" := $i/parent::tei:entry//tei:orth[@type='latin']/string()
            
        }

(:let $results := (['Agathandros', 'Ἀγάθανδρος'], ['Agathandros', 'Ἀγάθανδρος'], [$search, 'search']):)
let $recordsFiltered := count($results)

(::)
(:		if ( isset($request['search']) && $request['search']['value'] != '' ) {:)
(:			$str = $request['search']['value'];:)
(::)
(:limit:)
(:order:)
(:where:)

		return map {
			"draw" := $draw,
			"recordsTotal"    :=  $recordsTotal,
			"recordsFiltered" :=  $recordsFiltered,
			"data"            := $results
		}


