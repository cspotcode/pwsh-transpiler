$ErrorActionPreference = 'Stop'

function foo() {
    echo 'this is end'
}

import-module -Force $PSScriptRoot/core.psm1
import-module -Force $PSScriptRoot/createEmptyBlocks.psm1
import-module -Force $PSScriptRoot/blocksWrappedInTryCatch.psm1
import-module -Force $PSScriptRoot/defaultBlockIsProcess.psm1

try {
$result = $function:foo
$result = transform $result ( get-command defaultBlockIsProcess )
$result = transform $result ( get-command createEmptyBlocks )
$result = transform $result ( get-command blocksWrappedInTryCatch )
}catch {
    write-host $_.scriptstacktrace
}

write-output $result.extent.text
