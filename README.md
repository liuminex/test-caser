### Test Caser

> Test programs by comparing actual output to expected output, using time limit and (probably doesn't work) memory limit

- inputX.txt matches to outputX.txt
- input*.txt and output*.txt files must be in the same path (the 'test case path' specified using -p)
- program must be executable (e.g. compiled if in C)

usage:
```bash
./test.sh -h # view help
./test.sh -p testcases/myprogram1 -t 1000 myprogram1 # example
```
