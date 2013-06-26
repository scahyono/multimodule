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
			loc.subFolders = $subFolders();
			for (loc.i = 1; loc.i <= loc.subFolders.RecordCount; loc.i ++) {
				loc.result = loc.subFolders["name"][loc.i] & "/" & baseInclude;
				if (FileExists(ExpandPath(LCase(loc.result)))) return loc.result;
			}
			return baseInclude;
		</cfscript>
	</cffunction>

	<cffunction name="$subFolders" returntype="query">
		<cfset loc = StructNew()>
		<cfset loc.rootPath = getDirectoryFromPath(getBaseTemplatePath())>
		<cfdirectory action="list" directory="#loc.rootPath#" type="dir" name="loc.q">
		<cfquery name="loc.q" dbtype="query">
		select name from loc.q where name not like '.%' 
		and name not in ('config','controllers','events','files','images','javascripts',
		'lib','miscellaneous','models','plugins','stylesheets','tests','views','wheels')
		</cfquery>
		<cfreturn loc.q>
	</cffunction>

	<cffunction name="$createControllerClass" returntype="any" access="public" output="false" mixin="global">
		<cfargument name="name" type="string" required="true">
		<cfargument name="controllerPaths" type="string" required="false" default="#application.wheels.controllerPath#">
		<cfargument name="type" type="string" required="false" default="controller" />
		<cfscript>
			var loc = StructNew();
			loc.args = duplicate(arguments);
			loc.basePath = arguments.controllerPaths;
			loc.subFolders = $subFolders();
			loc.results = arguments.controllerPaths;
			for (loc.i = 1; loc.i <= loc.subFolders.RecordCount; loc.i ++) {
				loc.result = loc.subFolders["name"][loc.i] & "/" & loc.basePath;
				if (DirectoryExists(ExpandPath(loc.result))) {
					loc.results = loc.results & ",";
					loc.results = loc.results & loc.result;
				}
			}
			loc.args.controllerPaths = loc.results;
			return core.$createControllerClass(loc.args.name,loc.args.controllerPaths,loc.args.type);
		</cfscript>
	</cffunction>

	<cffunction name="$createModelClass" returntype="any" access="public" mixin="global">
		<cfargument name="name" type="string" required="true">
		<cfargument name="modelPaths" type="string" required="false" default="#application.wheels.modelPath#">
		<cfargument name="type" type="string" required="false" default="model" />
		<cfscript>
			var loc = StructNew();
			loc.args = duplicate(arguments);
			loc.basePath = arguments.modelPaths;
			loc.subFolders = $subFolders();
			loc.results = arguments.modelPaths;
			for (loc.i = 1; loc.i <= loc.subFolders.RecordCount; loc.i ++) {
				loc.result = loc.subFolders["name"][loc.i] & "/" & loc.basePath;
				if (DirectoryExists(ExpandPath(loc.result))) {
					loc.results = loc.results & ",";
					loc.results = loc.results & loc.result;
				}
			}
			loc.args.modelPaths = loc.results;
			return core.$createModelClass(loc.args.name,loc.args.modelPaths,loc.args.type);
		</cfscript>
	</cffunction>

	<cffunction name="$initControllerObject" returntype="any" access="public" output="false" mixin="controller">
		<cfargument name="name" type="string" required="true">
		<cfargument name="params" type="struct" required="true">
		<cfscript>
			var loc = {};
			loc.template = "#application.wheels.viewPath#/#LCase(arguments.name)#/helpers.cfm";
			if (! FileExists(ExpandPath(loc.template))) {
				loc.subFolders = $subFolders();
				for (loc.i = 1; loc.i <= loc.subFolders.RecordCount; loc.i ++) {
					loc.template = "#loc.subFolders['name'][loc.i]#/#application.wheels.viewPath#/#LCase(arguments.name)#/helpers.cfm";
					if (FileExists(ExpandPath(loc.template))) break;
				}
			}
	
			// create a struct for storing request specific data
			variables.$instance = {};
			variables.$instance.contentFor = {};
	
			// include controller specific helper files if they exist, cache the file check for performance reasons
			loc.helperFileExists = false;
			if (!ListFindNoCase(application.wheels.existingHelperFiles, arguments.name) && !ListFindNoCase(application.wheels.nonExistingHelperFiles, arguments.name))
			{
				if (FileExists(ExpandPath(loc.template)))
					loc.helperFileExists = true;
				if (application.wheels.cacheFileChecking)
				{
					if (loc.helperFileExists)
						application.wheels.existingHelperFiles = ListAppend(application.wheels.existingHelperFiles, arguments.name);
					else
						application.wheels.nonExistingHelperFiles = ListAppend(application.wheels.nonExistingHelperFiles, arguments.name);
				}
			}
			if (ListFindNoCase(application.wheels.existingHelperFiles, arguments.name) || loc.helperFileExists)
				$include(template=loc.template);
	
			loc.executeArgs = {};
			loc.executeArgs.name = arguments.name;
			$simpleLock(name="controllerLock", type="readonly", execute="$setControllerClassData", executeArgs=loc.executeArgs);
	
			variables.params = arguments.params;
		</cfscript>
		<cfreturn this>
	</cffunction>

</cfcomponent>
