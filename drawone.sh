Suites="Clubs Diamonds Hearts Spades"
Values="2 3 4 5 6 7 8 9 10 Jack Queen King Ace"
suite=($Suites);value=($Values)
num_suites=${#suite[*]};num_denominations=${#value[*]}
printf "${value[$((RANDOM%num_denominations))]} of ${suite[$((RANDOM%num_suites))]}\n"
