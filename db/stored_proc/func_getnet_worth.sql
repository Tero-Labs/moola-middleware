CREATE OR REPLACE FUNCTION public.func_getnet_worth(in_address character varying)
 RETURNS TABLE(networth numeric)
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
	-- Total Colateral - Total Borrow
	(select (total_collateral_eth -  total_borrows_eth)
	from tbl_user_account
	where address=in_address -- and enabled=true
	order by  block_number desc limit 1);
	--order by  creation_datetime desc limit 1);
	
	------------------- Code Ends Here ---------------------
	
END;
$function$
;

-- Permissions

ALTER FUNCTION public.func_getnet_worth(varchar) OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON FUNCTION public.func_getnet_worth(varchar) TO public;
GRANT ALL ON FUNCTION public.func_getnet_worth(varchar) TO u5p3hgrt8h7nt4;
