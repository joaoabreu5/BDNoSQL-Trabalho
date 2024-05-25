import neo4j.exceptions
import oracledb
import neo4j
import argparse
import logging

class OracleConnection():
    host : str
    port : int
    user : str
    password : str
    service_name : str
    connection : oracledb.Connection
    cursor : oracledb.Cursor
    
    def __init__(self, host='localhost', port=1521, user='', password='', service_name='XEPDB1'):
        self.host = host
        self.port = int(port)
        self.user = user
        self.password = password
        self.service_name = service_name
        self.addConnection()
        self.addCursor()
        
    def addConnection(self):
        self.connection = oracledb.connect(host=self.host, port=self.port, 
                                           user=self.user, password=self.password, service_name=self.service_name)
        
    def addCursor(self):
        self.cursor = self.connection.cursor()
        
    def executeQuery(self, query : str):
        self.cursor.execute(query)
        return self.cursor.fetchall()
    
    def executeSingletonQuery(self, query : str):
        self.cursor.execute(query)
        return self.cursor.fetchone()
        
    def close(self):
        self.cursor.close()
        self.connection.close()
    
       
class Neo4jConnection():
    host : str
    port : int
    user : str
    password : str
    database : str
    driver : neo4j.GraphDatabase
    session : neo4j.Session
    
    def __init__(self, host='localhost', port=7687, user='', password='', database=''):     
        self.host = host
        self.port = int(port)
        self.user = user
        self.password = password
        self.database = database
        self.addDriver()
        self.addSession()
        
    def addDriver(self):
        uri = f'bolt://{self.host}:{self.port}'
        self.driver = neo4j.GraphDatabase.driver(uri=uri, auth=(self.user, self.password))
    
    def addSession(self):
        session = self.driver.session()
        session.run(f'CREATE DATABASE {self.database} IF NOT EXISTS WAIT')
        session.close()
        self.session = self.driver.session(database=self.database)
    
    def executeQuery(self, query : str):
        return self.session.run(query)
    
    def close(self):
        self.session.close()
        self.driver.close()
    
    
def migrate(oracle_conn : OracleConnection, neo4j_conn : Neo4jConnection):
    # Exemplo de inserção em Neo4j
    neo4j_conn.executeQuery("""
        MERGE (m: Musica { id: 0, nome: 'Clocks' })
        MERGE (a: Autor { id: 0, nome: 'Coldplay' })
        WITH m, a
        MERGE (m) - [:ESCRITA_POR] -> (a)
    """)


def main():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('-oh', '--oracle-host', help='Oracle host', default='localhost', type=str)
    parser.add_argument('-op', '--oracle-port', help='Oracle port', default=1521, type=int)
    parser.add_argument('-ou', '--oracle-user', help='Oracle username', default='hospital', type=str)
    parser.add_argument('-opwd', '--oracle-password', help='Oracle password', default='hospital', type=str)
    parser.add_argument('-osn', '--oracle-service-name', help='Oracle service name', default='XEPDB1', type=str)
    
    parser.add_argument('-nh', '--neo4j-host', help='Neo4j host', default='localhost', type=str)
    parser.add_argument('-np', '--neo4j-port', help='Neo4j port', default=7687, type=int)
    parser.add_argument('-nu', '--neo4j-user', help='Neo4j username', default='hospital', type=str)
    parser.add_argument('-npwd', '--neo4j-password', help='Neo4j password', default='hospital', type=str)
    parser.add_argument('-nd', '--neo4j-database', help='Neo4j database name', default='hospital', type=str)
    
    args = parser.parse_args()      # Para obter um dicionário: args = vars(parser.parse_args())
    
    logging.basicConfig(format="[%(asctime)s] - %(levelname)s - line %(lineno)d, in '%(funcName)s' - %(message)s\n\n")
    
    oracle_conn = OracleConnection(args.oracle_host, args.oracle_port, 
                                   args.oracle_user, args.oracle_password, args.oracle_service_name)
    
    neo4j_conn = Neo4jConnection(args.neo4j_host, args.neo4j_port,
                                 args.neo4j_user, args.neo4j_password, args.neo4j_database)
    
    migrate(oracle_conn, neo4j_conn)
    
    oracle_conn.close()
    neo4j_conn.close()


if __name__ == '__main__':
    main()
    