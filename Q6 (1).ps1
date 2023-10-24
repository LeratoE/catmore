function Send
{
    param ([string] $ip, [int] $port, [string] $msg)

    #End point
    $address = [System.Net.IPAddress]::Parse($ip);                           
    try
    {
        $socket = New-Object System.Net.Sockets.TCPClient($address, $port); 
        $stream = $socket.GetStream() 

        #Send message as an array of bytes
        $data = [System.Text.Encoding]::ASCII.GetBytes($msg)
        $stream.Write($data, 0, $data.Length)

        #Close
        $stream.Close()
        $socket.Close()
    }
    catch
    {
        Write-Host "No listener"
    }
} #Send

function Encrypt
{
    param([string]$original, [int]$shift)        
     
    $private:encrypted = ""                     #1
    foreach ($ch in [char[]]$original)          #2
    {
        $encrypted += [char]([int]$ch + $shift) #2
    } #foreach ch

    return $encrypted                           #1
} #Encrypt

#Main function
function Main 
{
    Clear-Host
      
    do
    {
        #Clear-Host
        $msg = Read-Host "Message"
        $encrypted = Encrypt $msg 3

        Send "192.168.56.202" 202 $encrypted

        #Read-Host "Press Enter"

    } while ($true)
    
} #Main

#Start here
Main


function Decrypt
{
    param([string]$encrypted, [int]$shift)

    $private:original = ""                       #1
    foreach ($ch in [char[]]$encrypted)          #2
    {
        $original += [char]([int]$ch - $shift)   #2
    } #foreach ch

    return $original                             #1
} #Decrypt

function Listen
{
    # Open listener and start listening
    $port = 202
    $endpoint = new-object System.Net.IPEndPoint([ipaddress]::any,$port) 
    $listener = new-object System.Net.Sockets.TcpListener $EndPoint

    $listener.start()
    Start-Sleep -MilliSeconds 500

    cls

    #Keep on listening until the sender sends a message to stop listening
    $isListening = $true
    $i = 0
    while ($isListening)
    {
        # Wait for data
        Write-Host "Listening ..."
        $tcpClient = $listener.AcceptTcpClient() #Blocks here to wait 

        # Data arrived - get it from the stream
        $stream = $tcpClient.GetStream()
        $bytes = New-Object System.Byte[] 1024

        # Keep on reading until the stream is empty (while nBytes > 0
        while ( ($nBytes = $stream.Read($bytes,0,$bytes.Length)) -gt 0)
        {
            $Encoding = New-Object System.Text.ASCIIEncoding
            $encrypted = $Encoding.GetString($bytes,0,$nBytes)  
            $msg = Decrypt $encrypted 3
        } #while data is arriving

        #Check for stop signal
        if ($msg -like "*Stop*")
        {
            $isListening = $false;
        }
        else
        {      
            write-host "Encrypted:" $encrypted
            write-host "Decrypted:" $msg
        }  
    } #while ($isListening)

    Clear-Host
    Write-Host "Stopped"
    $listener.Stop()
    
} #Listen

Listen