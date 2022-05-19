[![code quality](https://github.com/cpp-lln-lab/spm_2_bids/actions/workflows/miss_hit_code_quality.yml/badge.svg)](https://github.com/cpp-lln-lab/spm_2_bids/actions/workflows/miss_hit_code_quality.yml)
[![code style](https://github.com/cpp-lln-lab/spm_2_bids/actions/workflows/miss_hit_code_style.yml/badge.svg)](https://github.com/cpp-lln-lab/spm_2_bids/actions/workflows/miss_hit_code_style.yml)
[![tests and coverage with matlab](https://github.com/cpp-lln-lab/spm_2_bids/actions/workflows/run_tests_matlab.yml/badge.svg)](https://github.com/cpp-lln-lab/spm_2_bids/actions/workflows/run_tests_matlab.yml)
[![codecov](https://codecov.io/gh/cpp-lln-lab/spm_2_bids/branch/master/graph/badge.svg?token=yaL40GJK9y)](https://codecov.io/gh/cpp-lln-lab/spm_2_bids)

# spm_2_bids

Small code base to help convert the MRI spm output to a valid bids derivatives.

This code only generates the plausible BIDS derivatives filename for given file
that has been preprocessed with SPM.

Most of the renaming is based on the SPM prefixes combinations.

It is configurable to adapt to new set of prefixes.

## Dependencies

-   [BIDS-matlab](https://github.com/bids-standard/bids-matlab)

Can be installed with :

For MATLAB

```bash
make install_dev
```

For Octave

```bash
make install_dev_octave
```

## Usage

```matlab
file = 'wmsub-01_desc-skullstripped_T1w.nii';

[new_filename, pth, json] = spm_2_bids(file);

new_filename =

 'sub-01_space-IXI549Space_desc-preproc_T1w.nii');
```

For more see the [documentation](https://spm-2-bids.readthedocs.io/en/latest/).
