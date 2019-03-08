<#
 # This is an example of writing a module with the code transformer.
 # Then it calls our transpiler to *redeclare* the functions,
 # with transformations applied.
 # THIS IS ONLY FOR DEVELOPMENT.
 # For production, we should instead pre-compile
 # the code to avoid a runtime performance hit.
 #
 # To prove this works:
 #
 #     import-module ./example.psm1
 #     echo 1 2 3 | sampleStreamProcessor
 #>

# We want this function to be transformed
function sampleStreamProcessor {
    # Default block is process block
    Write-Host "Got pipeline item: $_"
}

# Perform transformation
. ./transformMe.ps1 $MyInvocation
