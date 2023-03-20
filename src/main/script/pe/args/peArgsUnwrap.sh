function peArgsUnwrap {
  local args=($@)
  local parsedArgs="${args[@]}"
  local parsedArgs="${parsedArgs[@]//" [#] "/ }"
  local parsedArgs="${parsedArgs[@]//" [#]"/}"
  local parsedArgs="${parsedArgs[@]//"[#] "/}"
  local parsedArgs="${parsedArgs[@]//"[#]"/}"
  echo " $parsedArgs"
}