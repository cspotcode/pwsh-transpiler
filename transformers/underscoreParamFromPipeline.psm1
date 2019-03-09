<#
 # IDEA:
 # If a function declares an $_ parameter,
 # That parameter should come from pipeline input and be named InputValue
 # Transform:
 #     param($_)
 #     process { echo $_ }
 # into:
 #     param([Parameter(ValueFromPipeline)]$InputValue)
 #     process { $_ = $InputValue ; echo $_ }
 #
 #>