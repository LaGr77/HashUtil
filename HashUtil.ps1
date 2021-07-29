<#
.SYNOPSIS
    Compare/create 'HASH' of file
.DESCRIPTION
    Compare/create 'HASH' of file, create "SUMS" file (example: MD5SUMS)
.INPUTS
    Any file (to create 'HASH') or text file with list of 'HASHes' and filenames
.OUTPUTS
    Text file with list of 'HASHes' and filenames
.EXAMPLE
    PS> HashUtil.ps1
.NOTES
    Author: Ing.Ladislav Grulich
    Create: 18.05.2021
    Edited: 13.07.2021
#>

function CreateHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] 
            [string]
            #File path
            $path,
        [Parameter(Mandatory=$true)]
            [string]
            #algorithm
            $algo
    )
           
    return (Get-FileHash -Path $path -Algorithm $algo).Hash;

    <#
    .SYNOPSIS
    Creates a HASH from file
    
    .DESCRIPTION
    Creates a HASH from a file by an algorithm
    
    .PARAMETER path
    File path
    
    .PARAMETER algo
    Algorithm

    .INPUTS
    Any file
    
    .OUTPUTS
    System.String. Created HASH file

    .EXAMPLE
    CreateHash -path "c:\temp" -algo "MD5"
    
    .NOTES
    Look at "Parameter(Mandatory=$true)"
    #>
}

function CheckBoxAlgoritm {
    param (
        [Parameter(Mandatory=$true)] 
            [bool]
            #status of check boxes;
            $status
    )
    
    $SyncHash.GuiElements.cbMd5.IsChecked = $status;
    $SyncHash.GuiElements.cbSha1.IsChecked = $status;
    $SyncHash.GuiElements.cbSha256.IsChecked = $status;
    $SyncHash.GuiElements.cbSha384.IsChecked = $status;
    $SyncHash.GuiElements.cbSha512.IsChecked = $status;
    $SyncHash.GuiElements.cbRipemd160.IsChecked = $status;
    $SyncHash.GuiElements.cbMactripledes.IsChecked = $status;

        <#
    .SYNOPSIS
    Changes the status of check boxes
    
    .DESCRIPTION
    Changes the status of check boxes
    
    .PARAMETER status
    [bool] status
    
    .INPUTS
    nothing
    
    .OUTPUTS
    noting

    .EXAMPLE
    CheckBoxAlgoritm status $true
    
    .NOTES

    #>

}

function Message {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
            [string]
            #The title of the message
            $title,
        [Parameter(Mandatory=$true)]
            [string]
            #The body of the message
            $body
    )
    #[Windows.MessageBox]::Show('A command is still running.')
    [windows.MessageBox]::Show($body, $title,'OK');

    <#
        .SYNOPSIS
        Show the message

        .DESCRIPTION
        Show the message only with 'OK' button

        .PARAMETER title
        The title of the message

        .PARAMETER body
        The body of the message

        .EXAMPLE
        Message -title "Custom title" -body "Custom body"

        .NOTES
        Look at "Parameter(Mandatory=$true)"
    #>
}

function SelectFile {
    [CmdletBinding()]
    param (
        [Parameter()]
            [string]
            $initialPath = "C:\"
    )

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null;
    
    $_SelectFileDialog = [System.Windows.Forms.OpenFileDialog]::new();
    $_SelectFileDialog.Multiselect=$false;
    if (Test-Path -Path $initialPath -PathType Container) {
        $_SelectFileDialog.InitialDirectory=$initialPath;
    } else {
        $_SelectFileDialog.InitialDirectory=$PSScriptRoot;
    }
    ##$_SelectFileDialog.filter = "CSV (*.csv)| *.csv"
    if ($_SelectFileDialog.ShowDialog() -eq "OK") {
        $_path=$_SelectFileDialog.FileName;
        $_SelectFileDialog.Dispose();
        return $_path;
    } else {
        $_SelectFileDialog.Dispose();
        return "";
    }

    <#
        .SYNOPSIS
        Find file

        .DESCRIPTION
        Find file and return path

        .PARAMETER initialPath
        Initial path

        .EXAMPLE
        SelectFile
        
        .EXAMPLE
        SelectFile -initialPath "C:\"

        .NOTES
    #>
}

function SelectFolder {
    [CmdletBinding()]
    param (
        [Parameter()]
            [string]
            $selectedPath = "C:\"
    )

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null;
    $_SelectFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog;
    $_SelectFolderDialog.ShowNewFolderButton=$false;

    if (!($selectedPath -eq "")) {
        if (Test-Path -Path $selectedPath -PathType Any) {
            $_SelectFolderDialog.SelectedPath=$selectedPath;
        } else {
            $_SelectFolderDialog.SelectedPath=[System.Environment+SpecialFolder]'MyComputer';
        }
    } else {
        $_SelectFolderDialog.SelectedPath=[System.Environment+SpecialFolder]'MyComputer';
    }
 
    if ($_SelectFolderDialog.ShowDialog() -eq "OK") {
        $_path=$_SelectFolderDialog.SelectedPath;
        $_SelectFolderDialog.Dispose();
        return $_path;
    } else {
        $_SelectFolderDialog.Dispose();
        return "";
    }

    <#
        .SYNOPSIS
        Find folder

        .DESCRIPTION
        Find folder and return path

        .PARAMETER selectedPath
        Initial path

        .EXAMPLE
        SelectFolder
        
        .EXAMPLE
        SelSelectFolderectFile selectedPath "C:\Temp"

        .NOTES
        (TODO) try to be simillar as SelectFile
        (TODO) work with UNC path
    #>
}

function ReturnAlgoritm {
    [array]$_algo = @();
    if ($_var_cbMd5.IsChecked) {$_algo += "MD5";}
    if ($_var_cbSha1.IsChecked) {$_algo += "SHA1";}
    if ($_var_cbSha256.IsChecked) {$_algo += "SHA256";}
    if ($_var_cbSha384.IsChecked) {$_algo += "SHA384";}
    if ($_var_cbSha512.IsChecked) {$_algo += "SHA512";}
    if ($_var_cbRipemd160.IsChecked) {$_algo += "RIPEMD160";}
    if ($_var_cbMactripledes.IsChecked) {$_algo  += "MACTripleDES";}
    if ($_algo.Count -eq 0) {$_algo += "MD5";}
    
    return $_algo;

    <#
    .SYNOPSIS
    Returns the selected algorithm
    
    .DESCRIPTION
    Returns the selected algorithm or 'All' for batch processing
    
    .EXAMPLE
    ReturnAlgoritm
    
    .NOTES
    #>
}


## Gui
##Set-Location -Path $PSScriptRoot;
Add-Type -AssemblyName 'PresentationCore', 'PresentationFramework';
[Xml]$WpfFile = Get-Content -Path $PSScriptRoot'\HashUtil.xaml';
$WpfFile.Window.RemoveAttribute('x:Class');
$WpfFile.Window.RemoveAttribute('mc:Ignorable');

## Namespace
$WpfNS = New-Object -TypeName Xml.XmlNamespaceManager -ArgumentList $WpfFile.NameTable;
$WpfNs.AddNamespace('x', $WpfFile.DocumentElement.x);
$WpfNs.AddNamespace('d', $WpfFile.DocumentElement.d);
$WpfNs.AddNamespace('mc', $WpfFile.DocumentElement.mc);

## Initialization 
## Synchronized HashTable, only one tread-safe variable 
$SyncHash = [Hashtable]::Synchronized(@{});
$SyncHash.Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $WpfFile));
$SyncHash.GuiElements = @{};

foreach ($N in $WpfFile.SelectNodes('//*[@x:Name]', $WpfNs)) {
    $SyncHash.GuiElements.Add($N.Name, $SyncHash.Window.FindName($N.Name));  
}

## Remove
$SyncHash.GuiElements.Count;

## NO tread
$SyncHash.GuiElements.rbCreateHash.add_click({
    ## Enable Components
    $SyncHash.GuiElements.lbIn.IsEnabled = $true;
    $SyncHash.GuiElements.tbIn.IsEnabled = $true;
    $SyncHash.GuiElements.btnIn.IsEnabled = $true;

    $SyncHash.GuiElements.lbHash.IsEnabled = $false;
    $SyncHash.GuiElements.tbHash.IsEnabled = $false;

    $SyncHash.GuiElements.cbOut.IsEnabled = $false;

    $SyncHash.GuiElements.lbOut.IsEnabled = $false;
    $SyncHash.GuiElements.tbOut.IsEnabled = $false;
    $SyncHash.GuiElements.btnOut.IsEnabled = $false;

    ## Colored Components
    $SyncHash.GuiElements.tbIn.Background = "LightGreen";
    $SyncHash.GuiElements.btnIn.Background = "LightGreen";

    $SyncHash.GuiElements.tbHash.Background = "DarkGray";

    ## Other
    $SyncHash.GuiElements.cbOut.IsChecked = $false;

    <#    
    if (!([string]::IsNullOrEmpty($SyncHash.GuiElements.tbIn.Text.Trim()))) {
        if (Test-Path -Path $SyncHash.GuiElements.tbIn.Text.Trim() -PathType Any) {
            if (((Get-Item $SyncHash.GuiElements.tbIn.Text.Trim()) -is [System.IO.DirectoryInfo])) {
                $SyncHash.GuiElements.tbIn.Text = "";
            }           
        }
    }

    #$SyncHash.GuiElements.tbOut.Background = "DarkGray";
    $SyncHash.GuiElements.tbOut.Text = "";
    #$SyncHash.GuiElements.btnOut.Background = "DarkGray";#>
})
$SyncHash.GuiElements.rbHashControl.add_click({ ##TODO : vynulování komponent
    ## Enable Component
    $SyncHash.GuiElements.lbIn.IsEnabled = $true;
    $SyncHash.GuiElements.tbIn.IsEnabled = $true;
    $SyncHash.GuiElements.btnIn.IsEnabled = $true;

    $SyncHash.GuiElements.lbHash.IsEnabled = $true;
    $SyncHash.GuiElements.tbHash.IsEnabled = $true;

    $SyncHash.GuiElements.cbOut.IsEnabled = $false;

    $SyncHash.GuiElements.lbOut.IsEnabled = $false;
    $SyncHash.GuiElements.tbOut.IsEnabled = $false;
    $SyncHash.GuiElements.btnOut.IsEnabled = $false;

    ## Colored Components
    $SyncHash.GuiElements.tbIn.Background = "LightGreen";
    $SyncHash.GuiElements.btnIn.Background = "LightGreen";

    $SyncHash.GuiElements.tbHash.Background = "LightGreen";

    $SyncHash.GuiElements.tbOut.Background = "DarkGray";
    $SyncHash.GuiElements.btnOut.Background = "DarkGray";

    ## Other
    $SyncHash.GuiElements.cbOut.IsChecked = $false;

})
$SyncHash.GuiElements.rbControlFromFile.add_click({
    ## Enable Component
    $SyncHash.GuiElements.lbIn.IsEnabled = $true;
    $SyncHash.GuiElements.tbIn.IsEnabled = $true;
    $SyncHash.GuiElements.btnIn.IsEnabled = $true;

    $SyncHash.GuiElements.lbHash.IsEnabled = $false;
    $SyncHash.GuiElements.tbHash.IsEnabled = $false;

    $SyncHash.GuiElements.cbOut.IsEnabled = $false;

    $SyncHash.GuiElements.lbOut.IsEnabled = $false;
    $SyncHash.GuiElements.tbOut.IsEnabled = $false;
    $SyncHash.GuiElements.btnOut.IsEnabled = $false;

    ## Colored Components
    $SyncHash.GuiElements.tbIn.Background = "LightGreen";
    $SyncHash.GuiElements.btnIn.Background = "LightGreen";

    $SyncHash.GuiElements.tbHash.Background = "DarkGray";

    $SyncHash.GuiElements.tbOut.Background = "DarkGray";
    $SyncHash.GuiElements.btnOut.Background = "DarkGray";

    ## Other
    $SyncHash.GuiElements.cbOut.IsChecked = $false;

    <#
    $SyncHash.GuiElements.tbOut.Text = "";
#>
})
$SyncHash.GuiElements.rbCreateHashSum.add_click({
    ## Enable Component
    $SyncHash.GuiElements.lbIn.IsEnabled = $true;
    $SyncHash.GuiElements.tbIn.IsEnabled = $true;
    $SyncHash.GuiElements.btnIn.IsEnabled = $true;

    $SyncHash.GuiElements.lbHash.IsEnabled = $false;
    $SyncHash.GuiElements.tbHash.IsEnabled = $false;
    
    $SyncHash.GuiElements.cbOut.IsEnabled = $true;
    
    $SyncHash.GuiElements.lbOut.IsEnabled = switch ($SyncHash.GuiElements.cbOut.IsChecked) {
        $true    { $false }
        $false   { $true }
    }
    $SyncHash.GuiElements.tbOut.IsEnabled = switch ($SyncHash.GuiElements.cbOut.IsChecked) {
        $true    { $false }
        $false   { $true }
    }
    $SyncHash.GuiElements.btnOut.IsEnabled = switch ($SyncHash.GuiElements.cbOut.IsChecked) {
        $true    { $false }
        $false   { $true }
    }

    ## Colored Components
    $SyncHash.GuiElements.tbIn.Background = "LightGreen";
    $SyncHash.GuiElements.btnIn.Background = "LightGreen";

    $SyncHash.GuiElements.tbHash.Background = "DarkGray";

    $SyncHash.GuiElements.tbOut.Background = switch ($SyncHash.GuiElements.cbOut.IsChecked) {
        $true  { "DarkGray" }
        $false { "LightGreen" }
    }
    $SyncHash.GuiElements.btnOut.Background = switch ($SyncHash.GuiElements.cbOut.IsChecked) {
        $true  { "DarkGray" }
        $false { "LightGreen" }
    }

})
$SyncHash.GuiElements.rbCreateHashSumMore.add_click({ ## TODO Change file 2 folder
    ## Enable Component
    $SyncHash.GuiElements.lbIn.IsEnabled = $true;
    $SyncHash.GuiElements.tbIn.IsEnabled = $true;
    $SyncHash.GuiElements.btnIn.IsEnabled = $true;

    $SyncHash.GuiElements.lbHash.IsEnabled = $false;
    $SyncHash.GuiElements.tbHash.IsEnabled = $false;

    $SyncHash.GuiElements.cbOut.IsEnabled = $true; 

    $SyncHash.GuiElements.lbOut.IsEnabled = switch ($SyncHash.GuiElements.cbOut.IsChecked) {
        $true    { $false }
        $false   { $true }
    }
    $SyncHash.GuiElements.tbOut.IsEnabled = switch ($SyncHash.GuiElements.cbOut.IsChecked) {
        $true    { $false }
        $false   { $true }
    }
    $SyncHash.GuiElements.btnOut.IsEnabled = switch ($SyncHash.GuiElements.cbOut.IsChecked) {
        $true    { $false }
        $false   { $true }
    }

    ## Colored Components
    $SyncHash.GuiElements.tbIn.Background = "LightGreen";
    $SyncHash.GuiElements.btnIn.Background = "LightGreen";

    $SyncHash.GuiElements.tbHash.Background = "DarkGray";   
    
    $SyncHash.GuiElements.tbOut.Background = switch ($SyncHash.GuiElements.cbOut.IsChecked) {
        $true  { "DarkGray" }
        $false { "LightGreen" }
    }
    $SyncHash.GuiElements.btnOut.Background = switch ($SyncHash.GuiElements.cbOut.IsChecked) {
        $true  { "DarkGray" }
        $false { "LightGreen" }
    }
})
$SyncHash.GuiElements.btnIn.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.cbOut.add_click({
    if ($SyncHash.GuiElements.cbOut.IsChecked) {
        $SyncHash.GuiElements.lbOut.IsEnabled = $false;
        $SyncHash.GuiElements.tbOut.IsEnabled = $false;
        #$SyncHash.GuiElements.tbOut.Background = "DarkGray";
        $SyncHash.GuiElements.btnOut.IsEnabled = $false;
        #$SyncHash.GuiElements.btnOut.Background = "DarkGray";
        if ($SyncHash.GuiElements.rbCreateHashSumMore.IsChecked) {
            $SyncHash.GuiElements.tbOut.Text = $SyncHash.GuiElements.tbIn.Text.Trim();
        }
        if ($SyncHash.GuiElements.rbCreateHashSum.IsChecked) {
            if (!([string]::IsNullOrEmpty($SyncHash.GuiElements.tbIn.Text.Trim()))) {
                if (Test-Path -Path $SyncHash.GuiElements.tbIn.Text.Trim() -PathType Any) {
                    $SyncHash.GuiElements.tbOut.Text = (Get-ChildItem $SyncHash.GuiElements.tbIn.Text.Trim()).Directory;
                }
            }
        }
    } else {
        $SyncHash.GuiElements.lbOut.IsEnabled = $true;
        $SyncHash.GuiElements.tbOut.IsEnabled = $true;
        #$SyncHash.GuiElements.tbOut.Background = "LightGreen";
        $SyncHash.GuiElements.btnOut.IsEnabled = $true;
        #$SyncHash.GuiElements.btnOut.Background = "LightGreen";
        $SyncHash.GuiElements.tbOut.Text = "";
    }
})
$SyncHash.GuiElements.btnOut.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.btnGo.add_click({
    [bool]$canGo = $true;
    ##Test
    if ($SyncHash.GuiElements.rbCreateHash.IsChecked -or $SyncHash.GuiElements.rbHashControl.IsChecked) {
        if ([string]::IsNullOrEmpty($SyncHash.GuiElements.tbIn.Text.Trim())) {
            Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Chyba zad$([char]0x00E1)n$([char]0x00ED) cesty k souboru !!!";
            $canGo = $false;
        } elseif ((Test-Path -Path $SyncHash.GuiElements.tbIn.Text.Trim() -PathType Leaf) -eq $false) {
            Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Soubor neexistuje !!!";
            $canGo = $false;
        }
    }
    if ($SyncHash.GuiElements.rbHashControl.IsChecked) {
        if ([string]::IsNullOrEmpty($SyncHash.GuiElements.tbHash.Text.Trim())) {
            Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Nen$([char]0x00ED) zad$([char]0x00E1)n kontroln$([char]0x00ED) HASH !!!";
            $canGo = $false;            
        }
    } 
    if ($SyncHash.GuiElements.rbControlFromFile.IsChecked) {
        $canGo = $false;
    }
    ##GO
    if ($canGo) {Write-Host "DRY RUN";}
    else {Write-Host "CAN'T GO";}



    

})
$SyncHash.GuiElements.btnRefresh.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.btnClear.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.btnExport.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.btnExit.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})

$SyncHash.GuiElements.btnAll.add_click({CheckBoxAlgoritm -status $true;})
$SyncHash.GuiElements.btnNothing.add_click({CheckBoxAlgoritm -status $false;})

$SyncHash.GuiElements.rbCzech.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.rbEnglish.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.rbRussian.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})

##$SyncHash.Jobs = [System.Collections.ArrayList]@();

## Runaspace

$SyncHash.Window.ShowDialog() | Out-Null;

# SIG # Begin signature block
# MIIGiwYJKoZIhvcNAQcCoIIGfDCCBngCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoOJ7xqnFlzlCV+D5fIJvgx8Y
# 7RugggPPMIIDyzCCArOgAwIBAgIQViGHnYe7vJpGUgpAqX3B/zANBgkqhkiG9w0B
# AQUFADBwMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxGDAWBgoJkiaJk/IsZAEZFghk
# ZHBvcnViYTEXMBUGA1UEAwwOZGRwb3J1YmEubG9jYWwxJDAiBgkqhkiG9w0BCQEW
# FWxncnVsaWNoQGRzcG9ydWJhLmNvbTAeFw0yMDA2MTcwODEwMzNaFw0zMDA2MTcw
# ODIwMzNaMHAxFTATBgoJkiaJk/IsZAEZFgVsb2NhbDEYMBYGCgmSJomT8ixkARkW
# CGRkcG9ydWJhMRcwFQYDVQQDDA5kZHBvcnViYS5sb2NhbDEkMCIGCSqGSIb3DQEJ
# ARYVbGdydWxpY2hAZHNwb3J1YmEuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
# MIIBCgKCAQEAwBDuWaGtQ+DLvep5GfZueKeW5uK9sDCSKOgxicig5Ca7QK/U61qe
# s24XNu1r0xNcsHGHwXhviMXKYoIgnx4NoX4rXyETzNpAVHrFBOVncAsMMcQouNUo
# TiRGOcktXLG4iYawXTJa9nQzP73pEHqm17bwVE3lbcZANr2rX8U82spLCmTETdJQ
# Sn7yLwo88pWv6Ug3jW+N9GD4ganQcqv3AF8P/0ieOggEE02noApAuHPcoJpsuhhi
# ModqRedFVcUXwzgQm7bdN+A6UcCB6vMh2RK2HlaW0aRcX219dIFm/iY0cQSu0Bd0
# 4QUXZQXehKjJEtLpdTcfviWQWouPly0XRQIDAQABo2EwXzAOBgNVHQ8BAf8EBAMC
# B4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwGQYDVR0RBBIwEIIOZGRwb3J1YmEubG9j
# YWwwHQYDVR0OBBYEFAmwge0l28AM51uv3geLKcRHg7G7MA0GCSqGSIb3DQEBBQUA
# A4IBAQAO5gr4bFb1QTb9y0S9X6enyWPGFAFEFUdx+LCy2Va8n/9jcG6veMef5bBB
# xs/3M2mSR0WooG8wgXnvaKiRf19NBRjLw1M2h1uyKnwcUyudU+FM551Wzvqtrhnv
# EwtTPZHnIpJb+WfpGKsElQSmDfD4i4cIUI37F3ZJ+70heuBqpj/QclWtfrIhvKOf
# 2gQbigPMhhh54PrSho6Psyyfo4pEq5ZNxoyTtWoyGsKwqPvKAJI+vxlluPzoFLNl
# 1onRcci3ZDtszd//RofPO+EHDHBV0BSiyZcSsbFxQPSy9pUOPi46RqbhsPm0te+S
# 9Uw4nsXECZcI80zx9oZ1Dd0zLp5TMYICJjCCAiICAQEwgYQwcDEVMBMGCgmSJomT
# 8ixkARkWBWxvY2FsMRgwFgYKCZImiZPyLGQBGRYIZGRwb3J1YmExFzAVBgNVBAMM
# DmRkcG9ydWJhLmxvY2FsMSQwIgYJKoZIhvcNAQkBFhVsZ3J1bGljaEBkc3BvcnVi
# YS5jb20CEFYhh52Hu7yaRlIKQKl9wf8wCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcC
# AQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYB
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFCl1st1K3TrQ
# LSufFuAzVaAq3o3iMA0GCSqGSIb3DQEBAQUABIIBACay80+I4WYXeIGdNStwNXnN
# lR9jUHxLaZKVY4YSCsY+e60Ny/iTmIdSyj27+GtL6GrWRJGWL60oEtRwFRSAlT1w
# Xbp9CSgbZBvwl/6e8AFPlxNlHuR32LuNp1M0vejsF8zrgFBNxCHN5Mir605vf/8/
# XPqqHiDLOPBxweXBiNIeXmWp18p2wt4qftaZ/1okgETt3ks8giVMgVGeUNalKikX
# 9LOFJ7XyvK3drafh7ADu5E85x2DjPltC5s0YROyS9TT+9T9uat7Gpj+z+UDKUGdE
# MqWHsAdkN1wWenAp9/357U3pu+OWcEJKAQHiasXWpjgFi11V8s7u57NDihlilmw=
# SIG # End signature block
