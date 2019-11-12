xquery version "3.1";

declare namespace json="http://www.json.org";
declare option exist:serialize "method=json media-type=text/javascript";

let $post-data := request:get-data()
let $log := util:log("info", "name-search - POST: " || serialize($post-data) )
return
    <result>
        <name>Jonas</name>
    </result>