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
    Edited: 12.11.2021
#>

function CheckBoxAlgoritm {
    param (
        [Parameter(Mandatory = $true)] 
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
        [Parameter(Mandatory = $true)]
        [string]
        $title,
        [Parameter(Mandatory = $true)]
        [string]
        $body
    )

    [windows.MessageBox]::Show($body, $title, 'OK');

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
    $_SelectFileDialog.Multiselect = $false;
    if ((Test-Path -Path $initialPath -PathType Container) -eq $true) {
        $_SelectFileDialog.InitialDirectory = $initialPath;
    }
    else {
        $_SelectFileDialog.InitialDirectory = $PSScriptRoot;
    }
    ##$_SelectFileDialog.filter = "CSV (*.csv)| *.csv"
    if ($_SelectFileDialog.ShowDialog() -eq "OK") {
        $_path = $_SelectFileDialog.FileName;
        $_SelectFileDialog.Dispose();
        return $_path;
    }
    else {
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
    $_SelectFolderDialog.ShowNewFolderButton = $false;
    $selectedPath = $selectedPath.Trim();

    if ([string]::IsNullOrEmpty($selectedPath) -eq $false) {
        if ((Test-Path -Path $selectedPath -PathType Container) -eq $true) {
            $_SelectFolderDialog.SelectedPath = $selectedPath;
        }
        else {
            $_SelectFolderDialog.SelectedPath = [System.Environment+SpecialFolder]'MyComputer';
        }
    }
    else {
        $_SelectFolderDialog.SelectedPath = [System.Environment+SpecialFolder]'MyComputer';
    }
 
    if ($_SelectFolderDialog.ShowDialog() -eq "OK") {
        $selectedPath = $_SelectFolderDialog.SelectedPath;
        $_SelectFolderDialog.Dispose();
        return $selectedPath;
    }
    else {
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

function TestPathIn {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [bool]
        $itIsFile
    )

    if (([string]::IsNullOrEmpty($SyncHash.GuiElements.tbIn.Text.Trim())) -eq $false) {
        if ($itIsFile -eq $true) {
            if ((Test-Path -Path $SyncHash.GuiElements.tbIn.Text.Trim() -PathType Leaf) -eq $true) {
                return $true;
            }
        }
        else {
            if ((Test-Path -Path $SyncHash.GuiElements.tbIn.Text.Trim() -PathType Container) -eq $true) {
                return $true;
            }
        }
    }

    return $false;
    
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

function changeInputComponents {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $para = 1
    )

    $SyncHash.GuiElements.lbIn.IsEnabled = $true;
    $SyncHash.GuiElements.tbIn.IsEnabled = $true;
    $SyncHash.GuiElements.btnIn.IsEnabled = $true;

    $SyncHash.GuiElements.tbIn.Background = "LightGreen";
    $SyncHash.GuiElements.btnIn.Background = "LightGreen";

    switch ($para) {
        1 {
            $SyncHash.GuiElements.lbHash.IsEnabled = $false;
            $SyncHash.GuiElements.tbHash.IsEnabled = $false;
            $SyncHash.GuiElements.tbHash.Background = "DarkGray";

            $SyncHash.GuiElements.tbHash.Text = "";
            if ((TestPathIn -itIsFile $true) -eq $false) { $SyncHash.GuiElements.tbIn.Text = ""; }
            break;
        }
        2 {
            $SyncHash.GuiElements.lbHash.IsEnabled = $true;
            $SyncHash.GuiElements.tbHash.IsEnabled = $true;

            $SyncHash.GuiElements.tbHash.Background = "LightGreen";

            if ((TestPathIn -itIsFile $true) -eq $false) { $SyncHash.GuiElements.tbIn.Text = ""; }
            break;
        }
        3 {
            $SyncHash.GuiElements.lbHash.IsEnabled = $false;
            $SyncHash.GuiElements.tbHash.IsEnabled = $false;

            $SyncHash.GuiElements.tbHash.Background = "DarkGray";   
    
            if ((TestPathIn -itIsFile $true) -eq $true) {
                $SyncHash.GuiElements.tbIn.Text = (Get-Item -Path $SyncHash.GuiElements.tbIn.Text.Trim()).Directory;
            }
            break;
        }
    }
    
<#
.SYNOPSIS
Enable/Disable input box 

.DESCRIPTION
Enable/Disable input box, change contents

.EXAMPLE
changeInputComponents -para 1;

.NOTES
#>
}


function changeLanguage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $lang
    )

    switch ($lang) {
        "cze" { 
            $SyncHash.Lang["001"] = "Upozorn$([char]0x011B)n$([char]0x00ED)";
            $SyncHash.Lang["002"] = "Chyba zad$([char]0x00E1)n$([char]0x00ED) cesty k vstupn$([char]0x00ED)mu souboru !!!";
            $SyncHash.Lang["003"] = "Chyba zad$([char]0x00E1)n$([char]0x00ED) cesty ke vstupn$([char]0x00ED)m soubor$([char]0x016F)m !!!";
            $SyncHash.Lang["004"] = "Chyba z$([char]0x00E1)pisu do v$([char]0x00FD)stupn$([char]0x00ED) slo$([char]0x017E)ky !!!";
            $SyncHash.Lang["005"] = "Nen$([char]0x00ED) zad$([char]0x00E1)n kontroln$([char]0x00ED) HASH !!!";
            $SyncHash.Lang["006"] = "$([char]0x010C)ek$([char]0x00E1)m";
            $SyncHash.Lang["007"] = "Pracuji";
            $SyncHash.Lang["008"] = "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";
            $SyncHash.Lang["009"] = "St$([char]0x00E1)le pracuji !!!";
            $SyncHash.Lang["010"] = "OK"
            $SyncHash.Lang["011"] = "Chyba";
        }
        "eng" { 
            $SyncHash.Lang["001"] = "Warning";
            $SyncHash.Lang["002"] = "Input path error !!!";
            $SyncHash.Lang["003"] = "Input path error !!!";
            $SyncHash.Lang["004"] = "Write permission to output folder error !!!";
            $SyncHash.Lang["005"] = "Control hash missing !!!";
            $SyncHash.Lang["006"] = "Waiting";
            $SyncHash.Lang["007"] = "Working";
            $SyncHash.Lang["008"] = "The function is not programmed !!!";
            $SyncHash.Lang["009"] = "Still working !!!";
            $SyncHash.Lang["010"] = "OK"
            $SyncHash.Lang["011"] = "FAIL";
        }
        "rus" {
            $SyncHash.Lang["001"] =     "Upozorn$([char]0x011B)n$([char]0x00ED)";
            $SyncHash.Lang["002"] =     "Chyba zad$([char]0x00E1)n$([char]0x00ED) cesty k souboru !!!";
            $SyncHash.Lang["003"] =     "Chyba zad$([char]0x00E1)n$([char]0x00ED) cesty ke slo$([char]0x017E)ce se soubory !!!";
            $SyncHash.Lang["004"] =     "Chyba z$([char]0x00E1)pisu do v$([char]0x00FD)stupn$([char]0x00ED) slo$([char]0x017E)ky !!!";
            $SyncHash.Lang["005"] =     "Nen$([char]0x00ED) zad$([char]0x00E1)n kontroln$([char]0x00ED) HASH !!!";
            $SyncHash.Lang["006"] =     "$([char]0x010C)ek$([char]0x00E1)m";
            $SyncHash.Lang["007"] =     "Pracuji";
            $SyncHash.Lang["008"] =     "Funkce nen$([char]0x00ED) naprogramov$([char]0x00E1)na !!!";
            $SyncHash.Lang["009"] =     "St$([char]0x00E1)le pracuji !!!";
            $SyncHash.Lang["010"] =     "OK"
            $SyncHash.Lang["011"] =     "Chyba";
        }
        Default {}
    }


    

<#
.SYNOPSIS
Change language

.DESCRIPTION
Change language

.EXAMPLE
changeLanguageM -lang EN;

.NOTES
#>    
}


function changeLanguageGUI {

<#
.SYNOPSIS
Change Language for GUI

.DESCRIPTION
Change Language for GUI

.EXAMPLE
changeLanguageGUI;

.NOTES
#>
}

$PSDefaultParameterValues['*:Encoding'] = 'utf8'

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
$SyncHash.GuiElementsEnable = @{};

foreach ($N in $WpfFile.SelectNodes('//*[@x:Name]', $WpfNs)) {
    $SyncHash.GuiElements.Add($N.Name, $SyncHash.Window.FindName($N.Name));  
    $SyncHash.GuiElementsEnable.Add($N.Name, $true);
}

$SyncHash.PathIn = "";
$SyncHash.PathOut = "";
$SyncHash.WorkType = 0;
$SyncHash.OriginalHash = "";
$SyncHash.Algo = @{};
$SyncHash.Algo.Add("MACTripleDES", $false);
$SyncHash.Algo.Add("RIPEMD160", $false);
$SyncHash.Algo.Add("SHA512", $false);
$SyncHash.Algo.Add("SHA384", $false);
$SyncHash.Algo.Add("SHA256", $false);
$SyncHash.Algo.Add("SHA1", $false);
$SyncHash.Algo.Add("MD5", $false);
$SyncHash.Lang = @{};
$SyncHash.Lang.Add("001", "");
$SyncHash.Lang.Add("002", "");
$SyncHash.Lang.Add("003", "");
$SyncHash.Lang.Add("004", "");
$SyncHash.Lang.Add("005", "");
$SyncHash.Lang.Add("006", "");
$SyncHash.Lang.Add("007", "");
$SyncHash.Lang.Add("008", "");
$SyncHash.Lang.Add("009", "");
$SyncHash.Lang.Add("010", "");
$SyncHash.Lang.Add("011", "");

changeLanguage -lang "cze";

##Runspace
$Runspace = [Runspacefactory]::CreateRunspace();
$Runspace.ApartmentState = [Threading.ApartmentState]::STA; ##The Thread will create and enter a single-threaded apartment.
$Runspace.Open();
$Runspace.SessionStateProxy.SetVariable('SyncHash', $SyncHash);

## NO tread
$SyncHash.GuiElements.rbCreateHash.add_click({changeInputComponents -para 1;});
$SyncHash.GuiElements.rbHashControl.add_click({changeInputComponents -para 2;});
$SyncHash.GuiElements.rbControlFromFile.add_click({changeInputComponents -para 1;});
$SyncHash.GuiElements.rbCreateHashSum.add_click({changeInputComponents -para 1;});
$SyncHash.GuiElements.rbCreateHashSumMore.add_click({changeInputComponents -para 3;});

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
    if ([string]::IsNullOrEmpty($_tempPath) -eq $false ) {
            $SyncHash.GuiElements.tbIn.Text = $_tempPath.Trim();
    }
});

$SyncHash.GuiElements.btnGo.add_click({
    Write-Output "DRY RUN";
    [bool]$canGo = $true;

    $SyncHash.PathIn = $SyncHash.GuiElements.tbIn.Text.Trim();

    ##Test tbIn
    if (($SyncHash.GuiElements.rbCreateHash.IsChecked -eq $true) `
        -or ($SyncHash.GuiElements.rbHashControl.IsChecked -eq $true) `
        -or ($SyncHash.GuiElements.rbControlFromFile.IsChecked -eq $true) `
        -or ($SyncHash.GuiElements.rbCreateHashSum.IsChecked -eq $true)) {
        if ((TestPathIn -itIsFile $true) -eq $false) {
            Message -title ($SyncHash.Lang["001"]) -body ($SyncHash.Lang["002"]);
            $canGo = $false;
        }
    } elseif ($SyncHash.GuiElements.rbCreateHashSumMore.IsChecked -eq $true) {
        if ((TestPathIn -itIsFile $false) -eq $false) {
            Message -title ($SyncHash.Lang["001"]) -body ($SyncHash.Lang["003"]);
            $canGo = $false;
        } 
    } else { $canGo = $false;}

    ## Store PathOut
    if ($canGo -eq $true) {
        if ((Get-Item -path $SyncHash.PathIn) -is [System.IO.DirectoryInfo]) {
            $SyncHash.PathOut = $SyncHash.PathIn;
        } else {
            $SyncHash.PathOut = (Get-Item -Path $SyncHash.PathIn).Directory.ToString();
        }
        if (($SyncHash.PathOut -notmatch '\\$') -and ($canGo -eq $true)) {$SyncHash.PathOut += '\';}
    }

    ##Todo test permision to write
    if ($canGo -eq $true) {
        Try { 
            [io.file]::OpenWrite($SyncHash.PathOut + "txt.txt").close();
            Remove-Item ($SyncHash.PathOut + "txt.txt");
        }
        Catch {
            Message -title ($SyncHash.Lang["001"]) -body ($SyncHash.Lang["004"]);
            ## Todo  Output path
        }

        $SyncHash.OriginalHash = $SyncHash.GuiElements.tbHash.Text.Trim();

        if ($SyncHash.GuiElements.rbCreateHash.IsChecked -eq $true) {$SyncHash.WorkType = 1;}
            elseif ($SyncHash.GuiElements.rbHashControl.IsChecked -eq $true) {$SyncHash.WorkType = 2;}
            elseif ($SyncHash.GuiElements.rbControlFromFile.IsChecked -eq $true) {$SyncHash.WorkType = 3;}
            elseif ($SyncHash.GuiElements.rbCreateHashSum.IsChecked -eq $true) {$SyncHash.WorkType = 4;}
            elseif ($SyncHash.GuiElements.rbCreateHashSumMore.IsChecked -eq $true) {$SyncHash.WorkType = 5;}
            else {$SyncHash.WorkType = 0;}
        $SyncHash.Algo["MD5"] = $SyncHash.GuiElements.cbMd5.IsChecked;
        $SyncHash.Algo["SHA1"] = $SyncHash.GuiElements.cbSha1.IsChecked;
        $SyncHash.Algo["SHA256"] = $SyncHash.GuiElements.cbSha256.IsChecked;
        $SyncHash.Algo["SHA384"] = $SyncHash.GuiElements.cbSha384.IsChecked;
        $SyncHash.Algo["SHA512"] = $SyncHash.GuiElements.cbSha512.IsChecked;
        $SyncHash.Algo["RIPEMD160"] = $SyncHash.GuiElements.cbRipemd160.IsChecked;
        $SyncHash.Algo["MACTripleDES"] = $SyncHash.GuiElements.cbMactripledes.IsChecked;

        if (($SyncHash.GuiElements.cbMd5.IsChecked -eq $false) -and `
            ($SyncHash.GuiElements.cbSha1.IsChecked -eq $false) -and `
            ($SyncHash.GuiElements.cbSha256.IsChecked -eq $false) -and `
            ($SyncHash.GuiElements.cbSha384.IsChecked -eq $false) -and `
            ($SyncHash.GuiElements.cbSha512.IsChecked -eq $false) -and `
            ($SyncHash.GuiElements.cbRipemd160.IsChecked -eq $false) -and `
            ($SyncHash.GuiElements.cbMactripledes.IsChecked -eq $false)) {
                $SyncHash.Algo["MD5"] = $true;
        }
        ##Test tbHash
        if ($SyncHash.GuiElements.rbHashControl.IsChecked -eq $true) {
            if (([string]::IsNullOrEmpty($SyncHash.GuiElements.tbHash.Text.Trim())) -eq $true) {
                Message -title ($SyncHash.Lang["001"]) -body ($SyncHash.Lang["005"]);
                $canGo = $false;            
            }
        } 
    }

    if ($canGo -eq $true) { 
            
        $Global:Session = [PowerShell]::create().addScript({
            $SyncHash.Error = $Error;
                
            $SyncHash.Window.Dispatcher.Invoke([Action]{
                $SyncHash.GuiElements.lbInfo.Content=($SyncHash.Lang["007"]) + " ... ";
                
                ##Disable componets
                foreach ($Key in $SyncHash.GuiElements.Keys) {
                    $SyncHash.GuiElementsEnable[$Key] = $SyncHash.GuiElements[$Key].IsEnabled;
                    if ($Key -ne "dgData") {
                        $SyncHash.GuiElements[$Key].IsEnabled = $false;
                    }
                }
            });

            ##TODO Case >> what we do
            ##TODO HASH and simillar
            ##TODO Change counter
            switch ($SyncHash.WorkType) {
                1 { ## Hash
                    $_max=0;
                    $_pos=0;
                    foreach ($_a in $SyncHash.Algo.Keys) { if ($SyncHash.Algo[$_a] -eq $true) {$_max += 1;}}
                    $SyncHash.Window.Dispatcher.Invoke([Action]{
                        $SyncHash.GuiElements.dgData.AddChild([pscustomobject]@{Name="File"; Data=$SyncHash.PathIn.Trim(); Result=$null});
                        $SyncHash.GuiElements.lbInfo.Content=(($SyncHash.Lang["007"]) + " ... ("+$_pos+"/"+$_max+")");
                    });
                    foreach ($_a in ($SyncHash.Algo.Keys | Sort-Object Keys)) {
                        if ($SyncHash.Algo[$_a] -eq $true) {
                            $_pos += 1;
                            $SyncHash.Window.Dispatcher.Invoke([Action]{
                                $SyncHash.GuiElements.lbInfo.Content=($SyncHash.Lang["007"]) + " ... ("+$_pos+"/"+$_max+")";
                            });

                            $_h=((Get-FileHash -Path $SyncHash.PathIn.Trim() -Algorithm $_a).Hash).ToLower();
                                
                            $SyncHash.Window.Dispatcher.Invoke([Action]{$SyncHash.GuiElements.dgData.AddChild([pscustomobject]@{Name=$_a; Data=$_h; Result=$null});});     
                        }
                    }
                    break;
                }
                2 { 
                    $_max=0;
                    $_pos=0;
                    foreach ($_a in $SyncHash.Algo.Keys) { if ($SyncHash.Algo[$_a] -eq $true) {$_max += 1;}}

                    $SyncHash.Window.Dispatcher.Invoke([Action]{
                        $SyncHash.GuiElements.dgData.AddChild([pscustomobject]@{Name="File"; Result=$null; Data=$SyncHash.PathIn.Trim()});
                        $SyncHash.GuiElements.lbInfo.Content=($SyncHash.Lang["007"]) + " ... ("+$_pos+"/"+$_max+")";
                    });

                    foreach ($_a in $SyncHash.Algo.Keys | Sort-Object Keys) {
                        if ($SyncHash.Algo[$_a] -eq $true) {
                            $_pos += 1;
                            $SyncHash.Window.Dispatcher.Invoke([Action]{$SyncHash.GuiElements.lbInfo.Content=($SyncHash.Lang["007"]) + "  ... ("+$_pos+"/"+$_max+")";});

                            $_h=((Get-FileHash -Path $SyncHash.PathIn.Trim() -Algorithm $_a).Hash).ToLower();

                            if ($_h -ceq $SyncHash.OriginalHash.ToLower()) {
                                $SyncHash.Window.Dispatcher.Invoke([Action]{$SyncHash.GuiElements.dgData.AddChild([pscustomobject]@{Name=$_a; Result=($SyncHash.Lang["010"]); Data=$_h});});     
                            } else {
                                $SyncHash.Window.Dispatcher.Invoke([Action]{$SyncHash.GuiElements.dgData.AddChild([pscustomobject]@{Name=$_a; Result=($SyncHash.Lang["011"]); Data=$_h});});
                            }
                        }
                    }
                    break;
                }
                3 { 
                    ##TODO
                    break;
                }
                4 {
                    $_max=0;
                    $_pos=0;
                    $_file = Get-Item -Path $SyncHash.PathIn.Trim();

                    foreach ($_a in $SyncHash.Algo.Keys) { if ($SyncHash.Algo[$_a] -eq $true) {$_max += 1;}}

                    $SyncHash.Window.Dispatcher.Invoke([Action]{
                        $SyncHash.GuiElements.dgData.AddChild([pscustomobject]@{Name="File"; Data=$_file.FullName; Result=$null});
                        $SyncHash.GuiElements.lbInfo.Content=($SyncHash.Lang["007"]) + " ... ("+$_pos+"/"+$_max+")";
                    });

                    foreach ($_a in ($SyncHash.Algo.Keys | Sort-Object Keys)) {
                        if ($SyncHash.Algo[$_a] -eq $true) {
                            $_pos += 1;

                            $SyncHash.Window.Dispatcher.Invoke([Action]{$SyncHash.GuiElements.lbInfo.Content=($SyncHash.Lang["007"]) + " ... ("+$_pos+"/"+$_max+")";});

                            $_h=((Get-FileHash -Path $_file.FullName -Algorithm $_a).Hash).ToLower();
                                
                            $SyncHash.Window.Dispatcher.Invoke([Action]{$SyncHash.GuiElements.dgData.AddChild([pscustomobject]@{Name=$_a; Data=$_h; Result=$null});});
                            
                            if ((Test-Path -Path ($SyncHash.PathOut + $_file.Name + "." + $_a) -PathType Leaf) -eq $false) {
                                New-Item -Path ($SyncHash.PathOut + $_file.Name + "." + $_a) -ItemType File -Name $_fileName 
                            }
                            Add-Content -Path ($SyncHash.PathOut + $_file.Name + "." + $_a) -Encoding UTF8 -Value ($_h + " *" + $_file.Name)
                        }
                    }
                    break;
                }
                5 {
                    $_max=0;
                    $_pos=0;
                    $_fileName="";
                    $_files = (Get-ChildItem -Path $SyncHash.PathIn) | Sort-Object -Property Length;

                    foreach ($_a in $SyncHash.Algo.Keys) { if ($SyncHash.Algo[$_a] -eq $true) {$_max += 1;}}
                    $_max = $_max * $_files.Length;

                    $SyncHash.Window.Dispatcher.Invoke([Action]{$SyncHash.GuiElements.lbInfo.Content=($SyncHash.Lang["007"]) + " ... ("+$_pos+"/"+$_max+")";});

                    foreach ($_f in $_files) {
                        $SyncHash.Window.Dispatcher.Invoke([Action]{$SyncHash.GuiElements.dgData.AddChild([pscustomobject]@{Name="File"; Result=$null; Data=$_f.FullName});});
                            
                        foreach ($_a in $SyncHash.Algo.Keys | Sort-Object Keys) {
                            if ($SyncHash.Algo[$_a] -eq $true) {
                                $_pos += 1;
                                $_fileName = ($_a + "SUM").ToUpper();

                                $SyncHash.Window.Dispatcher.Invoke([Action]{$SyncHash.GuiElements.lbInfo.Content=($SyncHash.Lang["007"]) + " ... ("+$_pos+"/"+$_max+")";});
                                
                                $_h=((Get-FileHash -Path $_f.FullName -Algorithm $_a).Hash).ToLower();

                                $SyncHash.Window.Dispatcher.Invoke([Action]{$SyncHash.GuiElements.dgData.AddChild([pscustomobject]@{Name=$_a; Data=$_h; Result=$null});});     

                                if ((Test-Path -Path ($SyncHash.PathOut + $_fileName) -PathType Leaf) -eq $false) {
                                    New-Item -Path $SyncHash.PathOut -ItemType File -Name $_fileName;
                                }
                                Add-Content -Path ($SyncHash.PathOut + $_fileName) -Encoding UTF8 -Value ($_h + " *" + $_f.Name);
                            }
                        }
                    }
                    break;
                }
            }

            ## Enable components
            $SyncHash.Window.Dispatcher.Invoke([Action]{
                foreach ($Key in $SyncHash.GuiElements.Keys) {
                    $SyncHash.GuiElements[$Key].IsEnabled = $SyncHash.GuiElementsEnable[$Key];
                    $SyncHash.GuiElementsEnable[$Key] = $true;
                }
                $SyncHash.GuiElements.lbInfo.Content=($SyncHash.Lang["006"]) + " ... ";
            });

        }, $true);
        
        $Global:Session.Runspace = $Runspace;
        $Global:Handle = $Global:Session.BeginInvoke();
    } else { Write-Host "CAN'T GO"; }
    
})
$SyncHash.GuiElements.btnClear.add_click( { Message -title ($SyncHash.Lang["001"]) -body ($SyncHash.Lang["008"]); })
$SyncHash.GuiElements.btnExport.add_click( { Message -title ($SyncHash.Lang["001"]) -body ($SyncHash.Lang["008"]); })
$SyncHash.GuiElements.btnExit.add_click( { Message -title ($SyncHash.Lang["001"]) -body ($SyncHash.Lang["008"]); })

$SyncHash.GuiElements.btnAll.add_click( { CheckBoxAlgoritm -status $true; })
$SyncHash.GuiElements.btnNothing.add_click( { CheckBoxAlgoritm -status $false; })

$SyncHash.GuiElements.rbCzech.add_click({changeLanguage -lang "cze";})
$SyncHash.GuiElements.rbEnglish.add_click({changeLanguage -lang "eng";})
$SyncHash.GuiElements.rbRussian.add_click({changeLanguage -lang "rus";})

$SyncHash.Window.add_closing( { ## TODO cancel
    if ($Global:Session -ne $null -and $Global:Handle.IsCompleted -eq $false) {
        Message -title ($SyncHash.Lang["001"]) -body ($SyncHash.Lang["009"]);
        $_.Cancel = $true;
        Write-Host $_;
    }
})

$SyncHash.Window.add_closed({
    if ($Global:Session -ne $null) {$Runspace.Close();}
})

$SyncHash.Window.ShowDialog() | Out-Null;

# SIG # Begin signature block
# MIIGiwYJKoZIhvcNAQcCoIIGfDCCBngCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoFtHZ4fS5XyTM4fhQP/LCTbh
# qSGgggPPMIIDyzCCArOgAwIBAgIQViGHnYe7vJpGUgpAqX3B/zANBgkqhkiG9w0B
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFFQ9dmpedn5P
# i/XROZAjY2zo3HGIMA0GCSqGSIb3DQEBAQUABIIBAJDfDQWNhS6Qnov4P+oXtPh7
# WLr8UJW9IlwdRq4GtVqKFmjMqTztmrl2rWc4OBrHR/Y14LIJzhgt/RR7q57J1NkJ
# lkGQus1gl6zU9SzRqPJKCxv0IHAotuP06HzNjXKpm1nE9NeXUxs3riVXW0GAa89Z
# 1+0B9FSWUwq/hOwYHu1lEAX7/RhXuy4oUKA8KXKbFxCxhm6XVQnz8o5r8DIxtkh6
# qZFHH4x+Fa5SNTaomFujb3DWYfHiIYZ3aNjpPv1qIk9DdQn9KAHZwcYKF9vPv5gp
# yadr6kl8QAB3EzPqYcHzC0CE0GL3h2IraLEXAXYny50bwXhri98zfuHFB+n7yJ0=
# SIG # End signature block
