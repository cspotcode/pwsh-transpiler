function foo() {
    begin {
        echo 'this is begin'
    }
    process {
        echo 'this is process'
    }
    end {
        echo 'this is end'
    }
}

import-module $PSScriptRoot/core.psm1
import-module $PSScriptRoot/blocksWrappedInTryCatch.psm1

$result = transform $function:foo ( get-command blocksWrappedInTryCatch )

write-output $result.extent.text
