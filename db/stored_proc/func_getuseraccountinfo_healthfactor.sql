CREATE OR REPLACE FUNCTION public.func_getuseraccountinfo_healthfactor(in_address character varying, in_currency character varying)
 RETURNS TABLE(healthfactor numeric, liquidationprice numeric, state character varying)
 LANGUAGE plpgsql
AS $function$
declare

temp_health_factor numeric;
temp_liquidation_price numeric;

health_state character varying;

BEGIN
	-- Created DateTime 1st June 2021 - Tuesday -- 
	-- Author: Mohammad Abdur Rahman --
	
	-- Function - Find the maximum value of supplied activityType=[deposit, withdraw, borrow, repay] on a address
	
	-- Required Tables -> tbl_user_account
	-- CORE SQL - 
	
	

	--- HEALTH-FACTOR,LIQUIDATION-PRICE ---
	select health_factor into temp_health_factor 
	from tbl_user_account
	where address=in_address
	--and enabled=true
	order by block_number desc limit 1;

	
	--- FIXED liquidation_price 20-07-21
	if temp_health_factor = 0 then
		temp_liquidation_price = 0;
	else
		temp_liquidation_price = 1 / temp_health_factor;
	end if;

	
	if temp_health_factor < 1 then
		health_state = 'LIQUIDATED';
	elseif temp_health_factor between 1 and 1.25 then 
		health_state = 'RISKY';
	elseif temp_health_factor > 1.25 then
		health_state = 'HEALTHY';
	end if;	

	
	return QUERY 
	------------------- Code Starts Here ---------------------
	select temp_health_factor,temp_liquidation_price,health_state;
	------------------- Code Ends Here ---------------------
	
END;
$function$
;

-- Permissions

ALTER FUNCTION public.func_getuseraccountinfo_healthfactor(varchar,varchar) OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON FUNCTION public.func_getuseraccountinfo_healthfactor(varchar,varchar) TO public;
GRANT ALL ON FUNCTION public.func_getuseraccountinfo_healthfactor(varchar,varchar) TO u5p3hgrt8h7nt4;


