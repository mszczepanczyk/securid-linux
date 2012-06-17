This is a set of scripts for running RSA SecurID from the Linux command 
line.

### Setting up:

1. Install wine and xvfb:

    ```
    $ apt-get install wine xvfb
    ```

2. Download and install SecurID software:

    ```
    $ wget ftp://ftp.rsasecurity.com/pub/agents/RSASecurIDToken411.zip
    $ unzip -x RSASecurIDToken411.zip -d RSASecurIDToken411
    $ wine msiexec /i RSASecurIDToken411/RSASecurIDToken411.msi
    ```

3. Import your token file:

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
