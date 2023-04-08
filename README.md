# hashcomp.sh
Bash script to analyze and compare two directories to detect changes.

hashcomp

Script that analyzes and compares two directories to detect file changes.

# Description

I needed a tool that was able to analyze and compare the contents from two directories in order to evaluate if the content from a due second directory is equal to the content from the first one. Then, I wrote this script. It is a kind of file integrity check. 

# hashcomp.sh checksum

MD5SUM: 9b578bee68c9e0f99ce51cad655c8572 hashcomp.sh //
SHA1SUM: b7e06b1415b3e9c901ae0c460cf8f72b3a43daf5 hashcomp.sh //
SHA256SUM: 0edff77c0635dafd25b9225c8106d70d0c637bdda044169678ea747d0514cc8e hashcomp.sh

# Use Premises

1 - You need to evaluate the contents of a copy / clone / shadow directory. Eg. /home/user/dir2, created from, Eg. /home/user/di1

2 - You absolutely trust all the contents from /home/user/dir1

3 - You want to pass /home/user/dir1 and /home/user/dir2 as aguments to analyze and respond the following questions:

  - Is /home/user/dir2 equal to /home/user/dir1?
  - Is there any content change on /home/user/dir2? If so,
  - What files in /home/user/dir2 have changed: [HASH path/filename]?
  - Do /home/user/dir1 and /home/user/dir2 have the same number of objects? If don't, 
  - What files/objects are missing in /home/user/dir1 OR /home/user/dir2 [HASH path/filename]?

# Usage

$ git clone [url repo.git]

$ chmod u+x hashcomp.sh

$ chmod 755 -R /home/user/dir1 && chmod 755 -R /home/user/dir2

$ chown -R user:user /home/user/dir1 && chown -R user:user /home/user/dir2

$./hashcomp.sh [directory you trust] [directory you don't trust and want to compare] [md5sum|sha1sum|sha256sum|sha512sum]

[*] Choose only one algorithm at time. Always in the order as shown above.

[*] A folder called results will be created after finishing script execution.

# Test Cases

- Is /home/user/dir2 equal to /home/user/dir1?

![h1](https://user-images.githubusercontent.com/39169975/230681778-bc7b0bd4-923e-491c-9f2d-5b1e359673b0.jpg)


- Is there any content change on /home/user/dir2? If so,
- What files in /home/user/dir2 have changed: [HASH path/filename]?

![image](https://user-images.githubusercontent.com/39169975/230682003-a1f9b534-4d58-4f91-bcef-d13a32271a0a.png)


- Do /home/user/dir1 and /home/user/dir2 have the same number of objects? If don't, 
- What files/objects are missing in /home/user/dir2 related to dir1 [HASH path/filename]?

![image](https://user-images.githubusercontent.com/39169975/230682385-dca36a9d-9b58-4bd1-a5cd-9d04bececd97.png)

- What files are missing on /home/user/dir1 related to dir2 [HASH path/filename]?

![image](https://user-images.githubusercontent.com/39169975/230682622-b7562e83-3ce5-4e35-b23d-d46a2c9d4d96.png)

# BUGS / TIPS

You can report any bugs or tips in the comments as well as fork and submit a merge request :)

# Tested on

Distributor ID: Kali 
Description: Kali GNU/Linux Rolling 
Release: 2023.1 
Codename: kali-rolling
