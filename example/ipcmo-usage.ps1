Import-Module $PSScriptRoot/../experiments/loader.psm1

# Compile and load our module
New-CompiledModule $PSScriptRoot/compiled-module.psm1 | Import-Module

# Use it
echo 1 2 3 | foo
echo ''

# Log source code to show that it was, in fact, compiled
(get-command foo).scriptblock.ast.extent.text
