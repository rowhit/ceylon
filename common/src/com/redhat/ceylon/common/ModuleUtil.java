package com.redhat.ceylon.common;

import java.io.File;
import java.util.regex.Pattern;

public abstract class ModuleUtil {

    public static final Pattern moduleIdPattern =
            AndroidUtil.isRunningAndroid()
            // Android does not support Unicode block family tests, but claims its ASCII properties are Unicode
            // https://developer.android.com/reference/java/util/regex/Pattern.html#ubpc
            ? Pattern.compile("[\\p{Lower}_][\\p{Alpha}\\p{Digit}_]*")
            // The JDK however claims that ASCII and Unicode block properties differ
            // https://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html#sum
            : Pattern.compile("[\\p{IsLowercase}_][\\p{IsAlphabetic}\\p{IsDigit}_]*");

    private ModuleUtil() {
    }

    public static String moduleName(String moduleNameOptVersion) {
        int p = moduleNameOptVersion.indexOf('/');
        if (p == -1) {
            return moduleNameOptVersion;
        } else {
            return moduleNameOptVersion.substring(0, p);
        }
    }
    
    public static String moduleVersion(String moduleNameOptVersion) {
        int p = moduleNameOptVersion.indexOf('/');
        if (p == -1 || (p == (moduleNameOptVersion.length() - 1))) {
            return null;
        } else {
            return moduleNameOptVersion.substring(p + 1);
        }
    }

    public static boolean isDefaultModule(String moduleName) {
        return "default".equals(moduleName);
    }

    public static String makeModuleName(String moduleName, String version) {
        return makeModuleName(null, moduleName, version);
    }

    public static String makeModuleName(String namespace, String moduleName, String version) {
        String ns = namespace != null ? namespace + ":" : "";
        if (isDefaultModule(moduleName) || version == null) {
            return ns + moduleName;
        } else {
            return ns + moduleName + "/" + version;
        }
    }

    public static File moduleToPath(String moduleName) {
        return new File(moduleName.replace('.', File.separatorChar));
    }

    public static File moduleToPath(File dir, String moduleName) {
        return new File(dir, moduleName.replace('.', File.separatorChar));
    }

    public static String pathToModule(File modulePath) {
        return modulePath.getPath().replace('/', '.').replace('\\', '.');
    }
    
    public static boolean isModuleFolder(Iterable<File> paths, File modPath) {
        File modDesc = new File(modPath, Constants.MODULE_DESCRIPTOR);
        File path = FileUtil.searchPaths(paths, modDesc.getPath());
        return path != null && (new File(path, modDesc.getPath())).isFile();
    }

    public static File moduleFolder(Iterable<File> paths, File relFile) {
        while (relFile != null && !isModuleFolder(paths, relFile)) {
            relFile = relFile.getParentFile();
        }
        return relFile;
    }
    
    public static String moduleName(Iterable<File> paths, File relFile) {
        File modPath = moduleFolder(paths, relFile);
        if (modPath != null) {
            return ModuleUtil.pathToModule(modPath);
        } else {
            return "default";
        }
    }

    /**
     * Turns foo:bar into foo.bar
     * Turns maven:foo:bar into foo.bar
     */
    public static String toCeylonModuleName(String name){
        return getModuleNameFromUri(name).replace(':', '.');
    }
    
    /**
     * Returns true if the module name contains a ':'
     */
    public static boolean isMavenModule(String name){
        return name != null && name.indexOf(':') != -1;
    }
    
    /**
     * For imports of the type
     * <code>import "maven:some.artifact:name" "1.2.3"</code>
     * this will return "maven" and <code>null otherwise</code>
     */
    public static String getNamespaceFromUri(String uri) {
        int p = uri.indexOf(':');
        if (p > 0) {
            String prefix = uri.substring(0, p);
            if (validNamespace(prefix)) {
                return prefix;
            } else {
                // Prefix is invalid so it's considered a maven import
                return "maven";
            }
        } else {
            return null;
        }
    }
    
    /**
     * For imports of the type
     * <code>import "maven:some.artifact:name" "1.2.3"</code>
     * this will return "some.artifact:name"
     */
    public static String getModuleNameFromUri(String uri) {
        int p = uri.indexOf(':');
        if (p > 0) {
            String prefix = uri.substring(0, p);
            if (validNamespace(prefix)) {
                return uri.substring(p + 1);
            } else {
                // Prefix is invalid so it's considered a maven import
                return uri;
            }
        } else {
            return uri;
        }
    }
    
    /**
     * Only <code>null</code> or proper Ceylon identifiers are considered valid namespaces
     */
    public static boolean validNamespace(String namespace) {
        return namespace == null || moduleIdPattern.matcher(namespace).matches();
    }

    /**
     * Determines if the given major/minor binary versions support import namespaces
     */
    public static boolean supportsImportsWithNamespaces(int majorBinVer, int minorBinVer) {
        return (majorBinVer > Versions.V1_2_3_JVM_BINARY_MAJOR_VERSION
                || (majorBinVer == Versions.V1_2_3_JVM_BINARY_MAJOR_VERSION
                && minorBinVer >= Versions.V1_2_3_JVM_BINARY_MINOR_VERSION));
    }
    
}
