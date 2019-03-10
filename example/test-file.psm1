write-host 'foo'
return
write-host 'foo2'
$sb = {
    write-output real1
    write-output real2
    write-output real3
    throw 'error'
}

write-output $sb.file
$sb = $sbAst.getScriptBlock()
. $sb
