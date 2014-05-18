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
  if [[ -z "$SPLUNK_HOME" ]] ; then
    if [[ -e "${SPLUNK_HOME}/bin/python" ]] ; then
      echo "${SPLUNK_HOME}/bin/python"
      return
    fi
  fi

  #Try to find Splunk Home -- since we should be running as an app in etc/apps/app_name/bin try ../../../../bin/python
  if [[ -e "../../../../bin/python" ]] ; then
    echo "../../../../bin/python"
    return
  fi

  #Try a default splunk home
  if [[ -e "/opt/splunk/bin/python" ]] ; then
    echo "/opt/splunk/bin/python"
  fi
}


PYTHON=$(find_python)
sudo $PYTHON ./cc_iops.py "$@"
