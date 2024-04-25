import pymongo
from faker import Faker

# Set up Faker instance
fake = Faker()

# Set up connection to MongoDB
client = pymongo.MongoClient('mongodb://localhost:27017/')
db = client['mydatabase']
collection = db[fake.city()]

# Generate 100,000 random documents and insert them into the collection
for i in range(100000):
    document = {
        'name': fake.name(),
        'email': fake.email(),
        'address': {'street': fake.street_address(), 'city': fake.city(), 'state': fake.state_abbr(), 'zip': fake.zipcode()},
        'phone': fake.phone_number(),
    }
    collection.insert_one(document)

# Close the client
client.close()
