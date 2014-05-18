#!/bin/sh

# The python script has a shebang line of #!/usr/bin/env python 
# We really need Splunk's python environment as the script uses splunk.Intersplunk
# Technically, we could use the system's python (assuming there is one) if they have the python SDK installed.
# While that is standard for a python script, not every system has python installed at the system level.
# Since we have the expectation of being ran as a Splunk app, let's assume splunk is installed
# and thus we can utilize its version of python
DEFAULT_SPLUNK_HOME="/opt/splunk"


find_python() {
  #Try to find a variable indicating Splunk Home
  if [ -z "$SPLUNK_HOME" ] ; then
    if [ -e "${SPLUNK_HOME}/bin/python" ] ; then
      echo "${SPLUNK_HOME}/bin/python"
      return
    fi
  fi

  #Try to find Splunk Home -- since we should be running as an app in etc/apps/app_name/bin try ../../../../bin/python
  if [ -e "../../../../bin/python" ] ; then
    echo "../../../../bin/python"
    return
  fi

  #Try a default splunk home
  if [ -e "/opt/splunk/bin/python" ] ; then
    echo "/opt/splunk/bin/python"
  fi

  if [ -e "/Applications/splunk/bin/python" ] ; then
    echo "/Applications/splunk/bin/python"
  fi
}

needsudo() {
  # check root permissions
  if [ "$UID" != "0" ]; then
    echo "sudo -n "
    return
  fi
}

# by nolan6000 
# http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file/21188136#21188136
get_abs_filename() {
  # $1 : relative filename
  if [ -d "$(dirname "$1")" ]; then
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
  fi
}


PYTHON=$(find_python)
SUDO=$(needsudo)
OUTPUT=$($SUDO $PYTHON ./cc_iops.py "$@" 2>&1)

#if [ "$OUTPUT" = "sudo: a password is required" ] ; then
if [ "$OUTPUT" = "sudo: a password is required" ] || [ "$OUTPUT" = "sudo: sorry, a password is required to run sudo" ] ; then
  me=$(get_abs_filename "$0")
  CC=$(dirname $(get_abs_filename "$0"))
  CC="${CC}/cc_iops.py"
  echo "Unable to execute sudo as it required a password. Please edit the sudoers so $USER can run $me without a password."
  echo "$USER    $HOSTNAME = NOPASSWD: $CC"
  echo "Please be careful! If a non-root user owns or can write to $CC, they will effectively have passwordless root access to your system as they can modify the script"
  exit 2
fi

echo $OUTPUT
