# Linux-Forensics
  Simplify generating forensic artifacts on Linux hosts with the native power of bash.

Output folder will be written to your current directory and will include:

* Network Information
* Process Information
* User Information
* System Information
* Host Timeline
* Files of Interest
  * SH/PY/BAT/PS1
  * EXE/DOC/DOCX/XLS/XLSX
  * JS/JAR/RAR/PHP
* Crontab Configuration
* Environment Variables
* Command History
* And a tarball of /var/log


## Automated Forensics Collection

[get_forensics.sh](https://raw.githubusercontent.com/Starke427/Linux-Forensics/main/get_forensics.sh) will gather forensic artifacts and place them in a timestamped output directory in your current working directory. It must be run with either sudo or root privileges.


```
curl https://raw.githubusercontent.com/Starke427/Linux-Forensics/main/get_forensics.sh > get_forensics.sh
chmod 700 get_forensics.sh
sudo ./get_forensics.sh
```
