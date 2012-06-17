;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       WinXP
; Author:         Marcus Cortes <macortes84@yahoo.com>
;
; Script Function:
;   Provides console manipulation tools for Win32 AutoHotkey scripts.
;
/*
EXAMPLE:
   ;Run this script from a command prompt.
   #Include stdio.ahk
   StdioInitialize()
   FileAppend, This method should not work with console windows, *
   printf("`n")
   printf("Hello World`n")
   RunIOWait(comspec " /c echo Hello from a child process.")
   FreeConsole()
*/
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Include stdlib.ahk

/*
FUNCTION      StdioInitialize
DESCRIPTION
   Attaches to the parent application's console window or, if there isn't one, allocates a new console window.  After
   calling this function, the script can use FileAppend to write to the console window.
RETURN VALUE
   If the function succeeds, the return value is nonzero.
   If the function fails, the return value is zero.
REMARKS
   When called by a normal console program, such as cmd.exe, the calling program will not wait for this script to exit
   before it continues processing.  That is why the command prompt (e.g. 'C:\>'), is reprinted on the console window
   before any messages from the script are printed.
*/
StdioInitialize()
{
   global
   if (!DllCall("AttachConsole", int, -1, int))
      if (!DllCall("AllocConsole", int))
         return,  false
   ;atexit("FreeConsole")
   return true
}

/*
FUNCTION      FreeConsole
DESCRIPTION
   Detaches from or deallocates the currently attached console window, if one exists.
RETURN VALUE
   If the function succeeds, the return value is nonzero.
   If the function fails, the return value is zero.
*/
FreeConsole()
{
   ;atexitrem("FreeConsole")
   return DllCall("FreeConsole", int)
}

/*
FUNCTION      printf
DESCRIPTION
   Provides support for writing to the standard output of the script (the console window).  This
   function should be used in place of Ahk's FileAppend command for writing to consoles
   because the FileAppend command does not currently support writing to consoles.  FileAppend
   also does not currently "flush" the text out of the output buffer and onto the screen until the
   program ends.  That means that no program output would be displayed until the script finishes.
RETURN VALUE
   If the function succeeds, the return value is nonzero (TRUE).
   If the function fails, the return value is zero (FALSE)
*/
printf(str)
{
   str = [%str%] ;convert escape characters while preserving leading and trailing spaces and not changing AutoTrim
   StringTrimLeft, str, str, 1
   StringTrimRight, str, str, 1
   if (hStdout := DllCall("GetStdHandle", "int", -11))
      return DllCall("WriteFile", "uint", hStdout, "uint", &str, "uint", strlen(str), "uint", malloc(BytesWritten, 4), "uint", NULL)
}

;Runs a process and sets its STDIO to the same as the current process.
/*
FUNCTION      RunIO

DESCRIPTION
   Runs a program and redirects its standard input/output to the current script's standard input/output.
   This allows a script to run other console applications and have them write to current console window,
   instead of allocating a new console window.

PARAMETERS
   CmdLine [in, optional, String]
         The command line to be executed. The maximum length of this string is 32,768 characters, including the Unicode terminating null character.
         
         the first white space–delimited token of the command line specifies the module name. If you are using a long file name that contains a space,
         use quoted strings to indicate where the file name ends and the arguments begin (see the explanation for the lpApplicationName parameter).
         If the file name does not contain an extension, .exe is appended. Therefore, if the file name extension is .com, this parameter must include
         the .com extension. If the file name ends in a period (.) with no extension, or if the file name contains a path, .exe is not appended. If the file
         name does not contain a directory path, the system searches for the executable file in the following sequence:
         1.    The directory from which the application loaded.
         2.   The current directory for the parent process.
         3.   The 32-bit Windows system directory. Use the GetSystemDirectory function to get the path of this directory.
         4.   The 16-bit Windows system directory. There is no function that obtains the path of this directory, but it is searched. The name of this directory
            is System.
         5.   The Windows directory. Use the GetWindowsDirectory function to get the path of this directory.
         6.   The directories that are listed in the PATH environment variable. Note that this function does not search the per-application path specified by
            the App Paths registry key. To include this per-application path in the search sequence, use the ShellExecute function.
         
         The system adds a terminating null character to the command-line string to separate the file name from the arguments. This divides the original
         string into two strings for internal processing.
   
   WorkingDir [in, optional, String]
         The full path to the current directory for the process. The string can also specify a UNC path.
         
         If this parameter is NULL, the new process will have the same current drive and directory as the calling process. (This feature is provided primarily
         for shells that need to start an application and specify its initial drive and working directory.)

   Reserved [in, optional, void]
         Reserved for future use.
   
   PID [in, optional, Integer]
         A variable that receives the process identifier.
   
   UsedInternally [in, optional, String]
         This parameter is used internally and should be left blank.

RETURN VALUE
   If the function succeeds, the return value is the process identifier of the child process.
   If the function fails, the return value is zero.

http://msdn.microsoft.com/en-us/library/ms682425.aspx
*/
RunIO(CommandLine, WorkingDir="", Reserved="", byref PID="", byref UsedInternally="")
{
   global
   local sa, pi, si, hStdout, hStdin, hStderror, ec
   
   ;Alloc pi and si
   malloc(pi, 16) ;PROCESS_INFORMATION
   calloc(si, 4*18, 0) ;STARTUP_INFO
   
   ;Alloc and initialize a security attributes structure
   calloc(sa, 12, 0) ;security attributes
   NumPut(12,  sa, 0, "uint")
   NumPut(0, sa, 4, "uint")
   NumPut(true, sa, 8, "int")
   
   hStdin := DllCall("GetStdHandle", int, -10, int)
   hStdout := DllCall("GetStdHandle", int, -11, int)
   hStderror := DllCall("GetStdHandle", int, -12, int)
   
   NumPut(4*18,  si, 0, "uint") ;STARTUP_INFO {HANDLE cbSize}
   NumPut(0x100, si, 4*11, "uint") ;STARTUP_INFO {dwFlags}
   NumPut(hStdin, si, 4*14, "uint") ;STARTUP_INFO {HANDLE hStdInput}
   NumPut(hStdout, si, 4*15, "uint") ;STARTUP_INFO {HANDLE hStdOutput}
   NumPut(hStderror, si, 4*16, "uint") ;STARTUP_INFO {HANDLE hStderror}
   
   if (!DllCall("CreateProcess", "uint", 0, "uint", &CommandLine, "uint", 0, "uint", 0, "int", true, "uint", 0, "uint", 0, "uint", 0, "uint", &si, "uint", &pi)) {
      ;dprint("Execution failed.")
      return false
   }
   PID := NumGet(pi, 8, "uint") ;DWORD dwProcessId
   if (UsedInternally == "LEAVE_OPEN")
      UsedInternally := NumGet(pi, 0, "uint")
   else
      DllCall("CloseHandle", "uint", NumGet(pi, 0, "uint")) ;HANDLE hProcess
   DllCall("CloseHandle", "uint", NumGet(pi, 4, "uint")) ;HANDLE hThread
   return PID
}

/*
FUNCTION      RunIOWait
DESCRIPTION
   Runs a program, redirects its standard input/output to the current script's standard input/output, and
   waits for the program to finish before returning.  To return immediately without waiting, see the RunIO
   function.  These functions allow a script to run other console applications and have them write to
   current console window rather than allocating a new console window.
PARAMETERS
   CommandLine   The command line to be executed.  See parameter for RunIO.
   WorkingDir   The full path to the current directory for the process.  See parameter for RunIO.
   Reserved      Reserved for future use.
   ExitCode      A variable that receives the exit code of the process.
   PID         A variable that receives the process identifier.
RETURN VALUE
   If the function succeeds, the return value is the process identifier of the child process.
   If the function fails, the return value is zero.
*/
RunIOWait(CommandLine, WorkingDir="", Reserved="", byref ExitCode="", byref PID="")
{
   hProcess := "LEAVE_OPEN"
   if (!RunIO(CommandLine, WorkingDir, Reserved, PID, hProcess))
      return false
   DllCall("WaitForSingleObject", "uint", hProcess, "int", -1, "uint")
   DllCall("GetExitCodeProcess", "uint", hProcess, "uint", malloc(ec, 4), "int")
   ExitCode := NumGet(ec, 0, "uint")
   DllCall("CloseHandle", "uint", hProcess)
   return, PID
}

/*
FUNCTION   
PURPOSE
   To provide a simple solution to displaying an error message to a console and quitting.
*/
ErrorExitIO(Msg="Unexpected error; quitting.", ExitCode=1, Unused="")
{
   BlockInput, Off
   FileAppend, %Msg%`n, *
   FreeConsole()
   ExitApp, ExitCode
}

;INTENDED PRIVATE
malloc(byref Var, size=0)
{
   if (cb := VarSetCapacity(Var, size) != size) {
      MsgBox 48, , Out of memory.
      ExitApp, -1
   }
   return &Var
}

calloc(byref Var, size=0, fillbyte=0)
{
   if (cb := VarSetCapacity(Var, size, fillbyte) != size) {
      MsgBox 48, , Out of memory.
      ExitApp, -1
   }
   return &Var
}

STDIO_EndOfFile:
NULL := "" ;Prevent label from pointing to something labels can't point to.
