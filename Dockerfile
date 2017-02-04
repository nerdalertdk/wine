FROM ubuntu:16.04
MAINTAINER Towel Software <www.towel.dk>

#ENV WINEDEBUG -all,err+all

USER root

# original script by Jan Suchotzki <jan@suchotzki.de>
# from https://github.com/suchja/wix-toolset/blob/master/waitonprocess.sh
RUN echo $'[ $# -lt 2 ] && echo "Usage: $0 USER PROCESS-NAMES..." >&2 && exit 1 \n\
USER="$1" \n\
shift \n\
echo "Started waiting for $@" \n\
while pgrep -u "$USER" "$@" > /dev/null; do \n\
	echo "waiting ..." \n\
	sleep 1; \n\
done \n\
echo "$@ completed"'\
>> /usr/local/bin/waitfor
RUN cat /usr/local/bin/waitfor
RUN chmod +x /usr/local/bin/waitfor
RUN which waitfor

RUN apt-get update --assume-yes
RUN apt-get install --no-install-recommends --assume-yes software-properties-common \
	&& add-apt-repository --yes ppa:ricotz/unstable
RUN apt-get purge --assume-yes software-properties-common
RUN dpkg --add-architecture i386
RUN apt-get update --assume-yes
RUN apt-get install --no-install-recommends --assume-yes \
		wine2.0 \
		curl \
		winetricks \
		cabextract \
		xvfb
RUN apt-mark manual \
		wine2.0 \
		curl \
		winetricks \
		cabextract \
		xvfb
RUN apt-get autoclean --assume-yes \
	&& apt-get autoremove --assume-yes

RUN curl -o /usr/local/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
RUN chmod +x /usr/local/bin/winetricks
RUN which winetricks

RUN groupadd --system xclient && useradd --create-home --system --gid xclient xclient

USER xclient
ENV HOME /home/xclient
ENV WINEPREFIX /home/xclient/.wine
ENV WINEARCH win64
WORKDIR /home/xclient
#RUN rm -rf /home/xclient/.wine
RUN wine wineboot --init && waitfor xclient wineserver && wine --version
#RUN xvfb-run -a winetricks --unattended corefonts && waitfor xclient wineserver
#RUN xvfb-run -a winetricks --unattended dotnet40 && waitfor xclient wineserver
RUN xvfb-run -a winetricks --unattended vcrun2010 && waitfor xclient wineserver
RUN ls -la /home/xclient/
ENTRYPOINT ["wine"]

