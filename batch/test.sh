# This is not a real test suite, just a lazy convenience when developing

echo "#### building the batch job"
echo
docker build -t rgardler/acs-logging-test-batch:test .

echo
echo "#### running 2 batch jobs"
echo
id=$(docker run -d --env-file ../env.conf rgardler/acs-logging-test-batch:test)
id2=$(docker run -d --env-file ../env.conf rgardler/acs-logging-test-batch:test)

echo
echo "#### docker ps output"
echo
docker ps

echo
echo "#### stop batch jobs"
echo
docker stop $id
docker stop $id2

echo
echo "####  output batch logs"
echo
docker logs $id
docker logs $id2
