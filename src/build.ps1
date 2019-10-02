$BuildFolder = $PSScriptRoot

$powerShellGet = Import-Module PowerShellGet  -PassThru -ErrorAction Ignore
if ($powerShellGet.Version -lt ([Version]'1.6.0')) {
	Install-Module PowerShellGet -Scope CurrentUser -Force -AllowClobber
	Import-Module PowerShellGet -Force
}

Set-Location $BuildFolder

$OutputPath = "$BuildFolder\output\UniversalDashboard.ObjectTree"

Remove-Item -Path $OutputPath -Force -ErrorAction SilentlyContinue -Recurse
Remove-Item -Path "$BuildFolder\public" -Force -ErrorAction SilentlyContinue -Recurse

New-Item -Path $OutputPath -ItemType Directory

npm install
npm run build

Copy-Item $BuildFolder\public\*.bundle.js $OutputPath
Copy-Item $BuildFolder\public\*.map $OutputPath
Copy-Item $BuildFolder\UniversalDashboard.ObjectTree.psm1 $OutputPath

$Version = "1.0.0"

$manifestParameters = @{
	Path = "$OutputPath\UniversalDashboard.ObjectTree.psd1"
	Author = "Adam Driscoll"
	CompanyName = "Ironman Software, LLC"
	Copyright = "2019 Ironman Software, LLC"
	RootModule = "UniversalDashboard.ObjectTree.psm1"
	Description = "Object Tree for Universal Dashboard."
	ModuleVersion = $version
	Tags = @("universaldashboard", "objecttree", "ud-control")
	ReleaseNotes = "Initial release"
	FunctionsToExport = @(
		"New-UDObjectTree"
	)
	IconUri = "https://github.com/ironmansoftware/ud-helmet/raw/master/images/screenshot.png"
	ProjectUri = "https://github.com/ironmansoftware/ud-objecttree"
  RequiredModules = @()
}

New-ModuleManifest @manifestParameters 

if ($prerelease -ne $null) {
	Update-ModuleManifest -Path "$OutputPath\UniversalDashboard.ObjectTree.psd1" -Prerelease $prerelease
}

