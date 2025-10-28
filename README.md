A simple tester for your 42 Philosophers project.

![Philosophers Project](https://github.com/dmitrijslasko/42-assets/blob/ae13cf258a837711ebdd9601ef5d3357da805784/philosophers-tester.jpg)

## How to launch 🚀
**1. Place the script in the folder with your philo binary.**
```bash
git clone https://github.com/dmitrijslasko/42_philosophers_tester.git
```
**2. Give execution permissions:**
```bash
chmod +x run_tests.sh
```

**3. Launch in the desired mode. Expected binary name: philo**
```bash
./run_tests.sh 				# normal mode
./run_tests.sh valgrind		# Valgrind check for memory leaks
./run_tests.sh helgrind		# Helgrind check for memory leaks
./run_tests.sh all			# all checks
```

## The test suite contains following test scenarios
```bash
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

# large philosopher count - smaller time_to_die 
"100 600 200 200 10 0"
"150 600 200 200 10 0"
"200 600 200 200 10 0"

# large philosopher count - even smaller time_to_die 
"100 420 200 200 10 0"
"150 420 200 200 10 0"
"200 420 200 200 10 0"

# philosopher is expected to die in these scenarios 
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
```
