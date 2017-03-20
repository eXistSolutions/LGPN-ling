xquery version "3.0";


import module namespace login="http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

declare variable $logout := request:get-parameter("logout", ());
declare variable $login := request:get-parameter("user", ());


if ($exist:path eq '') then (
        login:set-user("org.exist.lgpn-ling", (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
)    
else if (ends-with(request:get-query-string(), 'logout=true')) then (
    login:set-user("org.exist.lgpn-ling", (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="about.html"/>
    </dispatch>
)
else if ($exist:resource eq 'save.xql') then (
    login:set-user("org.exist.lgpn-ling", (), false()),
    console:log(sm:id() || ' save ' || request:get-attribute("org.exist.lgpn-ling.user")),
    if (request:get-attribute("org.exist.lgpn-ling.user")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
    else 
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
    		<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
        </view>
	</dispatch>
    )
else if ($exist:path eq "/") then (
    login:set-user("org.exist.lgpn-ling", (), false()),
(:    console:log(sm:id() || ' editor ' || request:get-attribute("org.exist.lgpn-ling.user")),:)
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="about.html"/>
    </dispatch>
)
    (:  Protected resource: user is required to log in with valid credentials.
    If the login fails or no credentials were provided, the request is redirected
    to the about.html page. :)
else if ($exist:resource eq 'editor.xhtml') then (
    login:set-user("org.exist.lgpn-ling", (), false()),
    console:log(sm:id() || ' editor ' || request:get-attribute("org.exist.lgpn-ling.user")),
    if (request:get-attribute("org.exist.lgpn-ling.user")) then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <cache-control cache="no-cache"/>
        </dispatch>
    else 
(:        <redirect url="index.html?loginStatus=failed"/>:)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/about.html"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <add-parameter name="loginStatus" value="failed"/>
            </forward>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>

) else if ($logout or $login) then (
    login:set-user("org.exist.lgpn-ling", (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{replace(request:get-uri(), "^(.*)\?", "$1")}"/>
    </dispatch>
)
    (: the about.html page is run through view.xql to expand templates :)
else if (ends-with($exist:resource, "about.html")) then (
    login:set-user("org.exist.lgpn-ling", (), false()),
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>


    )


    (: other html pages are only available for logged in users is run through view.xql to expand templates :)
else if (ends-with($exist:resource, ".html")) then (
    login:set-user("org.exist.lgpn-ling", (), false()),
    console:log(sm:id() || ' editor ' || request:get-attribute("org.exist.lgpn-ling.user")),
    if (request:get-attribute("org.exist.lgpn-ling.user")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
    else 
(:        <redirect url="index.html?loginStatus=failed"/>:)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/about.html"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <add-parameter name="loginStatus" value="failed"/>
            </forward>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>




    )
else if (contains($exist:path, "/$shared/")) then (
        login:set-user("org.exist.lgpn-ling", (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>)
else (
    login:set-user("org.exist.lgpn-ling", (), false()),
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
    )