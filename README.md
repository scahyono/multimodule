<h1>Multi Module</h1> 
<h2>Author</h2>
<p><a href="http://cfwheels.org/user/profile/412">Singgih Cahyono</a></p>
<h2>Project Home</h2>
<p><a href="https://github.com/scahyono/MultiModule">https://github.com/scahyono/MultiModule</a><a href="https://github.com/dhumphreys/cfwheels-coldroute"></a></p>
<h2>Description</h2>
<p>This plugin allows multiple modules under a single wheels application. </p>
<p> A module is a group of models, controllers and views stored under a single folder per module. The main benefit is each module can be made self-contained (with models, controllers, views, javascripts, etc..) and can be deployed independently from other modules.</p>

<h2>Usage/Examples</h2>
<p>In /config/app.cfm:</p>
<p>
  <pre>&lt;cfscript&gt;<br />  this.name = &quot;MultiModuleExample&quot;;<br />	this.mappings[&quot;/controllers&quot;] = getDirectoryFromPath(getBaseTemplatePath()) &amp; &quot;controllers&quot;;<br />	this.mappings[&quot;/models&quot;] = getDirectoryFromPath(getBaseTemplatePath()) &amp; &quot;models&quot;;<br />&lt;/cfscript&gt;</pre>
In your /module1/controllers/Say.cfc: </p>
<p>
  <pre>&lt;cfcomponent extends=&quot;controllers.Controller&quot;&gt;<br />	&lt;cffunction name=&quot;hello&quot;&gt;&lt;/cffunction&gt;<br />&lt;/cfcomponent&gt;</pre>
In your /module1/views/say/index.cfm:</p>
<p>
  <pre>&lt;h1&gt;Hello World!&lt;/h1&gt;</pre>
This URL will access the module (for example if use Railo Express server):</p>
<p>http://localhost:8888/index.cfm/say/hello</p>
<h2>Change Log</h2>
<h3>Version 0.2 June 24, 2013</h3>
<ul>
  <li>Bug fixes for helpers.cfm</li>
  <li>Tested on Adobe ColdFusion 8</li>
</ul>
<h3>Version 0.1 June 23, 2013</h3>
<ul>
  <li>Initial release.</li>
  <li>Tested on Railo 4</li>
</ul>
<p>&nbsp;</p>
<p><br />
</p>
