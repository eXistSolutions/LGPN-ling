xquery version "3.0";

module namespace blah="http://www.existsolutions.com/apps/blah";

declare
function blah:foo($node as node(), $model as map(*), $blah as xs:string?) {
    'blah'
};

declare
function blah:foo($node as node(), $model as map(*), $blah as xs:string?) {
    ()
};
