#!/bin/bash
echo "Starting mongod and mongot"
docker compose up -d 
echo
sleep 10
echo "Initalizing the Replica Set"
mongosh --eval 'rs.initiate({})' \
     "mongodb://root:MzY0MzYyNmMtMjFkZS00Y2Q4LWEyNzQtNzVmZDdjOWU3NjA5@localhost:27778/?directConnection=true&authMechanism=DEFAULT"

echo
if ! [ -f sampledata.archive ]; then
  echo "Downloading sample data to file ./sampledata.archive"
  curl  https://atlas-education.s3.amazonaws.com/sampledata.archive -o sampledata.archive
fi
echo
echo "Running a mongorestore to populate the database"
mongorestore --drop --username root --password MzY0MzYyNmMtMjFkZS00Y2Q4LWEyNzQtNzVmZDdjOWU3NjA5 --archive=sampledata.archive --port=27778

echo Please use Compass or mongosh to connect to
echo mongodb://root:MzY0MzYyNmMtMjFkZS00Y2Q4LWEyNzQtNzVmZDdjOWU3NjA5@localhost:27778/?directConnection=true&authMechanism=DEFAULT

# mongosh --eval 'use sample_mflix' \
#         --eval 'db.movies.createSearchIndex("vectorSearchIndex01","vectorSearch", { fields: [{type: "knnVector", numDimensions: 1536, path: "plot_embedding", similarity: "cosine" }]})' \
#      "mongodb://root:MzY0MzYyNmMtMjFkZS00Y2Q4LWEyNzQtNzVmZDdjOWU3NjA5@localhost:27778/?directConnection=true&authMechanism=DEFAULT"

# {
#   "mappings": {
#     "dynamic": true,
#     "fields": {
#       plot_embedding: [
#         {
#           "type": "knnVector",
#           "dimensions": 1536,
#           "similarity": "euclidean"
#         }      
#       ]    
#     } 
#   }
# }