component output="false" displayname="Multi Module" {
	this.$modulesPath = getDirectoryFromPath(getBaseTemplatePath()) & '/modules';

	public any function init() output=false {
		this.version = "2.2,2.1,2.0.2,2.0.1,2,2.3,2.4";
		$buildModulesCache();
		return this;
	}

	/**
	 * decide whether to check all module location when searching for objects. Configurable via set(multiModuleCheckAllModules=) in settings.cfm
	 */
	public string function doCheckAll(type="all") {
		/*
			True: Check all type folders no matter what
			False: If [module] is defined in params then only check its models, views, etc no matter what
		*/
		if ( arguments.type == "models" ) {
			return true;
		} else if ( arguments.type == "controllers" ) {
			if ( IsDefined("application.wheels.multiModuleCheckAllModules") ) {
				return get("multiModuleCheckAllModules");
			}
			return true;
		} else if ( arguments.type == "modules" ) {
			if ( IsDefined("application.wheels.multiModuleCheckAllModules") ) {
				return get("multiModuleCheckAllModules");
			}
			return true;
		} else {
			if ( IsDefined("application.wheels.multiModuleCheckAllModules") ) {
				return get("multiModuleCheckAllModules");
			}
			return true;
		}
	}

	public string function getModuleFromUrl() {
		var loc = StructNew();
		cfparam( default="", name="request.module" );

		if(!len(request.module)) {
				if(!structKeyExists(variables,"params") && isDefined("core.$paramParser")) {
					loc.params = core.$paramParser();

				} else if (structKeyExists(variables,"params")) {
					loc.params = params;

				} else {
					loc.params = {};
				}

				// Check to see if module param was found
				if(structKeyExists(loc.params,"module")) {
					request.module = loc.params.module;
				}
				// Else check route name for module (before ~)
				else if(StructKeyExists(loc.params,"route") && find("~",loc.params.route)) {
					request.module = ListFirst(loc.params.route,"~");
				}
			}

			if(DirectoryExists(ExpandPath(LCase("modules\" & request.module)))) {
				return "modules/" & request.module;
			} else {
				return "";
			}
	}

	/**
	 * @mixin controller
	 */
	public string function $generateIncludeTemplatePath(required any $name, required any $type, string $controllerName="#variables.params.controller#", string $baseTemplatePath="#application.wheels.viewPath#", boolean $prependWithUnderscore="true") output=false {

		var loc = StructNew();
		loc.include = arguments.$baseTemplatePath;
		loc.fileName = ReplaceNoCase(Reverse(ListFirst(Reverse(arguments.$name), "/")), ".cfm", "", "all") & ".cfm"; // extracts the file part of the path and replace ending ".cfm"
		if (arguments.$type == "partial" && arguments.$prependWithUnderscore)
			loc.fileName = Replace("_" & loc.fileName, "__", "_", "one"); // replaces leading "_" when the file is a partial
		loc.folderName = Reverse(ListRest(Reverse(arguments.$name), "/"));
		if (Left(arguments.$name, 1) == "/") {
			loc.include = loc.include & loc.folderName & "/" & loc.fileName; // Include a file in a sub folder to views
		} else if (arguments.$name Contains "/") {
			loc.include = loc.include & "/" & arguments.$controllerName & "/" & loc.folderName & "/" & loc.fileName; // Include a file in a sub folder of the current controller
		} else {
			loc.include = loc.include & "/" & arguments.$controllerName & "/" & loc.fileName; // Include a file in the current controller's view folder
		}
		if (!FileExists(ExpandPath(LCase(loc.include)))) {
			loc.include = $findInModules(loc.include);
		}

		return LCase(loc.include);
	}

	public string function $findInModules(string baseInclude) {

		var loc = StructNew();
		loc.modules = $modules();

		// Override module name via URL
		if(len(getModuleFromUrl())) {
			loc.result = getModuleFromUrl() & "/" & baseInclude;
			if (FileExists(ExpandPath(LCase(loc.result)))) return loc.result;
		}

		// Not in url? Go look through modules folder
		if (doCheckAll("modules")) {

			for (loc.i = 1; loc.i <= ArrayLen(loc.modules); loc.i ++) {
				loc.result = loc.modules[loc.i] & "/" & baseInclude;
				if (FileExists(ExpandPath(LCase(loc.result)))) return loc.result;
			}

		}
		return baseInclude;
	}

	public array function $modules() {

		if (IsDefined("application.multimodule.modulesCache")) return application.multimodule.modulesCache;
			return $buildModulesCache();
	}

	public array function $buildModulesCache() {

		var loc = StructNew();
			if (IsDefined("application.wheels.multiModulePaths")) {
				application.multimodule.modulesCache = listToArray(application.wheels.multiModulePaths);
				return application.multimodule.modulesCache;
			}
		cfdirectory( directory=this.$modulesPath, name="loc.q", type="dir", action="list" );
		cfquery( dbtype="query", name="loc.q" ) { //Note: queryExecute() is the preferred syntax but this syntax is easier to convert generically

			echo("select name from loc.q where name not like '.%'");
		}

		loc.results = ArrayNew( 1 );
			for (loc.i = 1 ; loc.i LTE loc.q.RecordCount ; loc.i ++){
				ArrayAppend( loc.results, 'modules/' & loc.q["name"][loc.i]);
			}
			application.multimodule.modulesCache = loc.results;
			return( loc.results );
	}

	/**
	 * @mixin global
	 */
	public any function $createControllerClass(required string name, string controllerPaths="#application.wheels.controllerPath#", string type="controller") output=false {

		var loc = StructNew();
			loc.args = duplicate(arguments);
			loc.basePath = arguments.controllerPaths;
			loc.modules = $modules();

			// Override module name via URL
			if(len(getModuleFromUrl())) {
				loc.result = getModuleFromUrl() & "/" & loc.basePath;
				if (FileExists(ExpandPath("#loc.result#/#name#.cfc"))) {
					loc.args.controllerPaths = loc.result;
				}
			}

			// Not in url? Go look through modules folder
			if (doCheckAll("controllers")) {
				for (loc.i = 1; loc.i <= ArrayLen(loc.modules); loc.i ++) {
					loc.result = loc.modules[loc.i] & "/" & loc.basePath;
					if (FileExists(ExpandPath("#loc.result#/#name#.cfc"))) {
						loc.args.controllerPaths = loc.result;
						break;
					}
				}
			}

			return core.$createControllerClass(loc.args.name,loc.args.controllerPaths,loc.args.type);
	}

	/**
	 * @mixin global
	 */
	public any function $createModelClass(required string name, string modelPaths="#application.wheels.modelPath#", string type="model") {

		var loc = StructNew();
			loc.args = duplicate(arguments);
			loc.basePath = arguments.modelPaths;
			loc.modules = $modules();
			loc.results = arguments.modelPaths;

			// Go look through modules folder
			if (doCheckAll("models")) {
				for (loc.i = 1; loc.i <= ArrayLen(loc.modules); loc.i ++) {
					loc.result = loc.modules[loc.i] & "/" & loc.basePath;
					if (DirectoryExists(ExpandPath(loc.result))) {
						loc.results = loc.results & ",";
						loc.results = loc.results & loc.result;
					}
				}
			}

			// Override module name via URL
			if(len(getModuleFromUrl())) {
				loc.result = getModuleFromUrl() & "/" & loc.basePath;
				if (DirectoryExists(ExpandPath(loc.result))) {
					loc.results = loc.results & ",";
					loc.results = loc.results & loc.result;
				}
			}

			loc.args.modelPaths = loc.results;
			return core.$createModelClass(loc.args.name,loc.args.modelPaths,loc.args.type);
	}

	/**
	 * @mixin controller
	 */
	public any function $initControllerObject(required string name, required struct params) output=false {

		var loc = {};
			loc.template = "#application.wheels.viewPath#/#LCase(arguments.name)#/helpers.cfm";
			if (! FileExists(ExpandPath(loc.template))) {
				if (doCheckAll("controllers")) {
					loc.modules = $modules();
					for (loc.i = 1; loc.i <= ArrayLen(loc.modules); loc.i ++) {
						loc.template = "#loc.modules[loc.i]#/#application.wheels.viewPath#/#LCase(arguments.name)#/helpers.cfm";
						if (FileExists(ExpandPath(loc.template))) break;
					}
				} else if(len(getModuleFromUrl())) {
					loc.result = getModuleFromUrl();
					loc.template = "#getModuleFromUrl()#/#application.wheels.viewPath#/#LCase(arguments.name)#/helpers.cfm";
					if (FileExists(ExpandPath(loc.template))) break;
				}
			}

			// create a struct for storing request specific data
			variables.$instance = {};
			variables.$instance.contentFor = {};

			// include controller specific helper files if they exist, cache the file check for performance reasons
			loc.helperFileExists = false;
			if (!ListFindNoCase(application.wheels.existingHelperFiles, arguments.name) && !ListFindNoCase(application.wheels.nonExistingHelperFiles, arguments.name)) {
				if (FileExists(ExpandPath(loc.template))) {
					loc.helperFileExists = true;
				}
				if (get("cacheFileChecking")) {
					if (loc.helperFileExists) {
						application.wheels.existingHelperFiles = ListAppend(application.wheels.existingHelperFiles, arguments.name);
					} else {
						application.wheels.nonExistingHelperFiles = ListAppend(application.wheels.nonExistingHelperFiles, arguments.name);
					}
				}
			}
			if (Len(arguments.name) && (ListFindNoCase(application.wheels.existingHelperFiles, arguments.name) || loc.helperFileExists)) {
				$include(template=loc.template);
			}

			loc.executeArgs = {};
			loc.executeArgs.name = arguments.name;
			loc.lockName = "controllerLock" & application.applicationName;
			$simpleLock(name=loc.lockName, type="readonly", execute="$setControllerClassData", executeArgs=loc.executeArgs);
			variables.params = arguments.params;
			loc.rv = this;
		return loc.rv;
	}

	/**
	 * @mixin global
	 */
	public void function $abortInvalidRequest() output=false {

		var applicationPath = Replace(GetCurrentTemplatePath(), "\", "/", "all");
			var callingPath = Replace(GetBaseTemplatePath(), "\", "/", "all");
		if ( FileExists(cgi.path_translated) ) {
			include cgi.script_name;
			return;
		}

		if (ListLen(callingPath, "/") GT ListLen(applicationPath, "/") || GetFileFromPath(callingPath) == "root.cfm") {
				$header(statusCode="404", statusText="Not Found");
				$includeAndOutput(template="#application.wheels.eventPath#/onmissingtemplate.cfm");
				abort;
			}
	}

	/**
	 * @mixin global
	 */
	public void function $include(required string template) output=false {
		var loc = {};
		if ( template.startsWith("/") ) {
			include LCase(arguments.template);
		} else {
			include "../../#LCase(arguments.template)#";
		}
	}

	/**
	 * @mixin global
	 */
	public string function $includeAndReturnOutput(required string $template) output=false {
		var loc = {};
		if ( StructKeyExists(arguments, "$type") && arguments.$type == "partial" ) {
			//  make it so the developer can reference passed in arguments in the loc scope if they prefer
			loc = arguments;
		}
		//  we prefix returnValue with "wheels" here to make sure the variable does not get overwritten in the included template
		if ( $template.startsWith("/") ) {
			savecontent variable="loc.wheelsReturnValue" {
				include LCase(arguments.$template);
			}
		} else {
			savecontent variable="loc.wheelsReturnValue" {
				include "../../#LCase(arguments.$template)#";
			}
		}
		return loc.wheelsReturnValue;
	}

	/**
	 * @mixin controller
	 */
	public void function $callAction(required string action) output=false {

		var loc = {};

			if (Left(arguments.action, 1) == "$" || ListFindNoCase(application.wheels.protectedControllerMethods, arguments.action))
				Throw(type="Wheels.ActionNotAllowed", message="You are not allowed to execute the `#arguments.action#` method as an action.", extendedInfo="Make sure your action does not have the same name as any of the built-in Wheels functions.");

			if (StructKeyExists(this, arguments.action) && IsCustomFunction(this[arguments.action])) {
				$invoke(method=arguments.action);
			}
			else if (StructKeyExists(this, "onMissingMethod")) {
				loc.invokeArgs = {};
				loc.invokeArgs.missingMethodName = arguments.action;
				loc.invokeArgs.missingMethodArguments = {};
				$invoke(method="onMissingMethod", invokeArgs=loc.invokeArgs);
			}

			if (!$performedRenderOrRedirect()) {
				try {
					// Added to prevent error
					request.wheels.deprecation = [];
					renderView(); // Change to renderView for 1.2
				}
				catch(Any e) {
					if (
						FileExists(ExpandPath("#application.wheels.viewPath#/#LCase(variables.$class.name)#/#LCase(arguments.action)#.cfm")) or
						FileExists(ExpandPath($findInModules("#application.wheels.viewPath#/#LCase(variables.$class.name)#/#LCase(arguments.action)#.cfm")))
						) {
						Throw(object=e);
					} else {
						if (application.wheels.showErrorInformation) {
							Throw(type="Wheels.ViewNotFound", message="Could not find the view page for the `#arguments.action#` action in the `#variables.$class.name#` controller.", extendedInfo="Create a file named `#LCase(arguments.action)#.cfm` in the `views/#LCase(variables.$class.name)#` directory (create the directory as well if it doesn't already exist).");
						} else {
							$header(statusCode="404", statusText="Not Found");
							$includeAndOutput(template="#application.wheels.eventPath#/onmissingtemplate.cfm");
							abort;
						}
					}
				}
			}
	}

	/**
	 * @mixin controller
	 */
	public string function $renderLayout(required string $content, required any $layout) output=false {

		if ((IsBoolean(arguments.$layout) && arguments.$layout) || (!IsBoolean(arguments.$layout) && Len(arguments.$layout))) {
			// store the content in a variable in the request scope so it can be accessed
			// by the includeContent function that the developer uses in layout files
			// this is done so we avoid passing data to/from it since it would complicate things for the developer
			contentFor(body=arguments.$content, overwrite=true);

			local.include = application.wheels.viewPath;
			if (IsBoolean(arguments.$layout)) {
				local.layoutFileExists = false;
				if (!ListFindNoCase(application.wheels.existingLayoutFiles, variables.params.controller) && !ListFindNoCase(application.wheels.nonExistingLayoutFiles, variables.params.controller)) {


					if (FileExists(ExpandPath(
						$findInModules("#application.wheels.viewPath#/#LCase(variables.params.controller)#/layout.cfm")
					))) {
						local.layoutFileExists = true;
					}
					if (application.wheels.cacheFileChecking) {
						if (local.layoutFileExists) {
							application.wheels.existingLayoutFiles = ListAppend(application.wheels.existingLayoutFiles, variables.params.controller);
						} else {
							application.wheels.nonExistingLayoutFiles = ListAppend(application.wheels.nonExistingLayoutFiles, variables.params.controller);
						}
					}
				}
				if (ListFindNoCase(application.wheels.existingLayoutFiles, variables.params.controller) || local.layoutFileExists) {
					local.include = $findInModules("#application.wheels.viewPath#/#LCase(variables.params.controller)#/layout.cfm");
				} else {
					local.include = local.include & "/" & "layout.cfm";
				}
				local.returnValue = $includeAndReturnOutput($template=local.include);
			} else {
				arguments.$name = arguments.$layout;
				arguments.$template = $generateIncludeTemplatePath(argumentCollection=arguments);
				local.returnValue = $includeFile(argumentCollection=arguments);
			}
		} else {
			local.returnValue = arguments.$content;
		}
		return local.returnValue;
	}

}
