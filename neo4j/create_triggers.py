import neo4j
import argparse
import logging
import jinja2
from migrate_to_neo4j import Neo4jConnection
import os

SCRIPT_DIR_PATH = os.path.dirname(os.path.abspath(__file__))
TRIGGERS_DIR_PATH = os.path.join(SCRIPT_DIR_PATH, 'triggers')

def add_trigger_hospital(neo4j_conn : Neo4jConnection, j2_env : jinja2.Environment, database : str):
    # Load the template
    template = j2_env.get_template('trigger_hospital.cypher.j2')
    query = template.render(database=database)
    
    # Execute the query to add the trigger
    neo4j_conn.executeQuery(query)


def add_trigger_set_id(neo4j_conn : Neo4jConnection, j2_env : jinja2.Environment, database : str):
    # Load the template
    template = j2_env.get_template('trigger_set_id.cypher.j2')
    query = template.render(database=database)
    
    # Execute the query to add the trigger
    neo4j_conn.executeQuery(query)


def add_trigger_set_id_insurance(neo4j_conn : Neo4jConnection, j2_env : jinja2.Environment, database : str):
    # Load the template
    template = j2_env.get_template('trigger_set_id_insurance.cypher.j2')
    query = template.render(database=database)
    
    # Execute the query to add the trigger
    neo4j_conn.executeQuery(query)


def add_trigger_set_id_medical_history(neo4j_conn : Neo4jConnection, j2_env : jinja2.Environment, database : str):
    # Load the template
    template = j2_env.get_template('trigger_set_id_special.cypher.j2')
    query = template.render(database=database, trigger_name='medicalhistory_id_trigger', label='MedicalHistory', id_field='id_record')
    
    # Execute the query to add the trigger
    neo4j_conn.executeQuery(query)


def add_trigger_set_id_staff(neo4j_conn : Neo4jConnection, j2_env : jinja2.Environment, database : str):
    # Load the template
    template = j2_env.get_template('trigger_set_id_special.cypher.j2')
    query = template.render(database=database, trigger_name='staff_id_trigger', label='Staff', id_field='id_emp')
    
    # Execute the query to add the trigger
    neo4j_conn.executeQuery(query)


def add_trigger_set_id_lab_screening(neo4j_conn : Neo4jConnection, j2_env : jinja2.Environment, database : str):
    # Load the template
    template = j2_env.get_template('trigger_set_id_special.cypher.j2')
    query = template.render(database=database, trigger_name='labscreening_id_trigger', label='LabScreening', id_field='id_lab')
    
    # Execute the query to add the trigger
    neo4j_conn.executeQuery(query)


def add_triggers(neo4j_conn : Neo4jConnection, database : str):
    j2_env = jinja2.Environment(loader=jinja2.FileSystemLoader(searchpath=TRIGGERS_DIR_PATH))
    
    add_trigger_hospital(neo4j_conn, j2_env, database)
    add_trigger_set_id(neo4j_conn, j2_env, database)
    add_trigger_set_id_insurance(neo4j_conn, j2_env, database)
    add_trigger_set_id_medical_history(neo4j_conn, j2_env, database)
    add_trigger_set_id_staff(neo4j_conn, j2_env, database)
    add_trigger_set_id_lab_screening(neo4j_conn, j2_env, database)

def main():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('-nh', '--neo4j-host', help='Neo4j host', default='localhost', type=str)
    parser.add_argument('-np', '--neo4j-port', help='Neo4j port', default=7687, type=int)
    parser.add_argument('-nu', '--neo4j-user', help='Neo4j username', default='hospital', type=str)
    parser.add_argument('-npwd', '--neo4j-password', help='Neo4j password', default='hospital', type=str)
    parser.add_argument('-nd', '--neo4j-database', help='Neo4j database name', default='hospital', type=str)
    
    args = parser.parse_args()      # Para obter um dicionário: args = vars(parser.parse_args())
    
    logging.basicConfig(format="[%(asctime)s] - %(levelname)s - line %(lineno)d, in '%(funcName)s' - %(message)s\n\n")
    
    neo4j_conn = Neo4jConnection(args.neo4j_host, args.neo4j_port,
                                 args.neo4j_user, args.neo4j_password, 'system')
    
    add_triggers(neo4j_conn, args.neo4j_database)
    
    neo4j_conn.close()


if __name__ == '__main__':
    main()
    