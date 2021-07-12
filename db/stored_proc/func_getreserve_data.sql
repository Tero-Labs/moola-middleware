CREATE OR REPLACE FUNCTION public.func_getreserve_data()
 RETURNS TABLE(currency character varying, "totalDeposited" numeric, "availableLiquidity" numeric, "totalBorrowStable" numeric, "totalBorrowVariable" numeric, "stableBorrowAPR" numeric, "variableBorrowAPR" numeric, "utilizationRate" numeric, apy numeric)
 LANGUAGE plpgsql
AS $function$
BEGIN
	-- Created DateTime 26th May 2021 - Monday -- 
	-- Author: Mohammad Abdur Rahman --
	
	-- Function - Find the maximum value of supplied activityType=[deposit, withdraw, borrow, repay] on a address
	
	-- Required Tables -> tbl_reserve
	-- CORE SQL - 
	

	return QUERY
	------------------- Code Starts Here ---------------------
	(select coin_name, total_liquidity,
	available_liquidity ,total_borrows_stable,
	total_borrows_variable , stable_borrow_rate,
	variable_borrow_rate ,utilization_rate,
	liquidity_rate
    from tbl_reserve where coin_name = 'Celo' --and enabled=true 
    order by block_number DESC limit 1)
    
    union 
    
	(select coin_name, total_liquidity,
	available_liquidity ,total_borrows_stable,
	total_borrows_variable , stable_borrow_rate,
	variable_borrow_rate ,utilization_rate,
	liquidity_rate
    from tbl_reserve where coin_name = 'cUSD' --and enabled=true 
    order by block_number DESC limit 1)
    
    union 
    
    (select coin_name, total_liquidity,
	available_liquidity ,total_borrows_stable,
	total_borrows_variable , stable_borrow_rate,
	variable_borrow_rate ,utilization_rate,
	liquidity_rate
    from tbl_reserve where coin_name = 'cEUR' --and enabled=True 
    order by block_number DESC limit 1);
    
	------------------- Code Ends Here ---------------------
	
END;
$function$
;

-- Permissions

ALTER FUNCTION public.func_getreserve_data() OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON FUNCTION public.func_getreserve_data() TO public;
GRANT ALL ON FUNCTION public.func_getreserve_data() TO u5p3hgrt8h7nt4;

