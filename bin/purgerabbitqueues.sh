rabbitmqadmin -f tsv -q list queues name | while read queue; do
  echo "Purging queue ${queue}"
  rabbitmqadmin purge queue name=${queue};
done

