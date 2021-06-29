# test data

Input data for tests or to test against (expected output).

## cpp_spm

Contains the "typical" output of the SPM preprocessing of an fMRI dataset with
cpp_spm: in this case the MoAE dataset from SPM tutorial.

Actual data content was truncated with:

```
find . -type f -name '*.nii' -exec truncate -s 0 {} +
```
