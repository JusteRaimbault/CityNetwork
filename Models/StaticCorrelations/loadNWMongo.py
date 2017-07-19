import pymongo,json,sys

jsonfile = sys.argv[1]
database = sys.argv[2]
#mongohost = sys.argv[3]
mongohost = open('mongohost').readlines()[0].replace('\n','')

mongo = pymongo.MongoClient(mongohost)
db = mongo[database]
col = db['network']
col.delete_many({})

# read the json file
with open(jsonfile) as df:
    data = json.load(df)

# reformat the data
cldata=[]
i=0
for feature in data['features']:
    if i%100000==0 : print(i)
    currentrec = {}
    for prop in feature['properties'].keys():
        currentrec[prop] = feature['properties'][prop]
    currentrec['geometry']=feature['geometry']
    if currentrec['ORIGIN']!=currentrec['DESTINATIO']:
        cldata.append(currentrec)
    i=i+1

print("Inserting features...")
col.insert_many(cldata)

# create index
print("Creating spatial index...")
col.create_index([('geometry',pymongo.GEOSPHERE)])
