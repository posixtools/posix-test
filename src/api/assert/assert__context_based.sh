#!/bin/sh
#==============================================================================
#    _____            _            _     _                        _
#   / ____|          | |          | |   | |                      | |
#  | |     ___  _ __ | |_ _____  _| |_  | |__   __ _ ___  ___  __| |
#  | |    / _ \| '_ \| __/ _ \ \/ / __| | '_ \ / _` / __|/ _ \/ _` |
#  | |___| (_) | | | | ||  __/>  <| |_  | |_) | (_| \__ \  __/ (_| |
#   \_____\___/|_| |_|\__\___/_/\_\\__| |_.__/ \__,_|___/\___|\__,_|
#
#==============================================================================
# CONTEXT BASED ASSERTIONS
#==============================================================================

#==============================================================================
# Context based assertions - as the name implies - needs a predefined context to
# be able to run. This context is provided by the 'run' function. To be able to
# use context based assertions you need to run the testable function or command
# with the 'run' function. This will save the output and the status of the
# executed function or command into the global assertion context, and you can
# call assertions to test this context. In this way you can check if a function
# or command provided the expected status code and output without running it
# multiple times for each assertions.
#==============================================================================

# Global variables that hold the last execution results of the tested function
# or command.
POSIX_TEST__ASSERT__RUNTIME__LAST_STATUS='__INVALID__'
POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1='__INVALID__'
POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2='__INVALID__'

#==============================================================================
#  ____
# |  _ \ _   _ _ __  _ __   ___ _ __
# | |_) | | | | '_ \| '_ \ / _ \ '__|
# |  _ <| |_| | | | | | | |  __/ |
# |_| \_\\__,_|_| |_|_| |_|\___|_|
#==============================================================================
# RUNNER FUNCTION
#==============================================================================

#==============================================================================
# Function under test capturer API function. It excepts a list of parameters
# that will be executed while the standard output, standard error and the status
# will be captured and will be put into test case level buffer files. Calling
# the testable function in this way is necessary if we want to use the advanced
# context based assertion functions, as those are working on the output
# variables of this function.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__ASSERT__RUNTIME__LAST_STATUS
#   POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1
#   POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2
# Arguments:
#   [..] command - Commands and parameters that needs to be executed.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   POSIX_TEST__ASSERT__RUNTIME__LAST_STATUS
#   POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1
#   POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected, as the status of the given command is
#       captured.
#==============================================================================
run() {
  posix_test__debug 'run' "running command: '$*'"

  # Creating temporary files to store the standard output and standard error
  # contents of the executed function.
  POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1="$( \
    posix_test__cache__create_temp_path \
  )"
  POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2="$( \
    posix_test__cache__create_temp_path \
  )"

  # Storing the passed command as a variable is not an option here, because it
  # would be re-splitted on execution.
  if "$@" \
    1>"$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1" \
    2>"$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2"
  then
    POSIX_TEST__ASSERT__RUNTIME__LAST_STATUS="$?"
  else
    POSIX_TEST__ASSERT__RUNTIME__LAST_STATUS="$?"
  fi

  posix_test__debug_list 'run' 'captured standard output:' \
    "$(posix_adapter__cat "$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1")"
  posix_test__debug_list 'run' 'captured standard error:' \
    "$(posix_adapter__cat "$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2")"

  posix_test__debug 'run' "captured status: '${POSIX_TEST__ASSERT__RUNTIME__LAST_STATUS}'"
}

#==============================================================================
#  ____  _        _
# / ___|| |_ __ _| |_ _   _ ___
# \___ \| __/ _` | __| | | / __|
#  ___) | || (_| | |_| |_| \__ \
# |____/ \__\__,_|\__|\__,_|___/
#==============================================================================
# STATUS ASSERTION
#==============================================================================

#==============================================================================
# Context based assertion function that will evaluate the previously set
# 'status' variable by the 'run' function.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__ASSERT__RUNTIME__LAST_STATUS
# Arguments:
#   [1] expected_status - Expected status of the previously run function.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#==============================================================================
assert_status() {
  ___expected="$1"
  ___result="$POSIX_TEST__ASSERT__RUNTIME__LAST_STATUS"

  posix_test__debug 'assert_status' 'asserting status:'
  posix_test__debug 'assert_status' "- expected: '${___expected}'"
  posix_test__debug 'assert_status' "- result:   '${___result}'"

  if [ "$___result" = "$___expected" ]
  then
    posix_test__debug 'assert_status' '=> assertion succeeded'
  else
    posix_test__debug 'assert_status' '=> assertion failed'

    ___subject='Status comparison failed'
    ___reason="expected: ${___expected}\n  actual: ${___result}"
    ___assertion='assert_status'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
#  ____  _      _               _               _
# / ___|| |_ __| |   ___  _   _| |_ _ __  _   _| |_
# \___ \| __/ _` |  / _ \| | | | __| '_ \| | | | __|
#  ___) | || (_| | | (_) | |_| | |_| |_) | |_| | |_
# |____/ \__\__,_|  \___/ \__,_|\__| .__/ \__,_|\__|
#==================================|_|=========================================
# STANDARD OUTPUT ASSERTIONS
#==============================================================================

#==============================================================================
# Context based assertion function that will compare the standard output of the
# tested function with the given value. If there is no argument passed to this
# function, it will only check the presence of the output.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1
# Arguments:
#   [1] expected_output <optional> - Expected output of the previously run
#       function.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
# - None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#==============================================================================
assert_output() {
  # Handling the special case then there is no passed parameter.
  if [ "$#" -eq '0' ]
  then
    ___target_buffer="$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1"
    ___assertion_name="assert_output"

    _posix_test__assert__assert_has_output \
      "$___target_buffer" \
      "$___assertion_name"

    # If the previous assertion hasn't exited the execution, we have to
    # explicitly abort with success.
    return 0
  fi

  ___expected="$1"
  ___target_buffer="$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1"
  ___assertion_name="assert_output"

  _posix_test__assert__assert_output \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"

  ___result="$?"

  if [ "$___result" -eq '2' ]
  then
    posix_test__debug 'assert_output' '=> assertion failed'

    ___subject='Inappropriate assertion function'
    ___reason="Multiline output should be asserted with assert_output_line_at_index' or 'assert_output_line_partially_at_index'."
    ___assertion='assert_output'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Context based assertion function that will check if there is no standard
# output captured during the last 'run' command execution.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
# - None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#==============================================================================
assert_no_output() {
  ___target_buffer="$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1"

  if [ -s "$___target_buffer" ]
  then
    posix_test__debug 'assert_no_output' '=> assertion failed'

    ___subject='Standard output was captured.'
    ___reason="$( \
      echo 'The tested functionality should not have emitted content on the standard output: '; \
      posix_adapter__cat "$___target_buffer" | \
        posix_adapter__sed --expression 's/$/\|/' | \
        posix_adapter__sed --expression 's/^/\|/'; \
    )"
    ___assertion='assert_no_output'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Context based assertion function to check the line count of the command
# output executed with the 'run' function.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1
# Arguments:
#   [1] expected_line_count - Expected output line count.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#==============================================================================
assert_output_line_count() {
  ___expected="$1"
  ___target_buffer="$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1"
  ___assertion_name="assert_output_line_count"

  _posix_test__assert__assert_line_count \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"
}

#==============================================================================
# Context based assertion function that compares the output line indexed by the
# index parameter with the expected parameter.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected_content - Expected content of the given line without the new
#       line character.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#==============================================================================
assert_output_line_at_index() {
  ___line_index="$1"
  ___expected="$2"
  ___target_buffer="$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1"
  ___assertion_name="assert_output_line_at_index"

  _posix_test__assert__assert_line_at_index \
    "$___line_index" \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"
}

#==============================================================================
# Context based assertion function that compares the output line indexed by the
# index parameter with the expected parameter. The line has to partially match
# only, should be a part of the whole output line.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected_content - Expected content of the given line without the new
#       line character.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#==============================================================================
assert_output_line_partially_at_index() {
  ___line_index="$1"
  ___expected="$2"
  ___target_buffer="$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1"
  ___assertion_name="assert_output_line_partially_at_index"

  _posix_test__assert__assert_line_partially_at_index \
    "$___line_index" \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"
}

#==============================================================================
#  ____  _      _
# / ___|| |_ __| |   ___ _ __ _ __ ___  _ __
# \___ \| __/ _` |  / _ \ '__| '__/ _ \| '__|
#  ___) | || (_| | |  __/ |  | | | (_) | |
# |____/ \__\__,_|  \___|_|  |_|  \___/|_|
#==============================================================================
# STANDARD ERROR ASSERTIONS
#==============================================================================

#==============================================================================
# Context based assertion function that will fail if there are any standard
# error captured output.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
# - None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#==============================================================================
assert_no_error() {
  ___target_buffer="$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2"

  if [ -s "$___target_buffer" ]
  then
    posix_test__debug 'assert_no_error' '=> assertion failed'

    ___subject='Standard error output was captured.'
    ___reason="$( \
      echo 'The tested functionality should not have emitted content on the standard error output: '; \
      posix_adapter__cat "$___target_buffer" | \
        posix_adapter__sed --expression 's/$/\|/' | \
        posix_adapter__sed --expression 's/^/\|/'; \
    )"
    ___assertion='assert_no_error'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Context based assertion function that will compare the standard error output
# of the tested function with the given value. If there is no argument passed to
# this function, it will only check the presence of the error output.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2
# Arguments:
#   [1] expected_output <optional> - Expected output of the previously run
#       function.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
# - None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#==============================================================================
assert_error() {
  # Handling the special case then there is no passed parameter.
  if [ "$#" -eq '0' ]
  then
    ___target_buffer="$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2"
    ___assertion_name="assert_error"

    _posix_test__assert__assert_has_output \
      "$___target_buffer" \
      "$___assertion_name"

    # If the previous assertion hasn't exited the execution, we have to
    # explicitly abort with success.
    return 0
  fi

  ___expected="$1"
  ___target_buffer="$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2"
  ___assertion_name="assert_error"

  _posix_test__assert__assert_output \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"

  ___result="$?"

  if [ "$___result" -eq '2' ]
  then
    posix_test__debug 'assert_error' '=> assertion failed'

    ___subject='Inappropriate assertion function'
    ___reason="Multiline output should be asserted with 'assert_error_line_at_index' or 'assert_error_line_partially_at_index'."
    ___assertion='assert_error'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Context based assertion function to check the line count of the command
# error output executed with the 'run' function.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2
# Arguments:
#   [1] expected_line_count - Expected error output line count.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#==============================================================================
assert_error_line_count() {
  ___expected="$1"
  ___target_buffer="$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2"
  ___assertion_name="assert_error_line_count"

  _posix_test__assert__assert_line_count \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"
}

#==============================================================================
# Context based assertion function that compares the error output line indexed
# by the index parameter with the expected parameter.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected_content - Expected content of the given line without the new
#       line character.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#==============================================================================
assert_error_line_at_index() {
  ___line_index="$1"
  ___expected="$2"
  ___target_buffer="$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2"
  ___assertion_name="assert_error_line_at_index"

  _posix_test__assert__assert_line_at_index \
    "$___line_index" \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"
}

#==============================================================================
# Context based assertion function that compares the error output line indexed
# by the index parameter with the expected parameter. The line has to partially
# match only, should be a part of the whole error output line.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected_content - Expected content of the given line without the new
#       line character.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#==============================================================================
assert_error_line_partially_at_index() {
  ___line_index="$1"
  ___expected="$2"
  ___target_buffer="$POSIX_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2"
  ___assertion_name="assert_error_line_partially_at_index"

  _posix_test__assert__assert_line_partially_at_index \
    "$___line_index" \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"
}

#==============================================================================
#  ____       _            _         _          _
# |  _ \ _ __(_)_   ____ _| |_ ___  | |__   ___| |_ __   ___ _ __ ___
# | |_) | '__| \ \ / / _` | __/ _ \ | '_ \ / _ \ | '_ \ / _ \ '__/ __|
# |  __/| |  | |\ V / (_| | ||  __/ | | | |  __/ | |_) |  __/ |  \__ \
# |_|   |_|  |_| \_/ \__,_|\__\___| |_| |_|\___|_| .__/ \___|_|  |___/
#================================================|_|===========================
# PRIVATE HELPERS
#==============================================================================

#==============================================================================
# Common function to check if the given buffer contains anything.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] target_buffer - Target buffer that should be used.
#   [2] assertion_name - Name of the original assertion.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
# - None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Target buffer contains something.
#   1 - Target buffer has nothing inside.
#==============================================================================
_posix_test__assert__assert_has_output() {
  ___target_buffer="$1"
  ___assertion_name="$2"

  ___result="$(posix_adapter__cat "$___target_buffer")"
  ___line_count="$(posix_adapter__wc --lines < "$___target_buffer")"
  ___char_count="$(posix_adapter__wc --chars < "$___target_buffer")"

  if [ "$___line_count" -eq '0' ] && [ "$___char_count" -eq '0' ]
  then
    posix_test__debug '_posix_test__assert__assert_has_output' \
      '=> target buffer has no content'

    ___subject='No output was captured'
    ___reason='No output was captured in the target buffer!'
    ___assertion="$___assertion_name"
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Common function to compare context based outputs.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] expected_output - Expected output of the previously run function.
#   [2] target_buffer - Target buffer that should be used.
#   [3] assertion_name - Name of the original assertion.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
# - None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#   2 - Inappropriate assertion function.
#==============================================================================
_posix_test__assert__assert_output() {
  ___expected="$1"
  ___target_buffer="$2"
  ___assertion_name="$3"

  ___result="$(posix_adapter__cat "$___target_buffer")"
  ___line_count="$(posix_adapter__wc --lines < "$___target_buffer")"
  ___char_count="$(posix_adapter__wc --chars < "$___target_buffer")"

  if [ "$___line_count" -eq '0' ] && [ "$___char_count" -eq '0' ]
  then
    posix_test__debug '_posix_test__assert__assert_output' \
      '=> nothing to compare to = assertion failed'

    ___subject='Cannot compare to empty ouput'
    ___reason='No output was captured in the target buffer, nothing to compare!'
    ___assertion="$___assertion_name"
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi

  if [ "$___line_count" -gt '1' ]
  then
    # If there are more than one lines present in the buffer, this assertion
    # method cannot be used! Returning 2 to signal this case.
    return 2
  fi

  posix_test__debug '_posix_test__assert__assert_output' \
    'asserting output:'
  posix_test__debug '_posix_test__assert__assert_output' \
    "- expected: '${___expected}'"
  posix_test__debug '_posix_test__assert__assert_output' \
    "- result:   '${___result}'"

  if [ "$___result" = "$___expected" ]
  then
    posix_test__debug '_posix_test__assert__assert_output' \
      '=> assertion succeeded'
  else
    posix_test__debug '_posix_test__assert__assert_output' \
      '=> assertion failed'

    ___subject='Output comparison failed'
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    ___assertion="$___assertion_name"
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Common function to check line counts for the context based captured outputs.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] expected_line_count - Expected output line count.
#   [2] target_buffer - Target buffer that should be used.
#   [3] assertion_name - Name of the original assertion.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#==============================================================================
_posix_test__assert__assert_line_count() {
  ___expected="$1"
  ___target_buffer="$2"
  ___assertion_name="$3"

  ___line_count="$(posix_adapter__wc --lines < "$___target_buffer")"
  ___char_count="$(posix_adapter__wc --chars < "$___target_buffer")"

  if [ "$___line_count" -eq '0' ] && [ "$___char_count" -gt '0' ]
  then
    # If there are new newline character in the buffer (line count == 0) but
    # there are characters captured, we can say that we have a line captured.
    ___result='1'
  else
    ___result="$___line_count"
  fi

  posix_test__debug '_posix_test__assert__assert_line_count' \
    'asserting output line count:'
  posix_test__debug '_posix_test__assert__assert_line_count' \
    "- expected: '${___expected}'"
  posix_test__debug '_posix_test__assert__assert_line_count' \
    "- result:   '${___result}'"

  if [ "$___result" -eq "$___expected" ]
  then
    posix_test__debug '_posix_test__assert__assert_line_count' \
      '=> assertion succeeded'
  else
    posix_test__debug '_posix_test__assert__assert_line_count' \
      '=> assertion failed'

    ___subject='Output line count mismatch'
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    ___assertion="$___assertion_name"
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Common context based assertion function that compares the output line indexed
# by the index parameter with the expected parameter.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected_content - Expected content of the given line without the new
#       line character.
#   [3] target_buffer - Target buffer that should be used.
#   [4] assertion_name - Name of the original assertion.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#==============================================================================
_posix_test__assert__assert_line_at_index() {
  ___index="$1"
  ___expected="$2"
  ___target_buffer="$3"
  ___assertion_name="$4"

  if ___result="$( \
    posix_test__get_line_from_output_buffer_by_index \
      "$___index" \
      "$___target_buffer" \
  )"
  then
    # Line extraction succeeded, the '__result' variable contains the extracted
    # line.
    :
  else
    # As the line extraction function returned a nonzero status, the line
    # extraction failed, and the error was already reported. Since it is
    # happened in a subshell to obtain the output from it, the execution won't
    # stop here, so we should simply return from here.
    return
  fi

  posix_test__debug '_posix_test__assert__assert_line_at_index' \
    'asserting output line at index:'
  posix_test__debug '_posix_test__assert__assert_line_at_index' \
    "- expected: '${___expected}'"
  posix_test__debug '_posix_test__assert__assert_line_at_index' \
    "- result:   '${___result}'"

  if [ "$___result" = "$___expected" ]
  then
    posix_test__debug '_posix_test__assert__assert_line_at_index' \
      '=> assertion succeeded'
  else
    posix_test__debug '_posix_test__assert__assert_line_at_index' \
      '=> assertion failed'

    ___subject="Line at index '${___index}' differs from expected"
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    ___assertion="$___assertion_name"
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Common context based assertion function that compares the output line indexed
# by the index parameter with the expected parameter. The line has to partially
# match only, should be a part of the whole output line.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected_content - Expected content of the given line without the new
#       line character.
#   [3] target_buffer - Target buffer that should be used.
#   [4] assertion_name - Name of the original assertion.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#==============================================================================
_posix_test__assert__assert_line_partially_at_index() {
  ___index="$1"
  ___expected="$2"
  ___target_buffer="$3"
  ___assertion_name="$4"

  if ___result="$( \
    posix_test__get_line_from_output_buffer_by_index \
      "$___index" \
      "$___target_buffer" \
  )"
  then
    # Line extraction succeeded, the '__result' variable contains the extracted
    # line.
    :
  else
    # As the line extraction function returned a nonzero status, the line
    # extraction failed, and the error was already reported. Since it is
    # happened in a subshell to obtain the output from it, the execution won't
    # stopped here, so we should simply return from here.
    return
  fi

  posix_test__debug '_posix_test__assert__assert_line_partially_at_index' \
    'asserting output line at index partially:'
  posix_test__debug '_posix_test__assert__assert_line_partially_at_index' \
    "- pattern: '${___expected}'"
  posix_test__debug '_posix_test__assert__assert_line_partially_at_index' \
    "- target:   '${___result}'"

  if echo "$___result" | posix_adapter__grep --silent "$___expected"
  then
    posix_test__debug '_posix_test__assert__assert_line_partially_at_index' \
      '=> assertion succeeded'
  else
    posix_test__debug '_posix_test__assert__assert_line_partially_at_index' \
      '=> assertion failed'

    ___subject="Line at index '${___index}' differs from expected'"
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    ___assertion="$___assertion_name"
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}
