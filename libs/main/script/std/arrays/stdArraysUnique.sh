function stdArraysUnique {
  local array=($@)
  local uniqueArray=()

  for item in ${array[@]}
  do

    local found=false

    for unique in ${uniqueArray[@]}
    do
      [[ "$unique" = "$item" ]] && found=true && break
    done

    [[ $found = false ]] && echo $item

    uniqueArray=(${uniqueArray[@]} $item)

  done

}