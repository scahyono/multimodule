package net.sidic.multimodule;

import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.concurrent.TimeUnit;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;

/**
 * Integration Tests (IT) to run during Maven integration-test phase
 * @author Singgih
 *
 */
@RunWith(Parameterized.class)
public class CFWheelsCoreIT {
	static final private String[] KNOWN_ERRORS={"The data source could not be reached."};
	static private CustomHtmlUnitDriver driver;
	static private String baseUrl;
	private String type;
	private String packageName;
	private StringBuffer verificationErrors = new StringBuffer();

	public CFWheelsCoreIT(String type, String packageName) {
		super();
		this.type = type;
		this.packageName = packageName;
	}

	@Parameters(name="package {0}:{1}")
    public static Collection<Object[]> getDirectories() {
    	Collection<Object[]> params = new ArrayList<Object[]>();
		for (File f : new File("plugins").listFiles()) {
			Object[] arr = new Object[] {f.getName(), ""};
			params.add(arr);
    	}
    	addSubDirectories(params, "", "wheels/tests");
    	return params;
    }

	private static boolean addSubDirectories(Collection<Object[]> params, String prefix, String path) {
		boolean added = false;
		for (File f : new File(path).listFiles()) {
			if (f.getName().startsWith("_")) continue;
    		if (!f.isDirectory()) {
    			if (!"controller.flash.".equals(prefix)) continue;
    			if (!f.getName().endsWith(".cfc")) continue;
    			Object[] arr = new Object[] {"core", prefix + f.getName().replace(".cfc", "") };
        		params.add(arr);
        		added = true;
        		continue;
    		}
			if (addSubDirectories(params, prefix + f.getName() + ".", f.getPath())) {
	    		added = true;
				continue;
			}
			
			Object[] arr = new Object[] {"core", prefix + f.getName() };
    		params.add(arr);
    		added = true;
    	}
		return added;
	}
    
	@BeforeClass
	static public void setUpServices() throws Exception {
		Path path = Paths.get("target/failsafe-reports");
		if (!Files.exists(path)) Files.createDirectory(path);
		driver = new CustomHtmlUnitDriver();
		baseUrl = "http://localhost:8080/";
		driver.manage().timeouts().implicitlyWait(30000, TimeUnit.SECONDS);
		//reset test database
		recreateTestDatabase();
	}

	private static void recreateTestDatabase() throws Exception {
		String content = new String(Files.readAllBytes(Paths.get("wheels/Plugins.cfc")));
		content = content.replace("mixableComponents = \"application,dispatch,controller,model,cache,base,connection,microsoftsqlserver,mysql,oracle,postgresql,h2\"","mixableComponents = \"application,dispatch,controller,model,cache,base,connection,microsoftsqlserver,mysql,oracle,postgresql,h2,test\"");
		Files.write(Paths.get("wheels/Plugins.cfc"), content.getBytes());

		System.out.println("test database re-create");
		driver.get(baseUrl + "index.cfm");
		driver.get(baseUrl + "index.cfm?controller=wheels&action=wheels&view=tests&type=core&reload=true&package=controller.caching");
        String pageSource = driver.getPageSource();
        String postfix="";
        // show error detail on Maven log if needed
        if (!pageSource.contains("Passed")) {
        	System.out.println(driver.getPageSourceAsText());
        	postfix = "-ERROR";
        }
		Files.write(Paths.get("target/failsafe-reports/_wheelstestdb" + postfix + ".html"), pageSource.getBytes());
	}

	@Test
	public void testCFWheels() throws IOException {
		System.out.print(type);
		System.out.print(':');
		System.out.println(packageName);
		String testUrl = baseUrl + "index.cfm?controller=wheels&action=wheels&view=tests&type=" + type;
		if (!"".equals(packageName)) testUrl += "&package=" + packageName;
		driver.get(testUrl);
        String pageSource = driver.getPageSource();
        assertTrue("The page should have results",pageSource.trim().length()>0);
        String postfix="";
        // show error detail on Maven log if needed
        if (!pageSource.contains("Passed")) {
        	System.out.println(driver.getPageSourceAsText());
        	postfix = "-ERROR";
        }
		Files.write(Paths.get("target/failsafe-reports/" + type + "-" + packageName + postfix + ".html"), pageSource.getBytes());
        for (String error:KNOWN_ERRORS) {
        	if (pageSource.contains(error)) fail(error + " " + testUrl);
        }
        assertTrue("The page should have passed " + testUrl,pageSource.contains("Passed"));
	}

	@AfterClass
	static public void tearDownServices() throws Exception {
		driver.quit();
	}

	@After
	public void tearDown() throws Exception {
		String verificationErrorString = verificationErrors.toString();
		if (!"".equals(verificationErrorString)) {
			fail(verificationErrorString);
		}
	}

}
