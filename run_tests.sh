#!/bin/bash

# ./run_tests.sh         # normal mode
# ./run_tests.sh valgrind
# ./run_tests.sh helgrind
# ./run_tests.sh all

# ==============================================================
#  Philosopher Test Runner
#  by dmlasko
#  Runs standard, Valgrind, and Helgrind test suites.
# ==============================================================

NAME="philo"
VALGRIND="valgrind"
HELGRIND="valgrind --tool=helgrind"
LOG_DIR="./logs"

ARGS_LIST=(
	
	# 1 philosopher
	"1 800 200 200 10 1"

	# long time_to_eat || time_to_sleep
	"2 80 20 20000 10 1"
	"2 80 20000 20 10 1"

	# short time_to_die
	"2 80 20 20 10 0"
	"4 80 20 20 10 0"
	"5 80 20 20 10 0"

	# rising philosopher count
	"2 800 200 200 10 0"
	"4 800 200 200 10 0"
	"5 800 200 200 10 0"
	"10 800 200 200 10 0"
	"20 800 200 200 10 0"
	"50 800 200 200 10 0"
	"100 800 200 200 10 0"
	"150 800 200 200 10 0"
	"200 800 200 200 10 0"
	
	# big philosopher count - smaller time_to_die 
	"100 600 200 200 10 0"
	"150 600 200 200 10 0"
	"200 600 200 200 10 0"

	# big philosopher count - even smaller time_to_die 
	"100 420 200 200 10 0"
	"150 420 200 200 10 0"
	"200 420 200 200 10 0"

	# philosopher is expected to die in thsese scenarios 
	"10 399 200 200 10 1"
	"2 399 200 200 10 1"
	"5 599 200 200 10 1"
	"5 150 60 60 5 1"
	"3 120 60 60 3 1"

	# extra tests
	"10 210 100 100 5 0"
	"4 120 50 50 3 0"
	"10 100 40 40 5 0"
	"10 80 30 30 5 0"
)

# --------------------------------------------------------------
# Run a single test
# --------------------------------------------------------------
run_test() {
	local args="$1"
	local count="$2"
	local logfile="$LOG_DIR/test_$(printf "%02d" "$count").log"
	local expected_outcome
	local args_only

	mkdir -p "$LOG_DIR"
	> "$logfile"

	echo -e "\nRunning test #$count: $args" | tee -a "$logfile"
	args_only=$(echo "$args" | awk '{print $1, $2, $3, $4, $5}')
	expected_outcome=$(echo "$args" | awk '{print $NF}')

	./$NAME $args_only >> "$logfile" 2>&1

	if grep -iq "died" "$logfile"; then
		echo "❌ Philo died..." | tee -a "$logfile"
		if [ "$expected_outcome" = "1" ]; then
			echo "✅ Expected outcome: PASS" | tee -a "$logfile"
		else
			echo "❌ Unexpected outcome: FAIL" | tee -a "$logfile"
		fi
	else
		echo "✅ No philos died!" | tee -a "$logfile"
		if [ "$expected_outcome" = "0" ]; then
			echo "✅ Expected outcome: PASS" | tee -a "$logfile"
		else
			echo "❌ Unexpected outcome: FAIL" | tee -a "$logfile"
		fi
	fi

	echo "-----------------------------------------------------" | tee -a "$logfile"
}

# --------------------------------------------------------------
# Run a Valgrind test
# --------------------------------------------------------------
run_valgrind_test() {
	local args="$1"
	local count="$2"
	local logfile="$LOG_DIR/valgrind_$(printf "%02d" "$count").log"
	local args_only
	args_only=$(echo "$args" | awk '{print $1, $2, $3, $4, $5}')

	echo -e "\nRunning Valgrind test #$count: $args" | tee -a "$logfile"
	$VALGRIND --log-file="$logfile" ./$NAME $args_only >> "$logfile" 2>&1

	grep -i "lost" "$logfile" && echo "❌ Memory leaks!" || echo "✅ No memory leaks found"
	echo "-----------------------------------------------------" | tee -a "$logfile"
}

# --------------------------------------------------------------
# Run a Helgrind test
# --------------------------------------------------------------
run_helgrind_test() {
	local args="$1"
	local count="$2"
	local logfile="$LOG_DIR/helgrind_$(printf "%02d" "$count").log"
	local args_only
	args_only=$(echo "$args" | awk '{print $1, $2, $3, $4, $5}')

	echo -e "\nRunning Helgrind test #$count: $args" | tee -a "$logfile"
	$HELGRIND --log-file="$logfile" ./$NAME $args_only >> "$logfile" 2>&1

	grep -i "possible data race" "$logfile" && echo "❌ Data Race Detected!" || echo "✅ No data race found"
	grep -i "lock order violation" "$logfile" && echo "❌ Lock Order Violation Detected!" || echo "✅ No lock order violations"
	grep -i "potential deadlock" "$logfile" && echo "❌ Potential Deadlock Detected!" || echo "✅ No deadlocks detected"
	grep -i "mutex" "$logfile" && echo "❌ Mutex Misuse Detected!" || echo "✅ Mutexes handled properly"
	echo "-----------------------------------------------------" | tee -a "$logfile"
}

# --------------------------------------------------------------
# Main runner
# --------------------------------------------------------------
run_suite() {
	local mode="$1"
	local count=0
	local success=0
	local fail=0

	mkdir -p "$LOG_DIR"

	echo -e "\n=== Running $mode tests ==="

	for args in "${ARGS_LIST[@]}"; do
		count=$((count + 1))

		case "$mode" in
			normal) run_test "$args" "$count" ;;
			valgrind) run_valgrind_test "$args" "$count" ;;
			helgrind) run_helgrind_test "$args" "$count" ;;
		esac
	done

	echo -e "\n==== $mode TEST SUITE FINISHED ====\n"
}

# --------------------------------------------------------------
# CLI options
# --------------------------------------------------------------
case "$1" in
	normal|"")
		run_suite "normal"
		;;
	valgrind)
		run_suite "valgrind"
		;;
	helgrind)
		run_suite "helgrind"
		;;
	all)
		run_suite "normal"
		run_suite "valgrind"
		run_suite "helgrind"
		;;
	*)
		echo "Usage: $0 [normal|valgrind|helgrind|all]"
		exit 1
		;;
esac
