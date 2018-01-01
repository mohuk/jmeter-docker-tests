FROM mohuk/jmeter:3.2

RUN wget -P /tmp/ "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2"
RUN tar -jxf /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2
ENV PATH "$PATH:/phantomjs-2.1.1-linux-x86_64/bin"

RUN mkdir -p /home/cherry/
WORKDIR /home/cherry
COPY ./tests/ /home/cherry/

COPY ./jmeter-lib-dependencies/ /apache-jmeter-3.2/lib/

CMD [ "-n", "-t", "Cherry.jmx", "-l", "testreport.csv", "-e", "-o", "testfolder" ]
