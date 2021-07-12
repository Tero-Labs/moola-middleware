-- public.tbl_reserve definition

-- Drop table

-- DROP TABLE tbl_reserve;

CREATE TABLE tbl_reserve (
	id_reserve uuid NOT NULL DEFAULT uuid_generate_v1(),
	coin_name varchar(8) NOT NULL,
	total_liquidity numeric NOT NULL,
	available_liquidity numeric NOT NULL,
	total_borrows_stable numeric NULL,
	total_borrows_variable numeric NOT NULL,
	liquidity_rate numeric NOT NULL,
	variable_borrow_rate numeric NOT NULL,
	stable_borrow_rate numeric NOT NULL,
	average_stable_borrow_rate numeric NOT NULL,
	utilization_rate numeric NOT NULL,
	liquidity_index numeric NOT NULL,
	variable_borrow_index numeric NOT NULL,
	atoken_address varchar(40) NOT NULL,
	last_update timestamptz NULL,
	block_number int8 NOT NULL,
	agent_id varchar(8) NULL,
	tag varchar(8) NULL,
	ip inet NULL,
	record_comment varchar(32) NULL,
	update_datetime timestamptz NULL,
	creation_datetime timestamptz NULL DEFAULT now(),
	enabled bool NULL DEFAULT true,
	CONSTRAINT tbl_reserve_coin_name_block_number_key UNIQUE (coin_name, block_number),
	CONSTRAINT tbl_reserve_pkey PRIMARY KEY (id_reserve)
);

-- Permissions

ALTER TABLE public.tbl_reserve OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON TABLE public.tbl_reserve TO u5p3hgrt8h7nt4;
