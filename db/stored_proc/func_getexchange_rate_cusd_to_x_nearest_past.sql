CREATE OR REPLACE FUNCTION public.func_getexchange_rate_cusd_to_x_nearest_past(in_currency_convert_to_type character varying, in_value numeric, in_block_no numeric)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
declare
--- Precedence - usd > celo > cusd > ceuro ?
converted_exchange_base_rate numeric:=1;
-- value_out numeric;
BEGIN
	-- Created DateTime 5th June 2021 -  - 
	-- Author: Mohammad Abdur Rahman --
	
	-- Function - 
	
	-- Required Tables -> 
	-- CORE SQL - 
	
	--- Possible Currency Type Strings - 
	---	"cUSD" , "Celo"[X],  "cEUR" 
	
	if in_currency_convert_to_type = 'Celo' then
	
	    select celo_exchange_rate into converted_exchange_base_rate
		from tbl_coin_exchange_rate 
		where coin_name = 'cUSD' --and enabled=true
		-- order by abs(block_number - in_block_no) desc limit 1; -- Timeout occurs ???
		order by block_number desc limit 1;
	
	elseif in_currency_convert_to_type = 'cEUR' then
		
		select ceuro_exchange_rate into converted_exchange_base_rate
		from tbl_coin_exchange_rate 
		where coin_name = 'cUSD' --and enabled=true
		-- order by abs(block_number - in_block_no) desc limit 1; -- Timeout occurs ???
		order by block_number desc limit 1;
	
	elseif in_currency_convert_to_type = 'cUSD' then
		
		converted_exchange_base_rate := 1;
	
	end if;
	
	return converted_exchange_base_rate * in_value;
	
END;
$function$
;

-- Permissions

ALTER FUNCTION public.func_getexchange_rate_cusd_to_x_nearest_past(varchar,numeric,numeric) OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON FUNCTION public.func_getexchange_rate_cusd_to_x_nearest_past(varchar,numeric,numeric) TO u5p3hgrt8h7nt4;
