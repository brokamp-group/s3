## Resubmission

Based on feedback from CRAN, I have:

- used quotes, spelled out acronyms, and provided linkable-URLs when mentioning 'AWS S3'
- used donttest for long running examples
- eliminated problem with exporting magrittr pipe
- be more specific with return types for exported functions
- ensure files will not be written to users home directory by default
- write to tempdir() in examples/vignettes/tests

## R CMD check results

0 errors | 0 warnings | 0 notes

* This is a new release.
