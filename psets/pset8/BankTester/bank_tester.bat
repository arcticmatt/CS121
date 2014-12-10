@echo off

java -Djdbc.drivers=com.mysql.jdbc.Driver -jar banktester.jar -v %*

