import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.Instrumentation;
import java.security.ProtectionDomain;
import java.io.FileOutputStream;
import java.nio.file.Files;
import java.nio.file.Paths;

public class ClassDumper {
    public static void premain(String agentArgs, Instrumentation inst) {
        String outputDir = agentArgs != null && !agentArgs.isEmpty() ? agentArgs : "./dumped";
        System.out.println("[ClassDumper] Dumping com/ctf/premium classes to: " + outputDir);
        
        inst.addTransformer(new ClassFileTransformer() {
            @Override
            public byte[] transform(ClassLoader loader, String className,
                                  Class<?> classBeingRedefined,
                                  ProtectionDomain protectionDomain,
                                  byte[] classfileBuffer) {
                // Only dump classes from com/ctf/premium package
                if (className == null || !className.startsWith("com/ctf/premium")) {
                    return null;
                }
                
                try {
                    String path = outputDir + "/" + className + ".class";
                    Files.createDirectories(Paths.get(path).getParent());
                    
                    try (FileOutputStream fos = new FileOutputStream(path)) {
                        fos.write(classfileBuffer);
                    }
                    System.out.println("[ClassDumper] Dumped: " + className);
                } catch (Exception e) {
                    System.err.println("[ClassDumper] Failed to dump " + className + ": " + e.getMessage());
                }
                
                return null;
            }
        }, true);
    }
}