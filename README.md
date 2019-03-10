# Experimental source-to-source code transformer for PowerShell functions.

Writing PowerShell CmdLet functions the "right way" involves far too much boilerplate and manual effort.
What if we could pre-compile our functions into a form that does all the right things without extra boilerplate?

Inspired by discussion on https://github.com/PowerShell/PowerShell/issues/8819 and https://github.com/PoshCode/PowerShellPracticeAndStyle/issues/37

## Quick-start

Want to use the transformer to write a module?  Look at "example.psm1"

Want to write your own transformer?  Look at "./transformers/*.psm1"

## Things you can do with a transformer:

* replace aliases with fully-qualified function names
* wrap all blocks in try-catch to throw errors predictably
* automatically add well-known parameters and annotations
* Make dynamicparameters easier to use
* throw on incorrect outputtype at runtime

## How transformers work

PowerShell already gives us access to an AST, so it's straightforward to extract and recombine spans of
code.

The AST is immutable, so the easiest approach for applying multiple transformations is:
1. Pass a parsed AST to the first transformer.
1. Transformer returns a string of source code.
1. Parse the string into a fresh AST.
1. Pass this AST to the second transformer.
1. And so on...

Performance during development might not be great, with all this parsing and re-parsing.
But we can precompile our functions for production.

For sample usage, see "example.ps1"

## Tasks

* Write `Import-Module` equivalent
    * transpile entire file into a single scriptblock
    * use `New-Module -ScriptBlock` to create a new module
    * pipe it to `Import-Module`
    * Hook `Import-Module` to transpile transitive modules?
* Save debug example
    * VSCode config with sample of setting breakpoints

## Transformers

*These docs are extracted from `Get-Help` via `./scripts/renderReadme.ps1`*

*Not all are implemented yet; some are stubs*

<!--{ "`n" ; ./scripts/getTransformerDocs.ps1 }-->

### [blocksWrappedInTryCatch](./transformers/blocksWrappedInTryCatch.psm1)

Wrap all function blocks in a `try {} catch {}` that throws errors predictably.

### [createEmptyBlocks](./transformers/createEmptyBlocks.psm1)

Other transformers can be simpler if the input function has all blocks declared with at least one statement.
This is not ideal, but it helps us prototype transformers quickly.

### [defaultBlockIsProcess](./transformers/defaultBlockIsProcess.psm1)

If function does not have any explicitly-declared blocks, rewrite so it's the `process` block.

### [disposingBlock](./transformers/disposingBlock.psm1)

Support a new `disposing {}` block that is called when an error happens.

Ideally this would be its own block.  To simulate that, however, we put it at the top of the `begin {}` block.

    function {
        begin {
            disposing {
                # cleanup code here
            }
        }
    }

This is valid PS syntax and is easy for our code transformer to detect and process.

### [expandAliases](./transformers/expandAliases.psm1)

Expand any alias invocations with the module-qualified command name.

### [parametersToParamBlock](./transformers/parametersToParamBlock.psm1)

Move params into a param() block and add [cmdletbinding()]

Convert `function foo($a) {}` into `function {[cmdletbinding()]param($a)}`

### [requireWriteOutput](./transformers/requireWriteOutput.psm1)

Prevent accidental output by requiring use of Write-Output

We do this by transforming all Write-Output calls into pwsh-transpiler-Write-Output calls,
which wraps each value written to output in a wrapper class.

Then each block is wrapped in a pipeline filter that unwraps wrapped items and suppresses all
others.

### [splatExpressions](./transformers/splatExpressions.psm1)

IDEA:
Allow splatting parenthesized expressions, eliminating the need to use a temporary variable.

    @(echo 1 2 3 | ? {})

becomes:

    $_tmp_1 = echo 1 2 3 | ? {} ; @_tmp_1

### [swallowBreaks](./transformers/swallowBreaks.psm1)

Swallow all `break` statements in this function and in code called by this function.

### [underscoreParamFromPipeline](./transformers/underscoreParamFromPipeline.psm1)

IDEA:
If a function declares an $_ parameter,
That parameter should come from pipeline input and be named InputValue
Transform:
    param($_)
    process { echo $_ }
into:
    param([Parameter(ValueFromPipeline)]$InputValue)
    process { $_ = $InputValue ; echo $_ }

### [validate](./transformers/validate.psm1)

Not a transformer per-se.  It validates the input function,
throwing a helpful error if it uses syntax that these transformers do not yet support.
<!--/-->
