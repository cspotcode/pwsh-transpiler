# Emit docs for all transformers
gci transformers | % {
    $name = split-path -leafbase $_
    $m = ipmo -fo ($_.fullname) -passthru
    $cmd = $m.exportedcommands.$name
    "### [$name](./transformers/$name.psm1)"
    ""
    ( get-help $cmd ).synopsis
    ""
}