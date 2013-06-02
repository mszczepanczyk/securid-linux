Use [stoken](https://github.com/cernekee/stoken).
   
---
   
   
   
    
This is a set of scripts for running RSA SecurID from the Linux command 
line.

### Setting up:

1. Install wine and xvfb:

    ```
    $ apt-get install wine xvfb
    ```

2. Download and install SecurID software using wine:

    Unfortunately version 3.0 is no longer available from RSA. The latest version won't work.

3. Import your token file and set the advanced view (View -> Advanced View):

    ```
    $ wine "C:\Program Files\RSA Security\RSA SecurID Software Token\SecurID.exe"
    ```

4. Download and unpack AutoHotkey:
    
    ```
    $ wget http://www.autohotkey.com/download/AutoHotkey.zip
    $ unzip -x AutoHotkey.zip -d AutoHotkey
    ```

5. Set your pin code inside securid.ahk file.

### Running:

```
$ chmod +x securid.sh
$ ./securid.sh
Remaining time:   12 Sec
Current PASSCODE: 23641982
Next PASSCODE:    74382911
```
