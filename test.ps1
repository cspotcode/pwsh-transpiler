$ErrorActionPreference = 'Stop'

function foo() {
    echo 'this is end'
    write-output 'more output'
    % {}
}
pushd $PSScriptRoot
try {
    import-module -Force $PSScriptRoot/core.psm1
    import-module -Force $PSScriptRoot/transformers/createEmptyBlocks.psm1
    import-module -Force $PSScriptRoot/transformers/blocksWrappedInTryCatch.psm1
    import-module -Force $PSScriptRoot/transformers/defaultBlockIsProcess.psm1
    import-module -Force $PSScriptRoot/transformers/expandAliases.psm1
} finally {
    popd
}

$result = $function:foo
$result = transform $result ( get-command defaultBlockIsProcess )
$result = transform $result ( get-command createEmptyBlocks )
$result = transform $result ( get-command blocksWrappedInTryCatch )
write-host $result.gettype()
$result = transform $result ( get-command expandAliases )

write-output $result.extent.text
