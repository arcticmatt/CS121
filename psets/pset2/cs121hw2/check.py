#! /usr/bin/env python

"""
CS 121 Style-Checker
--------------------
This makes sure that your assignment submissions are formatted correctly. It is
unable to catch assignment-specific configurations (like if you actually
submitted something for every question). It is also unable to check for MySQL
syntax errors.

Usage: python check.py filename1 [filename2 ...]
       python check.py *

Errors:
  [BAD PROBLEM HEADER] - Problem header was not formatted correctly.
  [DO NOT USE TABS] - Tabs should not be used for indentation. Use spaces.
  [LINE TOO LONG] - Lines should not be longer than 80 characters.
  [PUT SPACE AFTER COMMA] - There should be a space after any comma.
  [CODE BEFORE PROBLEM HEADER] - No code should appear before the first problem
                                 header.
  [NO DOUBLE-QUOTED STRINGS] - Strings must be enclosed by SINGLE quotes.
"""

import os
import re
import sys

MAX_LINE_LENGTH = 80

S                   = "[^\>\<\=\(\) \t\n\r\f\v]"

header              = re.compile("-- \[Problem (([0-9])+([a-zA-Z])*|[a-zA-Z])\]")
bad_header          = re.compile("-- \[Problem([^\]])*\]")
comment             = re.compile(r"\s*--.|/\*.|\*/.")
tabs                = re.compile(r"\t+")
comma_space         = re.compile(",[^ ][^\n]")
negative_num        = re.compile(r"\-([0-9]*\.?[0-9]+)")
count_star          = re.compile("\(\*\)|\(DISTINCT \*\)")
double_quote        = re.compile("\"([^\"])*\"")
HAS_HEADER = False
MULTILINE_COMMENT = False

def check_line(line, line_number):
  """
  Function: check_line
  --------------------
  Checks a line of a file for style violations.
  """
  global HAS_HEADER, MULTILINE_COMMENT
  is_bad_header = False

  def h():
    return "Line %d " % (line_number)

  def f(line):
    return ":\n  %s" % line.strip()

  if not len(line.strip()):
    return

  # Check for problem header formatting errors (cannot have code before a
  # problem header).
  if not HAS_HEADER and header.search(line):
    HAS_HEADER = True
  if line.strip().startswith("/*"):
    MULTILINE_COMMENT = True

  # Check for style mistakes.
  if bad_header.search(line) and not header.search(line):
    print h() + "[BAD PROBLEM HEADER]" + f(line)
    is_bad_header = True
  if tabs.search(line):
    print h() + "[DO NOT USE TABS]" + f(line)
  if len(line) > MAX_LINE_LENGTH:
    print h() + "[LINE TOO LONG (" + str(len(line)) + " CHARS)]" + f(line)
  if not MULTILINE_COMMENT and not comment.search(line):
    if comma_space.search(line):
      print h() + "[PUT SPACE AFTER COMMA]" + f(line)
    if double_quote.search(line):
      print h() + "[NO DOUBLE-QUOTED STRINGS]" + f(line)

  # Continue checking for problem header mistakes.
  if not (HAS_HEADER or
          MULTILINE_COMMENT or
          is_bad_header or
          comment.search(line.strip())):
    print h() + "[CODE BEFORE PROBLEM HEADER]" + f(line)
  if line.strip().startswith("*/") or line.strip().endswith("*/"):
    MULTILINE_COMMENT = False


if __name__ == '__main__':
  # Main program.
  if len(sys.argv) < 2:
    print "\nUsage: check.py filename1 [filename2 ...] OR\n" + \
          "       check.py *"
    sys.exit()

  files = []
  # If checking all SQL files.
  if sys.argv[1] == '*':
    files = [f for f in os.listdir(".") if f.endswith(".sql")]

  # If checking specific files.
  else: files = sys.argv[1:]

  for filename in files:
    f = open(filename, 'r')
    lines = f.readlines()
    f.close()
    print "\n", filename
    print "-" * len(filename)
    # Check for encoding.
    try:
      "\n".join(lines).decode('utf-8')
    except UnicodeDecodeError:
      print "FILE IS NOT IN UTF-8 ENCODING!"
      continue

    for i in range(len(lines)):
      line = lines[i][:-1]
      check_line(line, i + 1)
