# GHIDRA Server Script
GHIDRA server script code from Chapter 11 - Collaborative SRE in [The GHIDRA Book - The Definitive Guide](https://nostarch.com/GhidraBook) by Chris Eagle and Kara Nance from *no starch press*.  I added some code for user input options for the GHIDRA download URL and SHA256 confirmation hash.

* [GHIDRA download](https://github.com/NationalSecurityAgency/ghidra/releases)
* [Supported JAVA versions](https://htmlpreview.github.io/?https://github.com/NationalSecurityAgency/ghidra/blob/Ghidra_10.3.2_build/GhidraDocs/InstallationGuide.html#Requirements)
* Ubuntu APT package: `sudo apt install openjdk-<version>-jdk`

## Usage
```bash
./ghidra.sh <http_ghidra_download_url> <file_sha256_hash>
```

### Example
```bash
./ghidra.sh https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.3.2_build/ghidra_10.3.2_PUBLIC_20230711.zip a658677a87d0be12ab65bd7962f471875b81a2dd2ea35d69cc3201555ca1bd6f
```
