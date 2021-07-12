-- public.tbl_block_number definition

-- Drop table

-- DROP TABLE tbl_block_number;

CREATE TABLE tbl_block_number (
	id_block_number uuid NOT NULL DEFAULT uuid_generate_v1(),
	block_number numeric NULL,
	agent_id varchar(8) NULL,
	tag varchar(8) NULL,
	ip inet NULL,
	record_comment varchar(32) NULL,
	update_datetime timestamptz NULL,
	creation_datetime timestamptz NULL DEFAULT now(),
	enabled bool NULL DEFAULT true,
	CONSTRAINT tbl_block_number_pkey PRIMARY KEY (id_block_number)
);

-- Permissions

ALTER TABLE public.tbl_block_number OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON TABLE public.tbl_block_number TO u5p3hgrt8h7nt4;

