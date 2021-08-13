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
    Edited: 11.08.2021
#>

function CreateHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] 
            [string]
            $path,
        [Parameter(Mandatory=$true)]
            [string]
            $algo
    )
           
    return (Get-FileHash -Path $path -Algorithm $algo).Hash;

    <#
    .SYNOPSIS
    Creates a HASH from file
    
    .DESCRIPTION
    Creates a HASH from a file by an algorithm
    
    .PARAMETER path
    [string] File path
    
    .PARAMETER algo
    [string] Algorithm

    .INPUTS
    Any file
    
    .OUTPUTS
    System.String. Created HASH file

    .EXAMPLE
    CreateHash -path "c:\temp" -algo "MD5"
    
    .NOTES
    #>
}

function CheckBoxAlgoritm {
    param (
        [Parameter(Mandatory=$true)] 
            [bool]
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
            $title,
        [Parameter(Mandatory=$true)]
            [string]
            $body
    )

    [windows.MessageBox]::Show($body, $title,'OK');

    <#
        .SYNOPSIS
        Show the message

        .DESCRIPTION
        Show the message only with 'OK' button

        .PARAMETER title
        [string] The title of the message

        .PARAMETER body
        [string] The body of the message

        .EXAMPLE
        Message -title "Custom title" -body "Custom body"

        .NOTES
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
    if ((Test-Path -Path $initialPath -PathType Container) -eq $true) {
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
        [string] Initial path

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
    $selectedPath = $selectedPath.Trim();

    if ([string]::IsNullOrEmpty($selectedPath) -eq $false) {
        if ((Test-Path -Path $selectedPath -PathType Container) -eq $true) {
            $_SelectFolderDialog.SelectedPath=$selectedPath;
        } else {
            $_SelectFolderDialog.SelectedPath=[System.Environment+SpecialFolder]'MyComputer';
        }
    } else {
        $_SelectFolderDialog.SelectedPath=[System.Environment+SpecialFolder]'MyComputer';
    }
 
    if ($_SelectFolderDialog.ShowDialog() -eq "OK") {
        $selectedPath=$_SelectFolderDialog.SelectedPath;
        $_SelectFolderDialog.Dispose();
        return $selectedPath;
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
        [string] Initial path

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
    if ($_var_cbMd5.IsChecked -eq $true) {$_algo += "MD5";}
    if ($_var_cbSha1.IsChecked -eq $true) {$_algo += "SHA1";}
    if ($_var_cbSha256.IsChecked -eq $true) {$_algo += "SHA256";}
    if ($_var_cbSha384.IsChecked -eq $true) {$_algo += "SHA384";}
    if ($_var_cbSha512.IsChecked -eq $true) {$_algo += "SHA512";}
    if ($_var_cbRipemd160.IsChecked -eq $true) {$_algo += "RIPEMD160";}
    if ($_var_cbMactripledes.IsChecked -eq $true) {$_algo  += "MACTripleDES";}
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

function TestPathIn {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
            [bool]
            $itIsFile
    )

    if (([string]::IsNullOrEmpty($SyncHash.GuiElements.tbIn.Text.Trim())) -eq $false) {
        if ($itIsFile -eq $true) {
            if ((Test-Path -Path $SyncHash.GuiElements.tbIn.Text.Trim() -PathType Leaf) -eq $true) {
                return $true
            }
        } else {
            if ((Test-Path -Path $SyncHash.GuiElements.tbIn.Text.Trim() -PathType Container) -eq $true) {
                return $true
            }
        }
    }

    return $false
    
        <#
        .SYNOPSIS
        Test tbIn 

        .DESCRIPTION
        Test that if tbIn.Text is a valid path

        .PARAMETER itIsFile
        [bool] Test pahh to file or folder

        .EXAMPLE
        TestPathIn -itIsFile $true

        .NOTES
    #>
}

function TestPathOut {
    if (([string]::IsNullOrEmpty($SyncHash.GuiElements.tbOut.Text.Trim())) -eq $false) {
        if ((Test-Path -Path $SyncHash.GuiElements.tbOut.Text.Trim() -PathType Container) -eq $true) {
            return $true
        }
    }

    return $false
    
        <#
        .SYNOPSIS
        Test tbOut 

        .DESCRIPTION
        Test that if tbOut.Text is a valid path

        .EXAMPLE
        TestPathOut

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
##Runspace
$Runspace = [Runspacefactory]::CreateRunspace();
$Runspace.ApartmentState = [Threading.ApartmentState]::STA; ##The Thread will create and enter a single-threaded apartment.
$Runspace.Open();
$Runspace.SessionStateProxy.SetVariable('SyncHash',$SyncHash);

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

    $SyncHash.GuiElements.tbOut.Background = "DarkGray";
    $SyncHash.GuiElements.btnOut.Background = "DarkGray";

    ## Other
    $SyncHash.GuiElements.cbOut.IsChecked = $false;

    $SyncHash.GuiElements.tbOut.Text = "";
    $SyncHash.GuiElements.tbHash.Text = "";
    if ((TestPathIn -itIsFile $true) -eq $false) {$SyncHash.GuiElements.tbIn.Text = "";}
})
$SyncHash.GuiElements.rbHashControl.add_click({ 
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

    $SyncHash.GuiElements.tbOut.Text = "";
    if ((TestPathIn -itIsFile $true) -eq $false) {$SyncHash.GuiElements.tbIn.Text = "";}

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

    $SyncHash.GuiElements.tbOut.Text = "";
    $SyncHash.GuiElements.tbHash.Text = "";
    if ((TestPathIn -itIsFile $true) -eq $false) {$SyncHash.GuiElements.tbIn.Text = "";}

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

    ## Other
    if ((TestPathIn -itIsFile $true) -eq $false) {$SyncHash.GuiElements.tbIn.Text = "";}

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

    ## Other
    if ((TestPathIn -itIsFile $true) -eq $true) {
        $SyncHash.GuiElements.tbIn.Text = (Get-Item -Path $SyncHash.GuiElements.tbIn.Text.Trim()).Directory;
    }
})
$SyncHash.GuiElements.btnIn.add_click({
    [string]$_tempPath;
    if (($SyncHash.GuiElements.rbCreateHash.IsChecked -eq $true) `
    -or ($SyncHash.GuiElements.rbHashControl.IsChecked -eq $true) `
    -or ($SyncHash.GuiElements.rbControlFromFile.IsChecked -eq $true) `
    -or ($SyncHash.GuiElements.rbCreateHashSum.IsChecked -eq $true)) {
            
        if ((TestPathIn -itIsFile $true) -eq $true) {
            $_tempPath = SelectFile -initialPath ((Get-Item -Path $SyncHash.GuiElements.tbIn.Text.Trim()).Directory);
        } elseif ((TestPathIn -itIsFile $false) -eq $true) {
            $_tempPath = SelectFile -initialPath $SyncHash.GuiElements.tbIn.Text;
        } else {
            $_tempPath = SelectFile -initialPath "C:\";
        }
    } else {
        if ((TestPathIn -itIsFile $true) -eq $true) {
            $_tempPath = SelectFolder -selectedPath ((Get-Item -Path $SyncHash.GuiElements.tbIn.Text.Trim()).Directory);
        } elseif ((TestPathIn -itIsFile $false) -eq $true) {
            $_tempPath = SelectFolder -selectedPath $SyncHash.GuiElements.tbIn.Text;
        } else {
            $_tempPath = SelectFolder -selectedPath "C:\";
        }      
    }
    if ([string]::IsNullOrEmpty($_tempPath) -eq $false ){
        $SyncHash.GuiElements.tbIn.Text = $_tempPath.Trim();
    }
    if ((($SyncHash.GuiElements.rbCreateHashSum.IsChecked -eq $true) `
    -or ($SyncHash.GuiElements.rbCreateHashSumMore.IsChecked -eq $true)) `
    -and ($SyncHash.GuiElements.cbOut.IsChecked -eq $true)) {
        if (([String]::IsNullOrEmpty($_tempPath.Trim())) -eq $false) {
            if ((Test-Path -Path $_tempPath.Trim()) -eq $true) {
                $SyncHash.GuiElements.tbOut.Text = (Get-Item -Path $_tempPath.Trim()).Directory; ## TODO test
            }
        }
    }
})
$SyncHash.GuiElements.cbOut.add_click({
    switch ($SyncHash.GuiElements.cbOut.IsChecked) {
        $true  {
            ## Enable Component
            $SyncHash.GuiElements.lbOut.IsEnabled = $false;
            $SyncHash.GuiElements.tbOut.IsEnabled = $false;
            $SyncHash.GuiElements.btnOut.IsEnabled = $false;

            ## Colored Components
            $SyncHash.GuiElements.tbOut.Background = "DarkGray";
            $SyncHash.GuiElements.btnOut.Background = "DarkGray";

            ## Other
            if ($SyncHash.GuiElements.rbCreateHashSumMore.IsChecked -eq $true) {
                $SyncHash.GuiElements.tbOut.Text = $SyncHash.GuiElements.tbIn.Text.Trim();
            }
            if ($SyncHash.GuiElements.rbCreateHashSum.IsChecked -eq $true) {  ##TODO change
                if (([String]::IsNullOrEmpty($SyncHash.GuiElements.tbIn.Text.Trim())) -eq $false) {
                    if ((Test-Path -Path $SyncHash.GuiElements.tbIn.Text.Trim()) -eq $false) {
                        $SyncHash.GuiElements.tbOut.Text = (Get-Item -Path $SyncHash.GuiElements.tbIn.Text.Trim()).Directory; ## TODO test
                    }
                }
            }
        }
        $false {
            ## Enable Component
            $SyncHash.GuiElements.lbOut.IsEnabled = $true;
            $SyncHash.GuiElements.tbOut.IsEnabled = $true;
            $SyncHash.GuiElements.btnOut.IsEnabled = $true;

            ## Colored Components
            $SyncHash.GuiElements.tbOut.Background = "LightGreen";
            $SyncHash.GuiElements.btnOut.Background = "LightGreen";
        }
    }
})
$SyncHash.GuiElements.btnOut.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.btnGo.add_click({
    [bool]$canGo = $true;
    ##Test tbIn
    if (($SyncHash.GuiElements.rbCreateHash.IsChecked -eq $true) `
    -or ($SyncHash.GuiElements.rbHashControl.IsChecked -eq $true) `
    -or ($SyncHash.GuiElements.rbControlFromFile.IsChecked -eq $true) `
    -or ($SyncHash.GuiElements.rbCreateHashSum.IsChecked -eq $true)) {
        if ((TestPathIn -itIsFile $true) -eq $false) {
            Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Chyba zad$([char]0x00E1)n$([char]0x00ED) cesty k souboru !!!";
            $canGo = $false;
        }
    }
    if ($SyncHash.GuiElements.rbCreateHashSumMore.IsChecked -eq $true) {
        if ((TestPathIn -itIsFile $false) -eq $false) {
            Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Chyba zad$([char]0x00E1)n$([char]0x00ED) cesty ke slo$([char]0x017E)ce se soubory !!!";
            $canGo = $false;
        } 
    }

    ##Test tbHash
    if ($SyncHash.GuiElements.rbHashControl.IsChecked -eq $true) {
        if (([string]::IsNullOrEmpty($SyncHash.GuiElements.tbHash.Text.Trim())) -eq $true) {
            Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Nen$([char]0x00ED) zad$([char]0x00E1)n kontroln$([char]0x00ED) HASH !!!";
            $canGo = $false;            
        }
    } 

    ##Test tbOut
    if (($SyncHash.GuiElements.rbCreateHashSum.IsChecked -eq $true) `
    -or ($SyncHash.GuiElements.rbCreateHashSumMore.IsChecked -eq $true)) {
        if ((TestPathOut) -eq $false) {
            Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Chyba zad$([char]0x00E1)n$([char]0x00ED) cesty k v$([char]0x00FD)stupn$([char]0x00ED) slo$([char]0x017E)ce !!!";
            $canGo = $false;
        }
    }

    ##TODO Disable components

    ##GO
    if ($canGo -eq $true) {Write-Host "Disable components";Write-Host "DRY RUN";}
    else {Write-Host "CAN'T GO";}

    ##TODO Enable components


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

$SyncHash.Window.add_closing({
    ##TODO if Session stil work than cancel "Closing"
})

$SyncHash.Window.add_closed({
    ##TODO Session test
    $Runspace.Close();
})

$SyncHash.Window.ShowDialog() | Out-Null;
