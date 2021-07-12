CREATE OR REPLACE FUNCTION public.func_getuseraccountinfo_deposit(in_address character varying)
 RETURNS TABLE(currency character varying, amount numeric, interest numeric)
 LANGUAGE plpgsql
AS $function$
BEGIN
	-- Created DateTime 26th May 2021 - Monday -- 
	-- Author: Mohammad Abdur Rahman --
	
	-- Function - Find the maximum value of supplied activityType=[deposit, withdraw, borrow, repay] on a address
	
	-- Required Tables -> tbl_user_account
	-- CORE SQL - 
	

	return QUERY
	------------------- Code Starts Here ---------------------
	--- SQL should be stacked one where = 'celo' AND borrow <> 0 ORDER by creation_datetime DESC LIMIT 1 etc 
	--- Error occurs in replace(coin_name,'celo','CELO') --- 
	(select coin_name ,deposited,liquidity_rate 
	from tbl_user_reserve
	where address=in_address and coin_name = 'Celo' --and deposited <> 0
	--and enabled=true
	order by block_number desc limit 1)
	
	union
	
	(select coin_name,deposited,liquidity_rate
	from tbl_user_reserve
	where address=in_address and coin_name = 'cUSD'  --and deposited <> 0
	--and enabled=true
	order by block_number desc limit 1)
	
	union 
	
	(select coin_name ,deposited,liquidity_rate 
	from tbl_user_reserve
	where address=in_address and coin_name = 'cEUR'  --and deposited <> 0
	--and enabled=true
	order by block_number desc limit 1);
	------------------- Code Ends Here ---------------------
	
END;
$function$
;

-- Permissions

ALTER FUNCTION public.func_getuseraccountinfo_deposit(varchar) OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON FUNCTION public.func_getuseraccountinfo_deposit(varchar) TO public;
GRANT ALL ON FUNCTION public.func_getuseraccountinfo_deposit(varchar) TO u5p3hgrt8h7nt4;

