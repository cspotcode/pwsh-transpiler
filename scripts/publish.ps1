param($apikey)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function main {
    $target = "$PSScriptRoot/../published/pwsh-transpiler"
    if(test-path $target) { remove-item -r $target }
    new-item -type directory $target

    $srcPath = Split-Path -parent $PSScriptRoot
    $destPath = (gi $target).fullname
    $srcPath
    $destPath

    . {
        gi ./experiments/loader.psm1
        gci -r ./transformers
        gi README.md
        gi core.psm1
        gi *.psd1
    } | % {
        $src = $_.fullname
        $dest = $src.replace($srcPath, $destPath)
        mkdirp (split-path -parent $dest)
        cp $src $dest
    }

    # publish-module -path $target -nugetapikey $apikey
}

function mkdirp($path) {
    if(!(test-path $path)) {
        new-item -type directory $path >$Null
    }
}

main