<cfcomponent extends="wheelsMapping.Test" output="false">

	<cffunction name="setup">
        <cfset $$oldMultiModulePathsDefined = IsDefined("application.wheels.multiModulePaths")>
		<cfif $$oldMultiModulePathsDefined>
	        <cfset $$oldMultiModulePaths = get(multiModulePaths)>
		</cfif>
        <cfset set(multiModulePaths="plugins/multimodule/tests/module1,plugins/multimodule/tests/module2") >
		<cfset application.wheels.plugins.multimodule.init()>
	</cffunction>

	<cffunction name="test_controller" hint="can search for controller in module paths">
		<cfset results.multimodulecontroller = controller("MultiModuleController")>
		<cfset assert("IsObject(results.multimodulecontroller)")>
		<cfset assert("IsDefined('results.multimodulecontroller.testcontroller')")>
	</cffunction>

	<cffunction name="test_controller_in_module2" hint="can search for controller in module paths">
		<cfset results.multimodulecontroller2 = controller("MultiModuleController2")>
		<cfset assert("IsObject(results.multimodulecontroller2)")>
		<cfset assert("IsDefined('results.multimodulecontroller2.testcontroller2')")>
	</cffunction>

	<cffunction name="test_model" hint="can search for model in module paths">
		<cfset results.multimodulemodel = model("MultiModuleModel")>
		<cfset assert("IsObject(results.multimodulemodel)")>
	</cffunction>

	<cffunction name="test_view" hint="can search for model in module paths">
        <cfset params = {controller="MultiModuleView", action="index"}>
        <cfset loc.controller = controller("MultiModuleView", params)>
        <cfset result = loc.controller.renderPage()>
        <cfset assert("loc.controller.response() Contains 'test view'")>
	</cffunction>

	<cffunction name="test_view_helper" hint="can search for model in module paths">
        <cfset params = {controller="MultiModuleView", action="helperstest"}>
        <cfset loc.controller = controller("MultiModuleView", params)>
        <cfset result = loc.controller.renderPage()>
        <cfset assert("loc.controller.response() Contains 'test helper'")>
	</cffunction>

	<cffunction name="test_view_layout" hint="can search for layout in module paths">
        <cfset params = {controller="MultiModuleViewLayout", action="layouttest"}>
        <cfset loc.controller = controller("MultiModuleViewLayout", params)>
        <cfset result = loc.controller.renderPage()>
        <cfset assert("loc.controller.response() Contains 'test layout'")>
	</cffunction>

	<cffunction name="teardown">
		<cfif $$oldMultiModulePathsDefined>
	        <cfset set(multiModulePaths=$$oldMultiModulePaths) >
	    <cfelse>
	    	<cfset StructDelete(application.wheels,"multiModulePaths") >
		</cfif>
		application.wheels.plugins.multimodule.init();
	</cffunction>

</cfcomponent>