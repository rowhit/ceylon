package com.redhat.ceylon.cmr.resolver.aether;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import org.eclipse.aether.graph.DependencyNode;

public class DependencyNodeDependencyDescriptor implements DependencyDescriptor {
	private DependencyNode node;
	private List<DependencyDescriptor> deps;
	
	DependencyNodeDependencyDescriptor(DependencyNode node){
	    this.node = node;
	    deps = new ArrayList<>(node.getChildren().size());
	    for(DependencyNode dep : node.getChildren()){
	        deps.add(new DependencyNodeDependencyDescriptor(dep));
	    }
	}

	@Override
	public File getFile() {
	    if(node.getArtifact().getExtension().equals("aar")){
	        File repoFolder = node.getArtifact().getFile().getParentFile();
	        File explodedFolder = new File(repoFolder, "exploded");
            File exploded = new File(explodedFolder, "classes.jar");
	        if(exploded.exists())
	            return exploded;
	        try {
                unzip(node.getArtifact().getFile(), "classes.jar", explodedFolder);
            } catch (IOException e) {
                throw new RuntimeException("Failed to extract AAR file: "+node.getArtifact().getFile(), e);
            }
	        return exploded;
	    }
		return node.getArtifact().getFile();
	}

	@Override
	public List<DependencyDescriptor> getDependencies() {
		return deps;
	}

	@Override
	public String getGroupId() {
		return node.getArtifact().getGroupId();
	}

	@Override
	public String getArtifactId() {
		return node.getArtifact().getArtifactId();
	}

	@Override
	public String getVersion() {
		return node.getArtifact().getVersion();
	}

	@Override
	public boolean isOptional() {
		return node.getDependency().isOptional();
	}

    public static void unzip(File archive, String entryPath, File destinationFolder) throws IOException {
        if (destinationFolder.exists()) {
            if (!destinationFolder.isDirectory()) {
                throw new IOException("Destination is not a folder: " + destinationFolder);
            }
        } else {
            if(!destinationFolder.mkdirs())
                throw new IOException("Cannot create destination folder: " + destinationFolder);
        }

        try (ZipFile zf = new ZipFile(archive)) {
            ZipEntry entry = zf.getEntry(entryPath);
            if(entry == null)
                throw new IOException("No such entry: "+ entryPath);
            String name = entryPath;
            if(entryPath.indexOf('/') != -1)
                name = name.substring(entryPath.lastIndexOf('/')+1, name.length());
            // make sure that tmp files are fresh
            File tmpOut = File.createTempFile(name, ".part", destinationFolder);
            try (InputStream zipIn = zf.getInputStream(entry)) {
                try (BufferedOutputStream fileOut = new BufferedOutputStream(new FileOutputStream(tmpOut))) {
                    final byte[] bytes = new byte[8192];
                    int cnt;
                    while ((cnt = zipIn.read(bytes)) != -1) {
                        fileOut.write(bytes, 0, cnt);
                    }
                    fileOut.flush();
                }
                // now rename
                File out = new File(destinationFolder, name);
                if(out.exists()){
                    if(!out.delete())
                        throw new IOException("Cannot delete destination file: "+ out);
                }
                if(!tmpOut.renameTo(out))
                    throw new IOException("Cannot copy to destination file: "+ out);
            } finally {
                if(tmpOut.exists())
                    tmpOut.delete();
            }
        }
    }
}