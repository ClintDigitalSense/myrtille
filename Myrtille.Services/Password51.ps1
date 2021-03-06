# adapted from https://gallery.technet.microsoft.com/scriptcenter/Password-Text-String-34711a5e
# original script by Ken Sweet

# usage: Encrypt-RDP-Password -Password "password"
function Encrypt-RDP-Password()
{
  param (
    [String]$Password
  )
  Try
  {
    Add-Type -AssemblyName System.Security
	
	# use "LocalMachine" instead of "CurrentUser" (powershell and IIS are running under different user accounts)
	# use unicode (UTF-16LE) instead of UTF-8 in order to work with .rdp files ("password 51:b:")
	$EncryptArray = [System.Security.Cryptography.ProtectedData]::Protect($([System.Text.Encoding]::Unicode.GetBytes($Password)), $Null, "LocalMachine")
	
	Return (@($EncryptArray | ForEach-Object -Process { "{0:X2}" -f $_ }) -join "")
  }
  Catch
  {
  }
}

# usage: Decrypt-RDP-Password -PasswordHash "passwordHash"
function Decrypt-RDP-Password()
{
  param (
    [String]$PasswordHash
  )
  Try
  {
    Add-Type -AssemblyName System.Security

    $PasswordArray = @([RegEx]::Matches($PasswordHash, "(..)") | ForEach-Object -Process { [Convert]::ToByte($_, 16) })
	
	# use "LocalMachine" instead of "CurrentUser" (powershell and IIS are running under different user accounts)
	# use unicode (UTF-16LE) instead of UTF-8 in order to work with .rdp files ("password 51:b:")
	$DecryptArray = [System.Security.Cryptography.ProtectedData]::UnProtect($PasswordArray, $Null, "LocalMachine")
    
	Return $([System.Text.Encoding]::Unicode.GetString($DecryptArray))
  }
  Catch
  {
  }
}