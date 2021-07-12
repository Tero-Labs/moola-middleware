CREATE OR REPLACE FUNCTION public.func_getuseraccountinfo_activity(in_address character varying, in_currency character varying)
 RETURNS TABLE(type character varying, source character varying, "healthFactor" numeric, "liquidationPrice" numeric, "amountOfDebtRepaid" numeric, "amountOfDebtRepaidValue" numeric, "liquidatorClaimed" numeric, "liquidatorClaimedValue" numeric, currency character varying, amount numeric, value numeric, "timestamp" double precision, status text, "transactionId" character varying)
 LANGUAGE plpgsql
AS $function$
declare

---temp_health_factor numeric;
out_health_factor numeric :=0;
BEGIN
	-- Created DateTime 27th May 2021 - Thrusday -- 
	-- Author: Mohammad Abdur Rahman --
	
	-- Function - Find the maximum value of supplied activityType=[deposit, withdraw, borrow, repay] on a address
	
	-- Required Tables -> tbl_user_account
	-- CORE SQL - 
	
	----- Todo 
	----- ### Health Factor ### ----- DONE 
	--- 1. health_factor: -
	--- if action== 'liquidate':
	--- health factor from db

	--- if action == 'borrow' or 'repay':
	--- health_factor = 1 / liquidation_base_price (need to check division by zero)

	---------------------------------
	
	----- Paganation 
	
	return QUERY 
	------------------- Code Starts Here ---------------------
	
	(
	select activity_type, -- "type" 
	address, -- first 20 bytes ???? --- Was set to hardcored 'unkown'; before'
	--health_factor, -- "healthFactor"
	--- # # --- 
	CASE
          WHEN activity_type = 'liquidate' THEN
               health_factor
          WHEN ((activity_type='borrow' or activity_type='repay') and  (liquidation_price_base <> 0 )) THEN
    	   		1 / liquidation_price_base 
          else 
           	    0
    END ,
	--- # # ---
	func_getexchange_rate_celo_to_x_nearest_past(in_currency,liquidation_price_base,block_number),-- "liquidationPrice" --- The source field may be any of the above
	amount_of_debt_repaid, -- "amountOfDebtRepaid"
	func_getexchange_rate_celo_to_x_nearest_past(in_currency,amount_of_debt_repaid,block_number), -- "amountOfDebtRepaidValue"
	(tbl_user_activity.amount), --- liquidatorClaimed -- same as out_amount/amount in 'liquidate' action/event
	func_getexchange_rate_celo_to_x_nearest_past(in_currency,tbl_user_activity.amount,block_number), --- liquidatorClaimedValue -- same as value in 'liquidate' action/event
	coin_name, -- "currency"
	(tbl_user_activity.amount) as out_amount, -- "amount" 
	func_getexchange_rate_celo_to_x_nearest_past(in_currency,tbl_user_activity.amount,block_number), -- "value" 
	date_part('epoch', tx_timestamp) as tx_tmstamp , -- "timestamp"
	'', -- "status"
	tx_hash -- "transactionId"
	
	from tbl_user_activity
	where address=in_address
	and coin_name='Celo'
	--and enabled=true
	--order by tx_timestamp desc
	)

	union
	
	(

	select  activity_type, -- "type"
	address, --- first 20 bytes ???? --  was set to harccore 'unknown' before
	--health_factor, -- "healthFactor"
	--- # # ---
    CASE
          WHEN activity_type = 'liquidate' THEN
               health_factor
          WHEN ((activity_type='borrow' or activity_type='repay') and  (liquidation_price_base <> 0 )) THEN
          		1 / liquidation_price_base 
          else 
    	   	    0
    END ,
	--- # # ---
	func_getexchange_rate_cusd_to_x_nearest_past(in_currency,liquidation_price_base,block_number),-- "liquidationPrice" --- The source field may be any of the above
	amount_of_debt_repaid, -- "amountOfDebtRepaid"
	func_getexchange_rate_cusd_to_x_nearest_past(in_currency,amount_of_debt_repaid,block_number), -- "amountOfDebtRepaidValue"
	(tbl_user_activity.amount), --- liquidatorClaimed -- same as out_amount/amount in 'liquidate' action/event
	func_getexchange_rate_cusd_to_x_nearest_past(in_currency,tbl_user_activity.amount,block_number), --- liquidatorClaimedValue -- same as value in 'liquidate' action/event
	coin_name, -- "currency"
	(tbl_user_activity.amount) as out_amount, -- "amount" 
	func_getexchange_rate_cusd_to_x_nearest_past(in_currency,tbl_user_activity.amount,block_number), -- "value" 
	date_part('epoch', tx_timestamp) as tx_tmstamp , -- "timestamp"
	'', -- "status"
	tx_hash -- "transactionId"
	
	from tbl_user_activity
	where address=in_address
	and coin_name='cUSD'
	--and enabled=true
	--order by tx_timestamp desc
	)
	
	union
	
	(
	select activity_type, -- type
	address, --- first 20 bytes ???? was set to harccore 'unknown' before
	--health_factor, -- "healthFactor"
	--- # # ---
    CASE
          WHEN activity_type = 'liquidate' THEN
               health_factor
          WHEN ((activity_type='borrow' or activity_type='repay') and  (liquidation_price_base <> 0 )) THEN
          		1 / liquidation_price_base 
          else 
          	    0
    END ,
	--- # # ---
	func_getexchange_rate_ceur_to_x_nearest_past(in_currency,liquidation_price_base,block_number),-- "liquidationPrice" --- The source field may be any of the above
	amount_of_debt_repaid, -- "amountOfDebtRepaid"
	func_getexchange_rate_ceur_to_x_nearest_past(in_currency,amount_of_debt_repaid,block_number), -- "amountOfDebtRepaidValue"
	(tbl_user_activity.amount), --- liquidatorClaimed -- same as out_amount/amount in 'liquidate' action/event
	func_getexchange_rate_ceur_to_x_nearest_past(in_currency,tbl_user_activity.amount,block_number), --- liquidatorClaimedValue -- same as value in 'liquidate' action/event
	coin_name, -- "currency"
	(tbl_user_activity.amount) as out_amount, -- "amount" 
	func_getexchange_rate_ceur_to_x_nearest_past(in_currency,tbl_user_activity.amount,block_number), -- "value" 
	date_part('epoch', tx_timestamp) as tx_tmstamp , -- "timestamp"
	'', -- "status"
	tx_hash -- "transactionId"
	
	from tbl_user_activity
	where address=in_address
	and coin_name='cEUR' --- There is no 'cEUR' in DB
	--and enabled=true
	--order by tx_timestamp desc
		
	) order by tx_tmstamp desc;
	--) order by block_number desc;

	------------------- Code Ends Here ---------------------
	
END;
$function$
;

-- Permissions

ALTER FUNCTION public.func_getuseraccountinfo_activity(varchar,varchar) OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON FUNCTION public.func_getuseraccountinfo_activity(varchar,varchar) TO public;
GRANT ALL ON FUNCTION public.func_getuseraccountinfo_activity(varchar,varchar) TO u5p3hgrt8h7nt4;

