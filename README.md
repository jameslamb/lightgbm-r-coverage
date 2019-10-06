# lightgbm-r-coverage

Scripts for measuring the unit test coverage of the code in [LightGBM's R package](https://github.com/microsoft/LightGBM/tree/master/R-package).

The code in this project was created to work around the fact that `covr::package_coverage()` fails to generate coverage on `LightGBM`'s R package. I could not find the root cause of that, after some investigation, but at least wanted to be able to measure test coverage so I'd know where to focus testing effort.

This repo's setup is VERY BRITTLE and was put together hastily. It's intended to catalog some effort I put into creating unit tests for `LightGBM`'s R package, but is use-at-your-own-risk. I do not intend to maintain a full-featured project outside of `LightGBM` for building `LightGBM` in its multiple different configurations.

The code below will probably only work for you if the following are too:

* you are using Mac OS Mojave
* you have `g++` and `gcc` installed at `/usr/local/bin/g++-8` and `/usr/local/bin/gcc-8`
* you have R installed on your machine
* you have the `covr` and `glue` R packages installed on your machine

## Setup

This setup should work on modern versions of Mac OS. Clone `LightGBM` into this space.

```bash
git clone \
    --depth 1 \
    --recursive \
    https://github.com/microsoft/LightGBM
```

## Generating a coverage report

Run this script which will build the R package and compute test coverage. Not that it will create a directory `${HOME}/Desktop/8e3dc0c5-dd74-44c1-b4e8-db1f166f6ae6`.

```bash
Rscript r_coverage.R $(pwd)/LightGBM
```

This will create a file `coverage.html` detailing the test coverage of the R package's code.

## Re-generating a coverage report

```
rm -rf $(pwd)/LightGBM/lightgbm_r
rm -rf ${HOME}/Desktop/8e3dc0c5-dd74-44c1-b4e8-db1f166f6ae6
Rscript r_coverage.R $(pwd)/LightGBM
```

## Coverage changes from successive attempts

1 - 56.37%
2 - 60.80%
3 - 62.34%
4 - 65.48%
5 - 
