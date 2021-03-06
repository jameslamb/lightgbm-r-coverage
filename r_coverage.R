library(covr)
library(glue)

.run_shell_command <- function(cmd, ...){
    exit_code <- system(cmd, ...)
    if (exit_code != 0){
        stop(paste0("Command failed with exit code: ", exit_code))
    }
}

args <- commandArgs(
    trailingOnly = TRUE
)
LIGHTGBM_SOURCE <- args[[1]]

path <- file.path(LIGHTGBM_SOURCE, "lightgbm_r")
TMP_LIB <- file.path(
    Sys.getenv("HOME")
    , "Desktop"
    , "8e3dc0c5-dd74-44c1-b4e8-db1f166f6ae6"
)
type <- c("tests", "vignettes", "examples", "all", "none")
combine_types <- TRUE
relative_path <- TRUE
quiet <- TRUE
clean <- TRUE
line_exclusions <- NULL
function_exclusions <- NULL
code <- character()

if (!dir.exists(path)){
    .run_shell_command(
        glue::glue(
            "export CXX=/usr/local/bin/g++-8 CC=/usr/local/bin/gcc-8; cd '{LIGHTGBM_SOURCE}' && Rscript build_r.R"
        )
    )
} else {
    print("copying test files to the location instrumented for coverage")
    test_files <- list.files(
        path = file.path(LIGHTGBM_SOURCE, "R-package", "tests", "testthat")
        , pattern = "*test.*\\.R$"
        , full.names = TRUE
        , include.dirs = FALSE
    )
    for (test_file in test_files){
        file.copy(
            from = test_file
            , to = file.path(
                TMP_LIB
                , "lightgbm"
                , "lightgbm-tests"
                , "testthat"
            )
            , overwrite = TRUE
        )
        file.copy(
            from = test_file
            , to = file.path(
                TMP_LIB
                , "lightgbm"
                , "tests"
                , "testthat"
            )
            , overwrite = TRUE
        )
    }
}

pkg <- covr:::as_package(path)
type <- "tests"
type <- covr:::parse_type(type)
run_separately <- !isTRUE(combine_types) && length(type) > 1

tmp_lib <- TMP_LIB
if (!dir.exists(tmp_lib)){
    dir.create(tmp_lib)
}

flags <- getOption("covr.flags")
if (!covr:::uses_icc()) {
    flags <- getOption("covr.flags")
} else {
    if (length(getOption("covr.icov")) > 0L) {
        flags <- getOption("covr.icov_flags")
        unlink(file.path(pkg$path, "src", "*.dyn"))
        unlink(file.path(pkg$path, "src", "pgopti.*"))
    } else {
        stop("icc is not available")
    }
}

# At this point, edit the main CMAkeLists.txt and then run Rscript build_r.R
file.copy(
    file.path(.libPaths()[[1]], pkg$package)
    , tmp_lib
    , recursive = TRUE
)
res <- covr:::add_hooks(
    "lightgbm"
    , tmp_lib
    , fix_mcexit = FALSE
)
libs <- covr:::env_path(
    tmp_lib
    , .libPaths()
)
withr::with_envvar(
    c(
        R_DEFAULT_PACKAGES = "datasets,utils,grDevices,graphics,stats,methods"
        , R_LIBS = libs
        , R_LIBS_USER = libs
        , R_LIBS_SITE = libs
        , R_COVR = "true"
    )
    , {
        out_dir <- file.path(tmp_lib, pkg$package)
        result <- tools::testInstalledPackage(
            pkg$package
            , outDir = out_dir
            , types = "tests"
            , lib.loc = tmp_lib
        )
        if (result != 0L) {
            covr:::show_failures(out_dir)
        }
        covr:::run_commands(pkg, tmp_lib, code)
    }
)

trace_files <- list.files(
    path = tmp_lib
    , pattern = "^covr_trace_[^/]+$"
    , full.names = TRUE
)

coverage <- covr:::merge_coverage(
    trace_files
)

# where the magic of getting coverage is supposed to happen
res <- covr:::run_gcov(tmp_lib, quiet = FALSE)
coverage <- structure(
    c(coverage, res)
    , class = "coverage"
    , package = pkg
    , relative = relative_path
)
print(coverage)

covr::report(
    x = coverage
    , file = file.path(getwd(), "coverage.html")
    , browse = TRUE
)
