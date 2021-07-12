CREATE OR REPLACE FUNCTION public.func_getexchange_rate()
 RETURNS TABLE(celo_to_usd numeric, celo_to_cusd numeric, celo_to_ceuro numeric, cusd_to_usd numeric, cusd_to_celo numeric, cusd_to_ceuro numeric, ceuro_to_usd numeric, ceuro_to_celo numeric, ceuro_to_cusd numeric, usd_to_celo numeric, usd_to_cusd numeric, usd_to_ceuro numeric)
 LANGUAGE plpgsql
AS $function$
declare
--- Precedence - usd > celo > cusd > ceuro ?
BEGIN
	-- Created DateTime 31st May 2021 - Monday -- 
	-- Author: Mohammad Abdur Rahman --
	
	-- Function - 
	
	-- Required Tables -> tbl_user_account
	-- CORE SQL - 
	
    select usd_exchange_rate into celo_to_usd 
	from tbl_coin_exchange_rate 
	where coin_name = 'Celo' and enabled=true
	order by block_number desc limit 1;
	
	select usd_exchange_rate into cusd_to_usd 
	from tbl_coin_exchange_rate 
	where coin_name = 'cUSD' and enabled=true
	order by  block_number desc limit 1;

	select usd_exchange_rate into ceuro_to_usd 
	from tbl_coin_exchange_rate 
	where coin_name = 'cEUR' and enabled=true
	order by block_number desc limit 1;


	celo_to_cusd := celo_to_usd/cusd_to_usd;
	celo_to_ceuro := celo_to_usd/ceuro_to_usd;

    cusd_to_celo  := cusd_to_usd/celo_to_usd;
    cusd_to_ceuro := cusd_to_usd/ceuro_to_usd;
   
    ceuro_to_cusd := ceuro_to_usd/cusd_to_usd;
    ceuro_to_celo := ceuro_to_usd/celo_to_usd;
    
   	usd_to_celo := 1/celo_to_usd;
	usd_to_cusd := 1/cusd_to_usd;
	usd_to_ceuro := 1/ceuro_to_usd;
   
 	
	return QUERY
	------------------- Code Starts Here ---------------------
	(	
	select celo_to_usd,
	celo_to_cusd,
	celo_to_ceuro,

	cusd_to_usd,
	cusd_to_celo,
	cusd_to_ceuro,

	ceuro_to_usd,
    ceuro_to_celo,
    ceuro_to_cusd,

	usd_to_celo,
	usd_to_cusd,
	usd_to_ceuro
	);
	------------------- Code Ends Here ---------------------
	
END;
$function$
;

-- Permissions

ALTER FUNCTION public.func_getexchange_rate() OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON FUNCTION public.func_getexchange_rate() TO u5p3hgrt8h7nt4;

