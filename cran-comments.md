This is a resubmission of the package. 

There are no references describing the methods in the package.

In this version I changed `cat()` to `message()`. The only `cat()` and `print()` left are used for the tests, which are necessary to output to files and to see a formatted output. A normal user would not have access to tests.


## Test environments

* maxOS-latest (release) aarch64-apple-darwin20
* windows-latest (release) x86_64-w64-mingw32
* ubuntu-latest (devel) x86_64-pc-linux-gnu
* ubuntu-latest (release) x86_64-pc-linux-gnu
* ubuntu-latest (oldrel-1 4.4.3) x86_64-pc-linux-gnu (64-bit)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
