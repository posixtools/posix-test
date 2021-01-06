#==============================================================================
# TEST HOOKS
#==============================================================================

#==============================================================================
# Test file and test case level setup and teardown hooks are available for
# setting up test fixtures. You can run arbitrary code in them, but you should
# use the provided temporary directories for storing the fixtures.
#
# An error during the [teardown file] test hook would not interrupt the
# execution, it will be just noted. The cache system is responsible for
# cleaning up the artifacts and fixtures generated by each test case, IF they
# are created in the provided test directories.
#
# 1. [setup file] hook will be executed
# 2. test cases will be executed with optional [setup] and [teardown] hooks
# 3. [teardown file] hook will be executed, but error happens
# 4. error will be ignored and other test files will be executed
#==============================================================================

setup_file() {
  echo '--- ERROR DURING TEARDOWN FILE HOOK ---------------------------------------------'
  echo 'echo during [setup file] hook'
}

setup() {
  echo 'echo during [setup] hook'
}

teardown() {
  echo 'echo during [teardown] hook'
}

teardown_file() {
  echo 'echo during [teardown file] hook - error will happen after this'
  cat invalid_file
}

test__hooks__test_case__error_during_teardown_file() {
  echo 'echo during test case'
}
