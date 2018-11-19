# Build runtime image
FROM microsoft/aspnetcore-build:2.0 

USER root
#==============
# VNC and Xvfb
#==============

RUN yum -y update
RUN yum -y  install wget xvfb unzip
#============================================
# Google Chrome
#============================================
RUN mkdir testAutomation

ADD https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm /root/google-chrome-stable_current_x86_64.rpm
#RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
#RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# Update the package list and install chrome
RUN  yum -y update; yum clean all
#RUN  yum -y install google-chrome-stable
RUN yum -y install /root/google-chrome-stable_current_x86_64.rpm; yum clean all

# Set up Chromedriver Environment variables
ENV CHROMEDRIVER_VERSION 2.19
ENV CHROMEDRIVER_DIR /testAutomation/chromedriver

RUN mkdir -p $CHROMEDRIVER_DIR
#RUN mkdir /testAutomation/chromedriver

# Download and install Chromedriver
RUN wget -q --continue -P $CHROMEDRIVER_DIR "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip"
RUN unzip $CHROMEDRIVER_DIR/chromedriver* -d $CHROMEDRIVER_DIR

#COPY chromedriver /
# Put Chromedriver into the PATH
ENV PATH $CHROMEDRIVER_DIR:$PATH

RUN rm -rf $CHROMEDRIVER_DIR/chromedriver*

COPY . ./
RUN dotnet publish --output /testAutomation/ --configuration Release
#COPY --from=builder /app /testAutomation
WORKDIR testAutomation

ENTRYPOINT ["dotnet", "vstest", "OpenshiftPlaftformServices.dll"]
