# Experimental source-to-source code transformer for PowerShell functions.

Writing PowerShell CmdLet functions the "right way" involves far too much boilerplate and manual effort.
What if we could pre-compile our functions into a form that does all the right things without extra boilerplate?

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

For sample usage, see "test.ps1"

Inspired by discussion on https://github.com/PowerShell/PowerShell/issues/8819 and https://github.com/PoshCode/PowerShellPracticeAndStyle/issues/37
