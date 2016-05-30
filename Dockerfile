FROM java:8-jdk

# based on https://github.com/fbascheper/SoapUI-MockService-Docker-image
RUN mkdir -p /opt/soapui && \
    apt-get -y install wget && apt-get -y install tar && \
    wget --no-check-certificate --no-cookies http://cdn01.downloads.smartbear.com/soapui/5.2.1/SoapUI-5.2.1-linux-bin.tar.gz && \
    echo "ba51c369cee1014319146474334fb4e1  SoapUI-5.2.1-linux-bin.tar.gz" >> MD5SUM && \
    md5sum -c MD5SUM && \
    tar -xzf SoapUI-5.2.1-linux-bin.tar.gz -C /opt/soapui && \
    rm -f SoapUI-5.2.1-linux-bin.tar.gz MD5SUM

RUN find /opt/soapui -type d -execdir chmod 770 {} \; && \
    find /opt/soapui -type f -execdir chmod 660 {} \;

RUN apt-get -y install curl && \
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-amd64" && \
    chmod +x /usr/local/bin/gosu

ENV HOME /opt/soapui
ENV SOAPUI_DIR /opt/soapui/SoapUI-5.2.1
ENV SOAPUI_PRJ /opt/soapui/projects
ENV PROJECT $SOAPUI_PRJ/default-soapui-project.xml
ENV PATH $PATH:$SOAPUI_DIR/bin
ENV MOCK_SERVICE_NAME BLZ-SOAP11-MockService

ADD soapui-prj $SOAPUI_PRJ

EXPOSE 8080

COPY docker-entrypoint.sh /
RUN chmod 700 /docker-entrypoint.sh && \
    chmod 770 $SOAPUI_DIR/bin/*.sh

WORKDIR $SOAPUI_DIR

CMD ["sh", "-c", "bin/mockservicerunner.sh -Djava.awt.headless=true -p 8080 -m $MOCK_SERVICE_NAME $PROJECT"]
