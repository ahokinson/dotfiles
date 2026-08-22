typeset -rA C=(
  red    1
  green  2
  yellow 3
  blue   4
  cyan   6
  gray   8
  white  7
)
p()  { print -P "%F{${C[$2]:-7}}$1%f" }
pb() { print -P "%F{${C[$2]:-7}}%B$1%b%f" }
