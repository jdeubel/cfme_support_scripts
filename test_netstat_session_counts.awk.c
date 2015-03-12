BEGIN {
        OFS=","
        time_of_day = strftime("%D %T")")                  # get date and time of day to inject into log lines if any
      }
$1 ~ /tcp/ {PID[$(NF)]++}
END {
 for (count in PID) {if (PID[count] >1)  print time_of_day.count,PID[count]}

}
