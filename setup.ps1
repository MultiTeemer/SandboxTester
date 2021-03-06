param([string]$pathToExecutables='E:\\', [string]$pathToWorkEnv='C:\\Testing\\')

function AddToPath([string]$pathPatch) {
    $path = [environment]::GetEnvironmentVariable("Path",[System.EnvironmentVariableTarget]::Machine)

	if ($path.split(";") -notcontains $pathPatch)
	{
	    $path += ";$pathPatch"

		[Environment]::SetEnvironmentVariable("Path", $path, [System.EnvironmentVariableTarget]::Machine)
	}
}

function GetSystemArchitecture() {
    [string[]]$ComputerName = $env:computername       

    if ((Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName -ea 0).OSArchitecture -eq '64-bit') {            
        $architecture = "64"            
    } else  {            
        $architecture = "32"            
    }          
       
    return $architecture
}

$programs = @('ruby.exe', 'python.msi', 'pascal.exe', 'mingw.exe', 'git.exe', 'cmake.exe', 'java.exe', 'dotnet.exe', 'pascalabc.exe')

foreach ($program in $programs) {
    Start-Process -FilePath ($pathToExecutables + $program)
}

AddToPath('C:\MinGW\mingw' + (GetSystemArchitecture) + '\bin')
AddToPath('C:\Windows\Microsoft.NET\Framework\v4.0.30319')
AddToPath('C:\Java\bin')
AddToPath('C:\Program Files\PascalABC.NET\')

if (Test-Path $pathToWorkEnv) {
    Remove-Item -Path $pathToWorkEnv -Recurse -Force
}

New-Item -Path $pathToWorkEnv -ItemType 'dir'

cd $pathToWorkEnv

git clone http://github.com/MultiTeemer/Spawner
git clone http://github.com/MultiTeemer/SandboxTester

cd ($pathToWorkEnv + 'Spawner')

git submodule init
git submodule update

mkdir 'build_gcc'

git checkout GccCompiling

cd 'build_gcc'

cmake .. -G 'MinGW Makefiles'

cmake --build .

cd ($pathToWorkEnv + 'SandboxTester')

ruby -e ('IO.write(\"settings.ini\", \"[cats]\npath=' + $pathToWorkEnv + 'Spawner\\build_gcc\\sp.exe\\n[pcms2]\npath=' + $pathToExecutables + 'Run\")')

gem install test-unit
gem install inifile