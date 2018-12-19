FROM debian

COPY ./res/scr15lect.sh /opt/

RUN apt update -y && apt install wget -y && \
	apt install mc -y

WORKDIR /opt/

CMD ["sleep", "infinity"]

