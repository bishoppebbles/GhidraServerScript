# Ghidra Server Setup Script
Ghidra server script code from [The GHIDRA Book - The Definitive Guide](https://nostarch.com/GhidraBook) (*No Starch Press*) by Chris Eagle and Kara Nance in Chapter 11: Collaborative SRE.  This code is publicly available from the authors' [book website](https://ghidrabook.com/l) with downloadable `zip` or `tgz` versions.  This is why I've made this repo public.  I added some code for user input options for the Ghidra download URL, SHA256 confirmation hash, a user account name, and optionally, a parameter for a public IP that is most likely required if hosted in a cloud VPS.  I also change a couple other things.

### Obtaining Ghidra and Java
* [Ghidra download](https://github.com/NationalSecurityAgency/ghidra/releases)
* [Supported Java versions](https://htmlpreview.github.io/?https://github.com/NationalSecurityAgency/ghidra/blob/Ghidra_10.3.2_build/GhidraDocs/InstallationGuide.html#Requirements)
  * Ubuntu APT package: `sudo apt install openjdk-<version>-jdk`
      * Version 17 as of this writing: `openjdk-17-jdk`

## Script Usage
```bash
./ghidra.sh <ghidra_download_url> <file_sha256> <username> [<public_server_ip>]
```

### Example 1
```bash
./ghidra.sh https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.3.2_build/ghidra_10.3.2_PUBLIC_20230711.zip a658677a87d0be12ab65bd7962f471875b81a2dd2ea35d69cc3201555ca1bd6f user1 111.110.109.11
```

### Example 2 (no public IP)
```bash
./ghidra.sh https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.3.2_build/ghidra_10.3.2_PUBLIC_20230711.zip a658677a87d0be12ab65bd7962f471875b81a2dd2ea35d69cc3201555ca1bd6f user1
```
