<!--

When you have set up your repo

**Unit tests and coverage**

[![](https://img.shields.io/badge/Octave-CI-blue?logo=Octave&logoColor=white)](https://github.com/Remi-gau/template_matlab_analysis/actions)
![](https://github.com/Remi-gau/template_matlab_analysis/workflows/CI/badge.svg)

[![codecov](https://codecov.io/gh/Remi-gau/template_matlab_analysis/branch/master/graph/badge.svg)](https://codecov.io/gh/Remi-gau/template_matlab_analysis)

**Miss_hit linter**

[![Build Status](https://travis-ci.com/Remi-gau/template_matlab_analysis.svg?branch=master)](https://travis-ci.com/Remi-gau/template_matlab_analysis)

-->
# spm_2_bids

Small code base to help convert the MRI spm output to a valid bids derivatives.

This code only generates the plausible BIDS derivatives filename for given file that has
been preprocessed with SPM.

Most of the renaming is based on the SPM prefixes combinations.

It is configurable to adapt to new set of prefixes.

- [Dependencies](./lib/README.md)
- [Documentation](https://spm-2-bids.readthedocs.io/en/latest/)