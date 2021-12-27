# This script requires winget
# Install/update App Installer to get Winget, see https://www.microsoft.com/en-us/p/app-installer/9nblggh4nns1#activetab=pivot:overviewtab 
# To start a administrator session: Start-Process powershell.exe -Verb runAs

class Package {
    [string]$Id
    [Parameter(Mandatory=$False)][bool]$Interactive = $false
    [Parameter(Mandatory=$False)][bool]$RequiresAdmin = $false
}

Class Group {
    [string]$Name
    [array]$Packages
}

$coding = @(
  [Package]@{Id = "Microsoft.VisualStudioCode"; Interactive = $true}
  [Package]@{Id = "Git.Git"}
  [Package]@{Id = "GitHub.GitHubDesktop"}
  [Package]@{Id = "Microsoft.GitCredentialManagerCore"}
  [Package]@{Id = "Docker.DockerDesktop"; RequiresAdmin = $true}
  [Package]@{Id = "OpenJS.NodeJS.LTS"}
  [Package]@{Id = "Microsoft.dotnet"}
  [Package]@{Id = "Python.Python.3"}

)

$powertools = @(
  [Package]@{Id = "Microsoft.PowerToys"}
  [Package]@{Id = "Microsoft.WindowsTerminal"}
)

$social = @(
  [Package]@{Id = "Discord.Discord"}
  [Package]@{Id = "SlackTechnologies.Slack"}
  [Package]@{Id = "Zoom.Zoom"}
  [Package]@{Id = "Microsoft.Teams"}
)

$data_analysis = @(
  [Package]@{Id = "Microsoft.PowerBI"}
  [Package]@{Id = "Microsoft.AzureDataStudio"}
)

$devops = @(
  [Package]@{Id = "Microsoft.AzureStorageExplorer"}
  [Package]@{Id = "Microsoft.AzureCLI"}
)

$office = @(
  [Package]@{Id = "Microsoft.Office"}
  [Package]@{Id = "Google.Chrome"}
  [Package]@{Id = "Mozilla.Firefox"}
)

$life = @(
  [Package]@{Id = "Spotify.Spotify"}
)


$groups = @(
  [Group]@{Name = "Coding"; "Packages" = $coding}
  [Group]@{Name = "Social"; "Packages" = $social}
  [Group]@{Name = "Data Analysis"; "Packages" = $data_analysis}
  [Group]@{Name = "Power Tools"; "Packages" = $powertools}
  [Group]@{Name = "DevOps"; "Packages" = $devops}
  [Group]@{Name = "Office"; "Packages" = $office}
  [Group]@{Name = "Life"; "Packages" = $life}
)

function Get-Installed {
  param ([string]$package)

  # Check if package is installed
  winget list --exact --id $package

  $result = $false
  if ($LASTEXITCODE -eq 0) {
    $result = $true
  } 

  $result
}

function Get-UserDecision {
  param (
    [string]$Prompt,
    [Parameter(Mandatory=$False)][bool]$DefaultNo = $false
  )

  $result = $false
  
  if ($DefaultNo) {
    $reply = Read-Host -Prompt $("$Prompt [y/N]")
    if ( $reply -match "[yY]" ) { $result = $true }
  } else {
    $reply = Read-Host -Prompt $("$Prompt [Y/n]")
    if ( (!$reply) -or ($reply -match "[yY]") ) { $result = $true }
  }

  $result
}

function Install-Package {
  param (
    [Package]$Package
  )

  if ( (Get-Installed -Package $Package.Id) -eq $true ) {
    Write-Host "$($Package.Id) is installed"
  } else {
    if ( Get-UserDecision -Prompt $("Install $($Package.Id)?" ) ) { 
        
        Write-Host $("Installs $($Package.Id) ...") -ForegroundColor Green

        $Arguments = "install --exact --id $($Package.Id) --accept-package-agreements --accept-source-agreements"
        if ($Package.Interactive) {
          $Arguments = $Arguments + " --interactive"
        }

        # Check if admin elevation is needed.
        if ($Package.RequiresAdmin) {
          Start-Process -FilePath "winget.exe" -ArgumentList $Arguments  -verb RunAs
        } else {
          Invoke-Expression "winget $Arguments"
        }

        # Inform user about result of installation.
        if ($LASTEXITCODE -eq 0) { 
          Write-Host $("$($Package.Id) installed successfully.") -ForegroundColor Green  
        } else { 
          Write-Host $("$($Package.Id) failed to install.") -ForegroundColor Red 
        }
      }
  }
}

function Install-Group {
  param (
    [Group]$Group
  )

  if(Get-UserDecision -Prompt $("Install any $($Group.Name) software?") -DefaultNo $true) {
    foreach ($package in $Group.Packages) {
      Install-Package -Package $package -Interactive $Interactive
    }
  }
}

$groups | ForEach-Object {Install-Group $_}
