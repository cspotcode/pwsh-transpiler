<#
 # IDEA:
 # Allow splatting parenthesized expressions, eliminating the need to use a temporary variable.
 #
 #     @(echo 1 2 3 | ? {})
 #
 # becomes:
 #
 #     $_tmp_1 = echo 1 2 3 | ? {} ; @_tmp_1
 #
 #>