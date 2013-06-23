<cfcomponent output="false" displayname="Multi Module">

  <cffunction name="init" access="public" output="false" returntype="any">
		<cfset this.version = "1.1.8" />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="$generateIncludeTemplatePath" returntype="string" access="public" output="false" mixin="controller">
		<cfargument name="$name" type="any" required="true">
		<cfargument name="$type" type="any" required="true">
		<cfargument name="$controllerName" type="string" required="false" default="#variables.params.controller#" />
		<cfargument name="$baseTemplatePath" type="string" required="false" default="#application.wheels.viewPath#" />
		<cfargument name="$prependWithUnderscore" type="boolean" required="false" default="true">
		<cfscript>
			var loc = StructNew();
			loc.include = arguments.$baseTemplatePath;
			loc.fileName = ReplaceNoCase(Reverse(ListFirst(Reverse(arguments.$name), "/")), ".cfm", "", "all") & ".cfm"; // extracts the file part of the path and replace ending ".cfm"
			if (arguments.$type == "partial" && arguments.$prependWithUnderscore)
				loc.fileName = Replace("_" & loc.fileName, "__", "_", "one"); // replaces leading "_" when the file is a partial
			loc.folderName = Reverse(ListRest(Reverse(arguments.$name), "/"));
			if (Left(arguments.$name, 1) == "/")
				loc.include = loc.include & loc.folderName & "/" & loc.fileName; // Include a file in a sub folder to views
			else if (arguments.$name Contains "/")
				loc.include = loc.include & "/" & arguments.$controllerName & "/" & loc.folderName & "/" & loc.fileName; // Include a file in a sub folder of the current controller
			else
				loc.include = loc.include & "/" & arguments.$controllerName & "/" & loc.fileName; // Include a file in the current controller's view folder
			if (!FileExists(ExpandPath(LCase(loc.include)))) loc.include = $findInSubFolders(loc.include);
		</cfscript>
		<cfreturn LCase(loc.include) />
	</cffunction>

	<cffunction name="$findInSubFolders" returntype="string">
		<cfargument name="baseInclude" type="string">
		<cfscript>
			var loc = StructNew();
			loc.siblingFolders = $subFolders();
			for (loc.i = 1; loc.i <= loc.siblingFolders.RecordCount; loc.i ++) {
				loc.result = loc.siblingFolders["name"][loc.i] & "/" & baseInclude;
				if (FileExists(ExpandPath(LCase(loc.result)))) return loc.result;
			}
			return baseInclude;
		</cfscript>
	</cffunction>

	<cffunction name="$subFolders" returntype="query">
		<cfset var q = "">
		<cfdirectory action="list" directory="../.." type="dir" name="q">
		<cfquery name="q" dbtype="query">
		select name from q where name not like '.%'
		</cfquery>
		<cfreturn q>
	</cffunction>

	<cffunction name="$createControllerClass" returntype="any" access="public" output="false" mixin="global">
		<cfargument name="name" type="string" required="true">
		<cfargument name="controllerPaths" type="string" required="false" default="#application.wheels.controllerPath#">
		<cfargument name="type" type="string" required="false" default="controller" />
		<cfscript>
			var loc = StructNew();
			loc.basePath = arguments.controllerPaths;
			loc.siblingFolders = $subFolders();
			loc.results = "";
			for (loc.i = 1; loc.i <= loc.siblingFolders.RecordCount; loc.i ++) {
				loc.result = loc.siblingFolders["name"][loc.i] & "/" & loc.basePath
				if (DirectoryExists(ExpandPath(loc.result))) {
					if ("" neq loc.results) loc.results = loc.results & ",";
					loc.results = loc.results & loc.result;
				}
			}
			arguments.controllerPaths = loc.results;
			return core.$createControllerClass(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<cffunction name="$createModelClass" returntype="any" access="public" mixin="global">
		<cfargument name="name" type="string" required="true">
		<cfargument name="modelPaths" type="string" required="false" default="#application.wheels.modelPath#">
		<cfargument name="type" type="string" required="false" default="model" />
		<cfscript>
			var loc = StructNew();
			loc.basePath = arguments.modelPaths;
			loc.siblingFolders = $subFolders();
			loc.results = "";
			for (loc.i = 1; loc.i <= loc.siblingFolders.RecordCount; loc.i ++) {
				loc.result = loc.siblingFolders["name"][loc.i] & "/" & loc.basePath
				if (DirectoryExists(ExpandPath(loc.result))) {
					if ("" neq loc.results) loc.results = loc.results & ",";
					loc.results = loc.results & loc.result;
				}
			}
			arguments.modelPaths = loc.results;
			return core.$createModelClass(argumentCollection=arguments);
		</cfscript>
	</cffunction>

</cfcomponent>
