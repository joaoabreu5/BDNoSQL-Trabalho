import oracledb
import pymongo
import argparse

class OracleConnection():
    host : str
    port : int
    user : str
    password : str
    service_name : str
    
    def __init__(self, host='localhost', port=1521, user='', password='', service_name='XEPDB1'):
        self.host = host
        self.port = int(port)
        self.user = user
        self.password = password
        self.service_name = service_name
        
    def getConnection(self):
        return oracledb.connect(host=self.host, port=self.port, 
                                user=self.user, password=self.password, service_name=self.service_name)
    
    
class MongoDBConnection():
    host : str
    port : int
    user : str
    password : str
    database : str
    
    def __init__(self, host='localhost', port=27017, user='', password='', database=''):     
        self.host = host
        self.port = int(port)
        self.user = user
        self.password = password
        self.database = database
        
    def getClient(self):
        return pymongo.MongoClient(host=self.host, port=self.port, 
                                   username=self.user, password=self.password, connect=True)
        
    def getDatabase(self, client : pymongo.MongoClient):
        return client.get_database(name=self.database)
    
    def getClientAndDatabase(self):
        client = self.getClient()
        database = self.getDatabase(client)
        return client, database
        
        
def migrate(oracleConnectObj : OracleConnection, mongodbConnectObj : MongoDBConnection):
    try:
        oracleConnection = oracleConnectObj.getConnection()

        cursor = oracleConnection.cursor()
        
        cursor.execute('SELECT * FROM BILL')
        result = cursor.fetchall()
        print(result)
    
    finally:
        cursor.close()
        oracleConnection.close()
    
    
    try:
        mongoClient, mongoDatabase = mongodbConnectObj.getClientAndDatabase()
        
        mongoCollection = mongoDatabase['colecao_teste']
        
        data = [{'a': 1, 'b': 'teste'}, {'a': 2, 'c': 12.6}]
        mongoCollection.insert_many(data)
    
    finally:
        mongoClient.close()


def main():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('-oh', '--oracle-host', help='Oracle host', default='localhost', type=str)
    parser.add_argument('-op', '--oracle-port', help='Oracle port', default=1521, type=int)
    parser.add_argument('-ou', '--oracle-user', help='Oracle username', default='hospital', type=str)
    parser.add_argument('-opwd', '--oracle-password', help='Oracle password', default='hospital', type=str)
    parser.add_argument('-osn', '--oracle-service-name', help='Oracle service name', default='XEPDB1', type=str)
    
    parser.add_argument('-mh', '--mongodb-host', help='MongoDB host', default='localhost', type=str)
    parser.add_argument('-mp', '--mongodb-port', help='MongoDB port', default=27017, type=int)
    parser.add_argument('-mu', '--mongodb-user', help='MongoDB username', default='', type=str)
    parser.add_argument('-mpwd', '--mongodb-password', help='MongoDB password', default='', type=str)
    parser.add_argument('-md', '--mongodb-database', help='MongoDB database name', default='hospital', type=str)
    
    args = vars(parser.parse_args())
    
    oracle_conn = OracleConnection(args['oracle_host'], args['oracle_port'], 
                                   args['oracle_user'], args['oracle_password'], args['oracle_service_name'])
    
    mongodb_conn = MongoDBConnection(args['mongodb_host'], args['mongodb_port'], 
                                     args['mongodb_user'], args['mongodb_password'], args['mongodb_database'])
    
    migrate(oracle_conn, mongodb_conn)


if __name__ == '__main__':
    main()
    