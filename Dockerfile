FROM mohuk/jmeter:3.2

RUN wget -P /tmp/ "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2"
RUN tar -jxf /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2
ENV PATH "$PATH:/phantomjs-2.1.1-linux-x86_64/bin"

RUN wget -O /apache-jmeter-3.2/lib/cmdrunner-2.0.jar "http://search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/2.0/cmdrunner-2.0.jar"
RUN wget -O /apache-jmeter-3.2/lib/ext/jmeter-plugins-manager.jar "https://jmeter-plugins.org/get/"

RUN java -cp /apache-jmeter-3.2/lib/ext/jmeter-plugins-manager.jar org.jmeterplugins.repository.PluginManagerCMDInstaller

RUN mkdir -p /home/cherry/
WORKDIR /home/cherry
COPY ./tests/ /home/cherry/

RUN /apache-jmeter-3.2/bin/PluginsManagerCMD.sh install-for-jmx /home/cherry/Cherry.jmx

#COPY ./jmeter-lib-dependencies/ /apache-jmeter-3.2/lib/
#COPY ./jmeter-lib-dependencies/ext/jmeter-plugins-webdriver-1.4.0.jar /apache-jmeter-3.2/lib/ext/jmeter-plugins-webdriver-1.4.0.jar
COPY ./jmeter-lib-dependencies/ext/tag-jmeter-extn-1.1.jar /apache-jmeter-3.2/lib/ext/tag-jmeter-extn-1.1.jar

#CMD [ "-n", "-t", "Cherry.jmx", "-l", "testreport.jtl" ]
#CMD [ "-n", "-t", "Cherry.jmx", "-l", "testreport.csv", "-e", "-o", "testfolder" ]


#ENTRYPOINT ["sh"]