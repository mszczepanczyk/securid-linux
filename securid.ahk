;; Mariusz Szczepańczyk <mszczepanczyk@gmail.com>
;; 2012-06-17

PinCode = 12345678
SecurID = C:\Program Files\RSA Security\RSA SecurID Software Token\SecurID.exe
WinTitle = Software Token
WinText = Current PASSCODE

#Include stdio.ahk
StdioInitialize()

SetTitleMatchMode, 2

Run, %SecurID%

WinWait, %WinTitle%, %WinText%
IfWinNotActive, %WinTitle%, %WinText%, WinActivate, %WinTitle%, %WinText%
WinWaitActive, %WinTitle%, %WinText%

;; waiting for initialization
Loop {
    ControlGetText, time, Static10
    if time = "60 Sec"
        Sleep, 100
    else
        break
}

;; typing in the pin code and applying
ControlSend, Edit1, %PinCode%
ControlSend, Edit1, {Enter}

;; waiting for password
Loop {
    ControlGetText, pass1, Edit2
    if pass1 = ""
        Sleep, 100
    else
        break
}


;; getting values
ControlGetText, time, Static10
ControlGetText, pass1, Edit2
ControlGetText, pass2, Edit3
;ControlGetText, token1, Edit4
;ControlGetText, token2, Edit5

;; printing result
printf("Remaining time:   ")
printf(time)
printf("`nCurrent PASSCODE: ")
printf(pass1)
printf("`nNext PASSCODE:    ")
printf(pass2)
printf("`n")


;; closing
WinClose, %WinTitle%, %WinText%
ExitApp
