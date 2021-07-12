from fastapi import FastAPI,Depends,Request
from typing import Optional

import datetime
import databases
import os

__version__ = '0.1.12'

DATABASE_URL = os.environ.get('WORKING_DATABASE_URL','')
database = databases.Database(DATABASE_URL)
print('DATABASE_URL=',DATABASE_URL)


ENABLE_ERROR_LOG_DUMP = os.environ.get('ENABLE_ERROR_LOG_DUMP','')
ENABLE_SUCCESS_LOG_DUMP = os.environ.get('ENABLE_SUCCESS_LOG_DUMP','')

app = FastAPI( title="Moola Middleware Downstream Server",
    description="To Serve blockchain Crawler Agents",
    version=__version__,)

@app.on_event("startup")
async def startup():
	await database.connect()

@app.on_event("shutdown")
async def shutdown():
	await database.disconnect()

# /get/info/about
@app.get("/get/info/about")
async def info_about():
	executionDateTime = datetime.datetime.now(datetime.timezone.utc).strftime("%m-%d-%Y %H:%M:%S.%f")

	return {'status':'OK',
			'dateTime':executionDateTime,
			'version':__version__
			}

# /get/info/list_table
@app.get("/get/info/list_table")
async def info_list_table():
	executionDateTime = datetime.datetime.now(datetime.timezone.utc).strftime("%m-%d-%Y %H:%M:%S.%f")
	
	table_schema_name = "'public'"
	query = f"SELECT table_name FROM information_schema.tables  WHERE table_schema={table_schema_name} AND table_type='BASE TABLE';"
	
	result = await database.fetch_all(query=query)

	return {'status':'OK',
			'dateTime':executionDateTime,
			'result':result
			}

# /get/agent_last_block?agent_id=0
@app.get("/get/agent_last_block")
async def get_agent_last_block(agent_id: str):

	executionDateTime = datetime.datetime.now(datetime.timezone.utc).strftime("%m-%d-%Y %H:%M:%S.%f")

	try:
		query = "select * from tbl_block_number WHERE agent_id=(:agent_ID) and enabled=True ORDER BY creation_DateTime DESC LIMIT 1;"
		values = {"agent_ID":agent_id}
		result = await database.fetch_one(query=query,values=values)

		return_dic = {'status':'OK',
					'dateTime':executionDateTime,
					'agent_id': result['agent_id'],
					'block_number':result['block_number'],
					'creation_datetime': result[ 'creation_datetime']
					}

	except Exception as e:
		# if error strikes
		return_dic = {'status':'ERROR',
				'detail':str(e),
				#'class':e.__class__
					}

	return return_dic

#/get/info/table_info/tbl_use
#/get/info/table_info/{table_name}
@app.get("/get/info/table_info/{table_name}")
async def info_table_info(table_name: str):

	executionDateTime = datetime.datetime.now(datetime.timezone.utc).strftime("%m-%d-%Y %H:%M:%S.%f")

	table_schema_name = "'public'"
	table_name_work = "'" + table_name + "'"

	query = f"SELECT column_name,data_type,character_maximum_length,numeric_precision,column_default,is_nullable \
	FROM information_schema.columns \
	WHERE table_schema = {table_schema_name} \
	AND table_name = {table_name_work};"

	result = await database.fetch_all(query=query)

	return {'status':'OK',
			'dateTime':executionDateTime,
			'table':table_name,
			'result':result
			}

# /get/info/unique_address
@app.get("/get/info/unique_address")
async def info_unique_address():

	executionDateTime = datetime.datetime.now(datetime.timezone.utc).strftime("%m-%d-%Y %H:%M:%S.%f")

	query = "SELECT DISTINCT address from tbl_user_account order by address asc;"
	result = await database.fetch_all(query=query)

	# convert the list[dict{'address':value}] to a simple list[] only
	# Better not to allocate runtime list - Should find a way to avoid this / alternative method
	new_result = []
	for row in result:
		new_result.append(row['address']) 

	return {'status':'OK',
			'dateTime':executionDateTime,
			#'data':result
			'data' : new_result
			}



#http://127.0.0.1:8000/set/insert/db_name/tbl_useraccount?totalliquidity=1.0774382328227146&totalcollateral=1.5890325336963706&totalborrow=0.6895725628848932&totalfees=0.1768456745853204&availableborrow=0.17936398586399241&loantovalue=71&liquidationthreshold=83&record_comment=0742PM
# Deliberate error
#http://127.0.0.1:8000/set/insert/db_name/tbl_useraccount?totalliquidity=1.0774382328227146&totalcollateral=1.5890325336963706&totalborrow=0.6895725628848932&totalfees=0.1768456745853204&availableborrow=0.17936398586399241&loantovalue=71&liquidationthreshold=83&record_commen=0742PM
@app.get("/set/insert/{db_name}/{table_name}")
async def set_insert(db_name: str,table_name: str,request: Request):
	# ---- Common options among all defs -------

	start_perf_timer = datetime.datetime.utcnow()
	executionDateTime = start_perf_timer.timestamp()

	client_host = request.client.host

	dictionary_values_input = dict(request.query_params)
	dictionary_values_input["ip"] = client_host
	dictionary_values_to_be_inserted = {}

	query_insert_part = f'INSERT INTO {table_name} ('
	query_value_part = ' VALUES (' 
	# ---- Input Query processing ---
	dic_max_count = len(dictionary_values_input)
	
	sc = 0

	Suffix_Identifier= '__Type'
	for key in dictionary_values_input:
		sc = sc + 1
		if key.endswith(Suffix_Identifier) == False: 
		
			if sc == dic_max_count:
				query_insert_part = query_insert_part + key + ')'
				query_value_part = query_value_part + ':' + key + ');'
			else:
				query_insert_part = query_insert_part + key + ','
				query_value_part = query_value_part + ':' + key + ','

			# Find the data descriptor 
			data_descriptor = key + Suffix_Identifier
			if data_descriptor in dictionary_values_input:
			
				### bool
				if dictionary_values_input[data_descriptor] =='bool':
					# bool - always returning True ???? -- Only returns False if data =   (No Data Supplied)
					dictionary_values_to_be_inserted[key] = bool(dictionary_values_input[key])
					
				elif dictionary_values_input[data_descriptor] =='int':
					try:
						dictionary_values_to_be_inserted[key] = int(dictionary_values_input[key])
					except ValueError:
						dictionary_values_to_be_inserted[key] = dictionary_values_input[key]
				
				### datetime - '%m-%d-%Y %H:%M:%S' - 05-15-2021 17:57:36
				elif dictionary_values_input[data_descriptor]=='datetime':
					date_time_Conversion_string = '%m-%d-%Y %H:%M:%S'
					# Check if the format is OK -
					try:
						dictionary_values_to_be_inserted[key] = datetime.datetime.strptime(dictionary_values_input[key],date_time_Conversion_string)
					except ValueError:
						dictionary_values_to_be_inserted[key] = dictionary_values_input[key]
					
				else:
					# For all other - leave it as it is 
					dictionary_values_to_be_inserted[key] = dictionary_values_input[key]
				
			else:
				dictionary_values_to_be_inserted[key] = dictionary_values_input[key]
			
	final_insert_sql = query_insert_part + query_value_part

	try:
		await database.execute(query=final_insert_sql,values=dictionary_values_to_be_inserted)

	except Exception as e:
			is_error_detected=True
			return_dic = {'status':'ERROR',
					'detail':str(e),
					#'class':e.__class__
					}
	else:
			is_error_detected=False
			return_dic = {'status':'OK',
			'dateTime':executionDateTime,
			'request':request.query_params
			}

	if (ENABLE_ERROR_LOG_DUMP=='1' and is_error_detected==True):
		await dump_upstream_access_log(start_perf_timer,request.url.path,str(request.url),str(request.query_params),str(return_dic),is_error_detected,request.client.host)

	if (ENABLE_SUCCESS_LOG_DUMP=='1' and is_error_detected==False):
		await dump_upstream_access_log(start_perf_timer,request.url.path,str(request.url),str(request.query_params),str(return_dic),is_error_detected,request.client.host)

	return return_dic
 
async def dump_upstream_access_log(start_perf_timer,base_url,in_string,in_parameter,out_string,is_error_detected,ip):

	time_delta =  (datetime.datetime.utcnow() - start_perf_timer).microseconds

	#insert_query = "INSERT INTO tbl_downstream_access_log(base_url,in_string,in_parameter,out_string,elapsed_time_performance_metrics,ip) VALUES (:base_url,:in_string,:in_parameter, :out_string,:elapsed_time_performance_metrics,:ip)"
	#insert_values = {'base_url': base_url, 'in_string':in_string,'in_parameter': in_parameter,'out_string': out_string,'ip':ip,'elapsed_time_performance_metrics': time_delta,'ip': ip}

	insert_query = "INSERT INTO tbl_downstream_access_log(base_url,in_string,in_parameter,out_string,elapsed_time_performance_metrics, is_error,ip) VALUES (:base_url,:in_string,:in_parameter, :out_string, :elapsed_time_performance_metrics, :is_error,:ip)"
	insert_values = {'base_url': base_url, 'in_string':in_string,'in_parameter': in_parameter,'out_string': out_string,'ip':ip,'elapsed_time_performance_metrics': time_delta, 'is_error': is_error_detected ,'ip': ip}

	try:
		await database.execute(query=insert_query, values=insert_values)

	except Exception as e:
		print('ERROR',str(e))