FROM mohuk/jmeter:3.2

RUN wget -P /tmp/ "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2"
RUN tar -jxf /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2
ENV PATH "$PATH:/phantomjs-2.1.1-linux-x86_64/bin"

RUN wget -O /apache-jmeter-3.2/lib/cmdrunner-2.0.jar "http://search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/2.0/cmdrunner-2.0.jar"
RUN wget -O /apache-jmeter-3.2/lib/ext/jmeter-plugins-manager.jar "https://jmeter-plugins.org/get/"

RUN wget -O /tmp/tag-jmeter-extn.zip "http://www.testautomationguru.com/download/87/"
RUN unzip /tmp/tag-jmeter-extn.zip -d /apache-jmeter-3.2/lib/ext/

RUN java -cp /apache-jmeter-3.2/lib/ext/jmeter-plugins-manager.jar org.jmeterplugins.repository.PluginManagerCMDInstaller

RUN mkdir -p /cherryTests
WORKDIR /cherryTests
COPY ./tests/ /cherryTests/

RUN /apache-jmeter-3.2/bin/PluginsManagerCMD.sh install jpgc-webdriver,jpgc-json

CMD [ "-n", "-t", "Cherry.jmx", "-l", "testreport.jtl" ]

