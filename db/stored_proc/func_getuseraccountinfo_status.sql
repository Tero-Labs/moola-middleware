CREATE OR REPLACE FUNCTION public.func_getuseraccountinfo_status(in_address character varying, in_currency character varying)
 RETURNS TABLE("healthFactor" numeric, "liquidationPrice" numeric, state text, "currentLTV" numeric, "maximumLTV" numeric, "liquidationThreshold" numeric, "CeloInterestRate" numeric, "cUSDInterestRate" numeric, "cEURInterestRate" numeric, "CelototalCollateral" numeric, "cUSDtotalCollateral" numeric, "cEURtotalCollateral" numeric, "CelototalDebt" numeric, "cUSDtotalDebt" numeric, "cEURtotalDebt" numeric, "currentPrice" numeric, "liquidationPenalty" numeric, "remainingDebt" numeric, "totalFeeCelo" numeric, "totalFeecUSD" numeric, "totalFeecEUR" numeric)
 LANGUAGE plpgsql
AS $function$
declare
celo_liquidation_threshold numeric;
ceuro_liquidation_threshold numeric;
cusd_liquidation_threshold numeric;

celo_deposited numeric;
ceuro_deposited numeric;
cusd_deposited numeric;

liquidation_price numeric;
totalliquidity_eth numeric;

celo_liquidationpenalty numeric;


--- 24th June 2021 --- Thrusday
celo_interest_rate numeric;
cusd_interest_rate numeric;
ceuro_interest_rate numeric;

--- 24th June 2021 --- Thrusday 
celo_total_collateral numeric;
cusd_total_collateral numeric;
ceuro_total_collateral numeric;

--- 24th June 2021 --- Thrusday
celo_total_debt numeric;
cusd_total_debt numeric;
ceuro_total_debt numeric;




---- ??? 
---- What is this celo_debt -- used somewhere
celo_debt numeric;

temp_health_factor numeric;

temp_currentPrice numeric;

health_state text;

--- 19th June 2021 --
temp_currentltv numeric;
temp_maximumltv numeric;
temp_liquidation_threshold numeric;

--- 2nd July 2021 - Friday ---
temp_remaining_debt numeric=0;
temp_total_fees_eth numeric=0;

BEGIN
	-- Created DateTime 4th June 2021 - Friday -- 
	-- Author: Mohammad Abdur Rahman --
	
	-- Function - Find the maximum value of supplied activityType=[deposit, withdraw, borrow, repay] on a address
	
	-- Required Tables -> tbl_user_account
	-- CORE SQL - 
	
	
	-- 1. Healthfactor-> tbl_user_account -> health_factor

	-- 2. Liquidation_price -> (deposited[for celo] * 0.8+deposited[cusd] * 0.8+deposited[ceuro] * 0.8)/total_liquidity_eth --- NOT used instead 1 / heath_factor
	-- we get total_liquidity_eth from tbl_user_account and deposited from tbl_user_reserve

	
---- These can be made into a single SQL via join -- in the future ---
	
	--- ===============================================================--------------------
	---- Get the liquidation thresholds ---
	--- liquidation_threshold=celo_liquidation_theshold
	
	--- [tbl_reserve_configuration]
	
	select  liquidation_threshold , liquidation_discount into celo_liquidation_threshold , celo_liquidationpenalty 
	from  tbl_reserve_configuration
	where coin_name='Celo' --and enabled=true 
	order by block_number desc limit 1;

   	select  liquidation_threshold into ceuro_liquidation_threshold
	from  tbl_reserve_configuration
	where coin_name='cEUR' --and enabled=true 
	order by block_number desc limit 1;

	select  liquidation_threshold into cusd_liquidation_threshold
	from  tbl_reserve_configuration
	where coin_name='cUSD' --and enabled=true 
	order by block_number desc limit 1;
----------------------------------------------------------------------------

	select ltv , liquidation_threshold into temp_maximumltv , temp_liquidation_threshold
	from tbl_reserve_configuration
	where coin_name = in_currency --and enabled=true 
	order by block_number desc limit 1;

--- ===============================================================--------------------
    --- [tbl_user_reserve]
	select deposited , debt into celo_deposited , celo_debt --- ??? debt ????
	from tbl_user_reserve
	where  address=in_address and coin_name ='Celo' --and enabled=true 
	order by block_number desc limit 1;


	select deposited into cusd_deposited
	from tbl_user_reserve
	where  address=in_address and coin_name ='cUSD' --and enabled=true 
	order by block_number desc limit 1;

	select deposited into ceuro_deposited
	from tbl_user_reserve
	where  address=in_address and coin_name ='cEUR' --and enabled=true 
	order by block_number desc limit 1;

	-------------------------------------------
    --[tbl_reserve]
	---- 2nd July 2021 Friday ---
	select variable_borrow_rate into celo_interest_rate
	from tbl_reserve
	where coin_name ='Celo' --and enabled=true 
	order by block_number desc limit 1;

	select variable_borrow_rate into cusd_interest_rate
	from tbl_reserve
	where coin_name ='cUSD' --and enabled=true 
	order by block_number desc limit 1;

	select variable_borrow_rate into ceuro_interest_rate
	from tbl_reserve
	where coin_name ='cEUR' --and enabled=true 
	order by block_number desc limit 1;
	----------------------------------------------------


--- =====================================================================================
--- total_liquidity_eth from tbl_user_account
	--- [tbl_user_account] ---

	select total_liquidity_eth , health_factor,
	total_collateral_eth , func_getexchange_rate_celo_to_x('cUSD', total_collateral_eth ) , func_getexchange_rate_celo_to_x('cEUR', total_collateral_eth ),
	total_borrows_eth , func_getexchange_rate_celo_to_x('cUSD', total_borrows_eth ) , func_getexchange_rate_celo_to_x('cEUR', total_borrows_eth ),
	total_fees_eth
	
	
	into totalliquidity_eth , temp_health_factor,
	
	celo_total_collateral , cusd_total_collateral , ceuro_total_collateral,
	celo_total_debt , cusd_total_debt , ceuro_total_debt ,
	temp_total_fees_eth
		
	from tbl_user_account
	where  address=in_address --and enabled=true 
	order by block_number desc limit 1;
--- =====================================================================================


	--- FIXED 10-07-21
	if temp_health_factor = 0 then
		liquidation_price = 0;
	else
		liquidation_price = 1 / temp_health_factor;
	end if;
	
	----------------------
	--- Retrieve current price
    --- usd exchange rate has no function ---
	-- for currentPrice in output parameter
	select usd_exchange_rate into temp_currentPrice
	from tbl_coin_exchange_rate 
	where coin_name = in_currency --and enabled=true
	order by block_number desc limit 1;


    if temp_health_factor < 1 then
		health_state = 'LIQUIDATED';
	elseif temp_health_factor between 1 and 1.25 then 
		health_state = 'RISKY';
	elseif temp_health_factor > 1.25 then
		health_state = 'HEALTHY';
	end if;	

   ---- 10 Jul 2021 - Satuday ---
    if celo_total_collateral = 0 then 
    	temp_currentltv = 0;
    
    elseif (celo_total_debt + temp_total_fees_eth) = 0 then
    	temp_currentltv = 0;
    
    else
    	temp_currentltv = ((celo_total_debt + temp_total_fees_eth ) / celo_total_collateral)*100;

    end if;
   
   
   
    --- *** =======================================================================
   
    --- 2nd July 2021 - Friday ---
    --- celo_total_debt 
    -- or celo_debt ?? 
    temp_remaining_debt = func_getexchange_rate_celo_to_x(in_currency,( celo_total_debt + temp_total_fees_eth ));
       
	return QUERY 
	------------------- Code Starts Here ---------------------
	
	--24/25 June 2021, temp_currentltv needs change - LOAN / Collateral * 100% - from existing db retrieval --- @@@

	-- temp_currentltv = total_borrows_eth / total_liquidity_eth*100
	-- temp_currentltv = celo_total_debt / totalliquidity_eth * 100;
	-- temp_currentltv --- @@@
	
	select temp_health_factor , liquidation_price , health_state , temp_currentltv , temp_maximumltv , temp_liquidation_threshold ,
	
	celo_interest_rate , cusd_interest_rate , ceuro_interest_rate ,
	
	celo_total_collateral , cusd_total_collateral , ceuro_total_collateral ,
	
	celo_total_debt , cusd_total_debt,ceuro_total_debt ,
	
	temp_currentPrice , celo_liquidationpenalty , temp_remaining_debt ,

	temp_total_fees_eth , func_getexchange_rate_celo_to_x('cUSD', temp_total_fees_eth ) ,func_getexchange_rate_celo_to_x('cEUR', temp_total_fees_eth );
	------------------- Code Ends Here ---------------------
	
END;
$function$
;

-- Permissions

ALTER FUNCTION public.func_getuseraccountinfo_status(varchar,varchar) OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON FUNCTION public.func_getuseraccountinfo_status(varchar,varchar) TO public;
GRANT ALL ON FUNCTION public.func_getuseraccountinfo_status(varchar,varchar) TO u5p3hgrt8h7nt4;


