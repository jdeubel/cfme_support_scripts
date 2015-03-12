BEGIN { FS = ","}
 { print $3 "-" $6  $9 "|" $0}
 END {}