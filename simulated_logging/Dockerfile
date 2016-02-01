FROM rgardler/acs-logging-test-base:tr22

RUN pip install requests

COPY src src

CMD [ "python", "src/simulatedLogs.py" ]