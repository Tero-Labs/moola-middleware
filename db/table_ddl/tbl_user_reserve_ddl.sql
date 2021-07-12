-- public.tbl_user_reserve definition

-- Drop table

-- DROP TABLE tbl_user_reserve;

CREATE TABLE tbl_user_reserve (
	id_user_reserve uuid NOT NULL DEFAULT uuid_generate_v1(),
	coin_name varchar(8) NOT NULL,
	address varchar(40) NOT NULL,
	deposited numeric NULL,
	borrowed numeric NULL,
	debt numeric NULL,
	rate_mode varchar(8) NULL,
	borrow_rate numeric NULL,
	liquidity_rate numeric NOT NULL,
	origination_fee numeric NULL,
	borrow_index numeric NULL,
	last_update timestamptz NULL,
	is_collateral bool NULL,
	block_number int8 NOT NULL,
	agent_id varchar(8) NULL,
	tag varchar(8) NULL,
	ip inet NULL,
	record_comment varchar(32) NULL,
	update_datetime timestamptz NULL,
	creation_datetime timestamptz NULL DEFAULT now(),
	enabled bool NULL DEFAULT true,
	CONSTRAINT tbl_user_reserve_coin_name_block_number_address_key UNIQUE (coin_name, block_number, address),
	CONSTRAINT tbl_user_reserve_pkey PRIMARY KEY (id_user_reserve)
);
CREATE INDEX tbl_user_reserve_address_idx ON public.tbl_user_reserve USING btree (address);

-- Permissions

ALTER TABLE public.tbl_user_reserve OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON TABLE public.tbl_user_reserve TO u5p3hgrt8h7nt4;

