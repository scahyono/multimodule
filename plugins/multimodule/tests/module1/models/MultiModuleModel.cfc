<cfcomponent extends="models.Model" output="false">
	<cffunction name="init" output="false">
		<cfscript>
			// Table definition
			table("catalogs");
			setPrimaryKey("dummy");
		</cfscript>
	</cffunction>
</cfcomponent>