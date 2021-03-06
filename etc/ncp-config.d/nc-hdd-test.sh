#!/bin/bash

# Check HDD health
#
# Copyleft 2018 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com
#

SHORTTEST_=yes
LONGTEST_=no
DESCRIPTION="Check HDD health"

INFO="Running no test will display test results"

install()
{
  apt-get update
  apt-get install --no-install-recommends -y smartmontools
  systemctl disable smartd
  systemctl stop smartd
}

configure()
{
  local DRIVES=($(lsblk -ln | grep "^sd[[:alpha:]].*disk" | awk '{ print $1 }'))

  [[ ${#DRIVES[@]} == 0 ]] && {
    echo "no drives detected. Abort"
    return 0
  }

  for dr in "${DRIVES[@]}"; do
    smartctl --smart=on /dev/${dr} | sed 1,2d
    if [[ "$SHORTTEST_" == yes ]]; then
      echo "* Starting test on $dr. Check results later"
      smartctl -X "/dev/$dr" &>/dev/null
      smartctl -t short "/dev/$dr" | sed 1,2d
    elif [[ "$LONGTEST_" == yes ]]; then
      echo "* Starting test on $dr. Check results later"
      smartctl -X "/dev/$dr" &>/dev/null
      smartctl -t long "/dev/$dr" | sed 1,2d
    else
      echo "* Test results for $dr"
      smartctl -l selftest "/dev/$dr" | sed 1,2d

      echo "* Health Check for $dr"
      smartctl -H "/dev/$dr" | sed 1,2d

      echo "* Stats for $dr"
      smartctl -A "/dev/$dr" | sed 1,2d
    fi
  done
}

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA
