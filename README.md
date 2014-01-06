<h2>Description</h2>
<p>This plugin allows multiple modules under a single wheels application. </p>
<p>A module is a group of models, controllers and views stored under a single folder per module. The main benefit is each module can be made self-contained (with models, controllers, views, javascripts, etc..) and can be deployed independently from other modules.</p>

<h2>Usage/Examples</h2>
<p>In /config/app.cfm:</p>
<p>
<pre>
&lt;cfscript&gt;
	this.name = &quot;MultiModuleExample&quot;;
	this.mappings[&quot;/controllers&quot;] = getDirectoryFromPath(getBaseTemplatePath()) &amp; &quot;controllers&quot;;
	this.mappings[&quot;/models&quot;] = getDirectoryFromPath(getBaseTemplatePath()) &amp; &quot;models&quot;;
&lt;/cfscript&gt;</pre>
In your /modules/module1/controllers/Say.cfc: </p>
<p>
<pre>
&lt;cfcomponent extends=&quot;controllers.Controller&quot;&gt;
	&lt;cffunction name=&quot;hello&quot;&gt;&lt;/cffunction&gt;
&lt;/cfcomponent&gt;
</pre>
In your /modules/module1/views/say/hello.cfm:</p>
<p>
  <pre>&lt;h1&gt;Hello World!&lt;/h1&gt;</pre>
</p>
<p>
This URL will access the module (for example if you use <a href="http://www.getrailo.org/index.cfm/download/">Railo Express</a>):</p>
<pre><a href="http://localhost:8888/index.cfm/say/hello">http://localhost:8888/index.cfm/say/hello</a></pre>
<p>

<h2>Namespace Modules in URL</h2>
<p>Namespace works only with controllers and views. Those controllers still can access any models from any modules, regardless of there is a namespace in the URL or not.</p>
<p>In /config/routes.cfm:</p>
<p>
<pre>
&lt;cfscript&gt;
addRoute(
    name="moduleRoute", 
	pattern="/m/[module]/[controller]/[action]/[key].[format]"
);
addRoute(
	name="moduleRoute", 
	pattern="/m/[module]/[controller]/[action]"
);
&lt;/cfscript&gt;</pre>

This URL will access the namespaced module:</p>
<pre><a href="http://localhost:8888/index.cfm/m/module1/say/hello">http://localhost:8888/index.cfm/m/module1/say/hello</a></pre>

<p></p>

<p>This will make the plugin check the [module]'s controllers, models, views, etc first, and if something is not found it will fall back to checking other module folders. If you don't  want the plugin to check other modules when [module] is specified then add in /config/settings.cfm:</p>
<pre>&lt;cfset set(multiModuleCheckAllModules=false)></pre>

</p>
