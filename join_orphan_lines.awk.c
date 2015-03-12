BEGIN {
       hold_line = ""
      }
/^$/ {next}
/^\s/ {next}

/-- : $/ { hold_line = $0;next}

/^[A-Z]/ { hold_line = hold_line $0 ;print hold_line; hold_line = "";next}
/\[----\]/ {if (hold_line != "") { print hold_line ; hold_line = ""} print }
END {}
