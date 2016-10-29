FROM python:2.7
MAINTAINER STI-IT Dev <stiit-dev@groupes.epfl.ch>

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt -q install sqlite3 patch unzip

RUN easy_install pip
# As per doc/guide/cubesviewer-gui-installation.md, Django 1.9 required
# (excluding any later minor release - Been there, tried that)
RUN pip install django==1.9.10
RUN pip install django-piston django-utils djangorestframework requests django-cors-headers

ADD http://github.com/jjmontesl/cubesviewer-server/archive/v2.0.2.zip /
RUN cd /; unzip v2.0.2.zip
RUN mv /cubesviewer-server-2.0.2 /cubesviewer
ADD serialize.patch /cubesviewer
WORKDIR /cubesviewer
RUN patch -p1 < serialize.patch

# Persistent state (logins, saved queries) go into an sqlite database there:
VOLUME /cubesviewer/cvapp

ADD run.sh /run.sh
CMD [ "/run.sh" ]
