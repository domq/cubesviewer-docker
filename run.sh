#!/bin/sh

set -e -x

manage_script=/cubesviewer/cvapp/manage.py
sqlite_db=/cubesviewer/cvapp/cubesviewer.sqlite
settings_file=/cubesviewer/cvapp/cvapp/settings.py

if [ -n "$CUBESVIEWER_CUBES_URL" ]; then
    perl -i -pe 'next unless m/^CUBESVIEWER_CUBES_URL *=/; $_ = qq(CUBESVIEWER_CUBES_URL="$ENV{CUBESVIEWER_CUBES_URL}"\n)' $settings_file
fi

if [ -n "$CUBESVIEWER_BACKEND_URL" ]; then
    perl -i -pe 'next unless m/^CUBESVIEWER_BACKEND_URL *=/; $_ = qq(CUBESVIEWER_BACKEND_URL="$ENV{CUBESVIEWER_BACKEND_URL}"\n)' $settings_file
fi

yes yes | $manage_script migrate

# To load some initial data (e.g. accounts), mount a directory
# containing initdata.sql as a Docker volume under /initdata e.g.
#
#   docker run [...] -v myinitdir:/initdata [...]
#
# Files in that directory will be deleted as they are consumed,
# unless the volume is mounted read-only (tack ":ro" at the end of
# the -v argument)

if [ -f /initdata/initdata.sql ]; then
    sqlite3 $sqlite_db < /initdata/initdata.sql
    rm /initdata/initdata.sql || true
fi

exec $manage_script runserver 0.0.0.0:80
