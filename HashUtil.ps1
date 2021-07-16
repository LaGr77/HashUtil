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
        #The title of the message

        .PARAMETER body
        #The body of the message

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
    General notes
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
$SyncHash = [Hashtable]::Synchronized(@{})
$SyncHash.Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $WpfFile));
$SyncHash.GuiElements = @{};

foreach ($N in $WpfFile.SelectNodes('//*[@x:Name]', $WpfNs)) {
    $SyncHash.GuiElements.Add($N.Name, $SyncHash.Window.FindName($N.Name));  
}

## Remove
$SyncHash.GuiElements.Count;

## NO tread
$SyncHash.GuiElements.rbCreateHash.add_click({
    $SyncHash.GuiElements.lbHash.IsEnabled = $false;
    $SyncHash.GuiElements.tbHash.IsEnabled = $false;
    $SyncHash.GuiElements.tbHash.Background = "DarkGray";

    $SyncHash.GuiElements.lbIn.IsEnabled = $true;
    $SyncHash.GuiElements.tbIn.IsEnabled = $true;
    $SyncHash.GuiElements.tbIn.Background = "LightGreen";
    $SyncHash.GuiElements.btnIn.IsEnabled = $true;
    $SyncHash.GuiElements.btnIn.Background = "LightGreen";

    $SyncHash.GuiElements.cbOut.IsEnabled = $false;
    $SyncHash.GuiElements.cbOut.Background = "DarkGray";

    $SyncHash.GuiElements.lbOut.IsEnabled = $false;
    $SyncHash.GuiElements.tbOut.IsEnabled = $false;
    $SyncHash.GuiElements.tbOut.Background = "DarkGray";
    $SyncHash.GuiElements.btnOut.IsEnabled = $false;
    $SyncHash.GuiElements.btnOut.Background = "DarkGray";
})
$SyncHash.GuiElements.rbHashControl.add_click({
    $SyncHash.GuiElements.lbHash.IsEnabled = $true;
    $SyncHash.GuiElements.tbHash.IsEnabled = $true;
    $SyncHash.GuiElements.tbHash.Background = "LightGreen";

    $SyncHash.GuiElements.lbIn.IsEnabled = $true;
    $SyncHash.GuiElements.tbIn.IsEnabled = $true;
    $SyncHash.GuiElements.tbIn.Background = "LightGreen";
    $SyncHash.GuiElements.btnIn.IsEnabled = $true;
    $SyncHash.GuiElements.btnIn.Background = "LightGreen";

    $SyncHash.GuiElements.cbOut.IsEnabled = $false;
    $SyncHash.GuiElements.cbOut.Background = "DarkGray";

    $SyncHash.GuiElements.lbOut.IsEnabled = $false;
    $SyncHash.GuiElements.tbOut.IsEnabled = $false;
    $SyncHash.GuiElements.tbOut.Background = "DarkGray";
    $SyncHash.GuiElements.btnOut.IsEnabled = $false;
    $SyncHash.GuiElements.btnOut.Background = "DarkGray";
})
$SyncHash.GuiElements.rbControlFromFile.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.rbCreateHashSum.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.rbCreateHashSumMore.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})

$SyncHash.GuiElements.btnIn.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.cbOut.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.btnOut.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})

$SyncHash.GuiElements.btnGo.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.btnRefresh.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.btnClear.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.btnExport.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.btnExit.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})

$SyncHash.GuiElements.btnAll.add_click({CheckBoxAlgoritm -status $true;})
$SyncHash.GuiElements.btnNothing.add_click({CheckBoxAlgoritm -status $false;})

$SyncHash.GuiElements.rbCzech.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.rbEnglish.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
$SyncHash.GuiElements.rbRussian.add_click({Message -title ("Upozorn$([char]0x011B)n$([char]0x00ED)") -body "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";})
## Runaspace




$SyncHash.Window.ShowDialog() | Out-Null;
