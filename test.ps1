$ErrorActionPreference = 'Stop'

function foo() {
    echo 'this is end'
}

import-module -Force $PSScriptRoot/core.psm1
import-module -Force $PSScriptRoot/transformers/createEmptyBlocks.psm1
import-module -Force $PSScriptRoot/transformers/blocksWrappedInTryCatch.psm1
import-module -Force $PSScriptRoot/transformers/defaultBlockIsProcess.psm1

$result = $function:foo
$result = transform $result ( get-command defaultBlockIsProcess )
$result = transform $result ( get-command createEmptyBlocks )
$result = transform $result ( get-command blocksWrappedInTryCatch )

write-output $result.extent.text
