
## Solution

I inspected the `application.jar` in **jadx**, discovered that many classes were encrypted with a known library (`net/roseboy/classfinal`), and that runtime information (MAC, CPU serial, HDD serial) was used to derive a machine-bound key.  Since I couldn't decrypt statically, I dumped the decrypted classes at runtime using a small Java agent (ClassDumper) and a Docker runner, recovered the license-validation logic, implemented a license key generator (AES/ECB with a hardcoded key), produced a valid premium license, and used it in the web form to get the flag.

---

## Static analysis

1. Opened `application.jar` in **jadx** and explored packages.
2. Noticed many classes were encrypted ( class bodies mangled / missing). I found references to `net/roseboy/classfinal` which is a known project that performs class encryption confirmed the behaviour by searching the repository.
3. I thought i could not decrypt it.

---


## Runtime dumping approach

Rather than trying to reverse the encryption statically, I dumped the already-decrypted class bytes while the JVM was running by using a small Java instrumentation agent that hooks class loading and writes classfile bytes to disk.

* I wrote a `ClassDumper` [ClassDumper.java](files/ClassDumper.java) Java agent with the help of AI that saves any loaded class whose name starts with `com/ctf/premium` into a directory inside the container.


The agent approach allows us to capture the in-memory decrypted `.class` files as the application loads them.

Files I used for this step:

* The driver script I used to compile the agent, build a Docker image, run the application + agent, and extract dumped classes is  [extract_classes.sh](files/extract_classes.sh) and dockerfile [Dockerfile]{files/Dockerfile}. 
* The agent manifest used: [manifest.txt](files/manifest.txt). 


## Post-dump analysis

1. Loaded the dumped `.class` files back into **jadx** . The decrypted classes are readable and show the original implementation of license validation and other logic.
2. Inspecting the premium/license validation classes revealed:

   * The license format is a Base64 of AES-encrypted JSON.
   * AES key is hardcoded in the Java code: `PCC25PREMIUM#1A2` (16 bytes).
   * AES mode is **ECB** with PKCS5/PKCS7 padding (the code used Java's `Cipher.getInstance("AES/ECB/PKCS5Padding")`).

From this I could implement a small key-generator that builds a JSON payload and encrypts it with the hardcoded key.

---

## License generator

 wrote a short Python script [getPremiumKey.py](files/getPremiumKey.py) (AES/ECB) to:
.
* Construct a new license JSON with:

  ```json
  {
    "ispremium": true,
    "isnoob": true,
    "valid_until": <timestamp_in_future>
  }
  ```
* Encrypt it with the key `PCC25PREMIUM#1A2`, Base64-encode it, and print the resulting license string.





