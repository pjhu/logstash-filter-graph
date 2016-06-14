FROM logstash:latest

COPY ./logstash-filter-graph-0.1.0.gem /
RUN cd /opt/logstash\
	&& bin/plugin install /logstash-filter-graph-0.1.0.gem \
	&& rm /logstash-filter-graph-0.1.0.gem
