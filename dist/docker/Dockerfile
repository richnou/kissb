#from alpine
#from archlinux
FROM opensuse/tumbleweed

#RUN apk add tcl bash

#RUN pacman-key --init
#RUN pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
#RUN pacman-key --lsign-key 3056513887B78AEB
#RUN pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
#RUN pacman -U --noconfirm  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
#RUN echo "[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
#RUN pacman -Sy
#RUN pacman -Sy --noconfirm tcl unzip git base-devel

#RUN git clone https://aur.archlinux.org/tcllib.git
#RUN cd tcllib && su nobody -c "makepkg -si" --non-interactive

RUN zypper addrepo https://download.opensuse.org/repositories/devel:languages:tcl/openSUSE_Tumbleweed/devel:languages:tcl.repo
RUN zypper --gpg-auto-import-keys --non-interactive refresh
RUN zypper --gpg-auto-import-keys --non-interactive install unzip  tcllib tclxml

COPY dist.zip .
RUN unzip dist.zip
RUN cp -Rf kissb-* /usr/lib64/tcl/kissb
RUN chmod +x /usr/lib64/tcl/kissb/bin/kissb
#RUN ln -s /etc/profile.d/color_prompt.sh.disabled /etc/profile.d/color_prompt.sh
#RUN echo "alias kissb=$(ls /usr/lib/tcl8.6/kissb-*/bin/kissb)" >> /etc/profile.d/99-kiss.sh
WORKDIR /cwd
#RUN ["/usr/lib/tcl8.6/kissb/bin/kissb"]
#ENTRYPOINT ["/bin/bash","-l","-c","/usr/lib/tcl8.6/kissb/bin/kissb"]
#ENTRYPOINT ["/bin/bash","-ilc","kissb"]

#CMD ["/bin/sh","-ilc","/usr/lib64/tcl/kissb/bin/kissb"]
ENTRYPOINT ["/usr/lib64/tcl/kissb/bin/kissb"]
