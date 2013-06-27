<h2>Description</h2>
<p>This plugin allows multiple modules under a single wheels application. </p>
<p> A module is a group of models, controllers and views stored under a single folder per module. The main benefit is each module can be made self-contained (with models, controllers, views, javascripts, etc..) and can be deployed independently from other modules.</p>

<h2>Usage/Examples</h2>
<p>In /config/app.cfm:</p>
<p>
<pre>
&lt;cfscript&gt;
	this.name = &quot;MultiModuleExample&quot;;
	this.mappings[&quot;/controllers&quot;] = getDirectoryFromPath(getBaseTemplatePath()) &amp; &quot;controllers&quot;;
	this.mappings[&quot;/models&quot;] = getDirectoryFromPath(getBaseTemplatePath()) &amp; &quot;models&quot;;
&lt;/cfscript&gt;</pre>
In your /module1/controllers/Say.cfc: </p>
<p>
<pre>
&lt;cfcomponent extends=&quot;controllers.Controller&quot;&gt;
	&lt;cffunction name=&quot;hello&quot;&gt;&lt;/cffunction&gt;
&lt;/cfcomponent&gt;
</pre>
In your /module1/views/say/hello.cfm:</p>
<p>
  <pre>&lt;h1&gt;Hello World!&lt;/h1&gt;</pre>
</p>
<p>
This URL will access the module (for example if you use <a href="http://www.getrailo.org/index.cfm/download/">Railo Express</a>):</p>
<pre><a href="http://localhost:8888/index.cfm/say/hello">http://localhost:8888/index.cfm/say/hello</a></pre>
<p>
<b>ADVANCED USE</b>:<br>
If you have modules outside the wheels application, you have to configure two more mappings for each external modules in /config/app.cfm:<br/>
<pre>
&lt;cfscript&gt;
	this.name = &quot;MultiModuleExample&quot;;
	this.mappings[&quot;/controllers&quot;] = getDirectoryFromPath(getBaseTemplatePath()) &amp; &quot;controllers&quot;;
	this.mappings[&quot;/models&quot;] = getDirectoryFromPath(getBaseTemplatePath()) &amp; &quot;models&quot;;
	
	//list all modules
	application.multimodule.modulePaths="/module1,/admin/module2,module3,sub1/module4";
	
	//explicit mappings is required for external modules
	this.mappings[&quot;/module1/controllers&quot;] = ExpandPath(&quot;/module1/controllers&quot;);
	this.mappings[&quot;/module1/models&quot;] = ExpandPath(&quot;/module1/models&quot;);
	this.mappings[&quot;/admin/module2/controllers&quot;] = ExpandPath(&quot;/admin/module2/controllers&quot;);
	this.mappings[&quot;/admin/module2/models&quot;] = ExpandPath(&quot;/admin/module2/models&quot;);
&lt;/cfscript&gt;</pre>
The example above assumes that your wheels application is NOT in the root (e.g.: /base) and you have four modules:<br/>
<pre>
root
+ base
  + module3
  + sub1/module4
+ /module1
+ /admin/module2
</pre>
</p>
<p>
This URL will access the module (e.g.: you wheels app is in "/base" sub folder):</p>
<pre><a href="http://localhost:8888/base/index.cfm/say/hello">http://localhost:8888/base/index.cfm/say/hello</a></pre>
<p>
