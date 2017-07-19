import pymongo,json,sys

jsonfile = sys.argv[1]
database = sys.argv[2]
#mongohost = sys.argv[3]
mongohost = open('mongohost').readlines()[0].replace('\n','')

mongo = pymongo.MongoClient(mongohost)
db = mongo[database]
col = db['network']

# read the json file
with open(jsonfile) as df:
    data = json.load(df)

# reformat the data
cldata=[]
for feature in data['features']:
    currentrec = {}
    for prop in feature['properties'].names():
        currentrec[prop] = feature['properties'][prop]
    currentrec['geometry']=feature['geometry']
    cldata.append(currentrec)

print("Inserting features...")
col.insert_many(currentrec)

# create index
print("Creating spatial index...")
col.create_index({'geometry':'2dsphere'})
