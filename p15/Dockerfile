FROM debian

COPY ./res/scr15pract.sh /opt/

RUN apt update -y && apt install wget -y && \
	apt install mc -y && apt install bc -y

WORKDIR /opt/

CMD ["sleep", "infinity"]


