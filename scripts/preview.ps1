[CmdletBinding()]
param(
  [ValidateRange(1024, 65535)]
  [int]$Port = 4100,
  [ValidateSet('Auto', 'Native', 'Podman')]
  [string]$Runtime = 'Auto',
  [switch]$BuildOnly
)

$ErrorActionPreference = 'Stop'
$repositoryPath = Split-Path -Parent $PSScriptRoot

if ($Runtime -eq 'Auto') {
  $Runtime = if (Get-Command bundle -ErrorAction SilentlyContinue) { 'Native' } else { 'Podman' }
}

if ($BuildOnly) {
  Write-Host 'Building the site into _site ...'
  $jekyllArguments = @('build')
} else {
  Write-Host "Preview: http://localhost:$Port"
  Write-Host 'Keep this terminal running. Edits rebuild automatically; refresh the browser to see them.'
  Write-Host 'Press Ctrl+C to stop. Remote content is refreshed on each rebuild.'
  $jekyllArguments = @('serve', '--host', '127.0.0.1', '--port', "$Port", '--force_polling')
}

if ($Runtime -eq 'Native') {
  Push-Location $repositoryPath
  try {
    & bundle check
    if ($LASTEXITCODE -ne 0) {
      & bundle install
      if ($LASTEXITCODE -ne 0) { throw 'bundle install failed.' }
    }
    & bundle exec jekyll @jekyllArguments
    if ($LASTEXITCODE -ne 0) { throw 'Jekyll exited with an error.' }
  } finally {
    Pop-Location
  }
  return
}

# Windows Podman's SSH forwarding can be unavailable even when its WSL VM works.
# Run the VM's Podman directly. No Ruby or compiler installation is needed on Windows.
$useWsl = $env:OS -eq 'Windows_NT' -and (Get-Command wsl -ErrorAction SilentlyContinue)
if ($useWsl) {
  $distribution = 'podman-machine-default'
  $containerPath = (& wsl -d $distribution --exec wslpath -a -u $repositoryPath.Replace('\', '/') | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) { throw 'Cannot access the Podman WSL VM. Install/start Podman, or use -Runtime Native with Ruby 3.3 and Bundler.' }
} else {
  if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw 'Install Podman, or install Ruby 3.3 and Bundler and use -Runtime Native.'
  }
  $containerPath = $repositoryPath
}

# The named volume caches gems between runs. The container is removed on exit.
# Host networking keeps Jekyll bound to loopback, with working local preview URLs.
$containerArguments = @(
  'run', '--rm', '--init', '--network', 'host',
  '-e', $(if ($BuildOnly) { 'JEKYLL_ENV=production' } else { 'JEKYLL_ENV=development' }),
  '-e', 'GIT_CONFIG_COUNT=1',
  '-e', 'GIT_CONFIG_KEY_0=safe.directory',
  '-e', 'GIT_CONFIG_VALUE_0=/srv/jekyll',
  '-v', "${containerPath}:/srv/jekyll",
  '-v', 'beejblog-preview-gems-ruby33:/usr/local/bundle',
  '-w', '/srv/jekyll'
)
if ($env:GITHUB_TOKEN) { $containerArguments += @('-e', 'GITHUB_TOKEN') }
$command = 'set -e; bundle check || bundle install; exec bundle exec jekyll ' + ($jekyllArguments -join ' ')
$containerArguments += @('docker.io/library/ruby:3.3', 'bash', '-lc', $command)

if ($useWsl) {
  $previousWslEnv = $env:WSLENV
  try {
    if ($env:GITHUB_TOKEN) { $env:WSLENV = (@($previousWslEnv, 'GITHUB_TOKEN') | Where-Object { $_ }) -join ':' }
    & wsl -d $distribution -u root --exec podman @containerArguments
    $previewExitCode = $LASTEXITCODE
  } finally {
    $env:WSLENV = $previousWslEnv
  }
} else {
  & podman @containerArguments
  $previewExitCode = $LASTEXITCODE
}
if ($previewExitCode -ne 0) { throw 'Preview container exited with an error. Check the output above.' }
