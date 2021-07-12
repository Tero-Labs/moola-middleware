-- public.tbl_upstream_access_log definition

-- Drop table

-- DROP TABLE tbl_upstream_access_log;

CREATE TABLE tbl_upstream_access_log (
	id_upstream_access_log uuid NOT NULL DEFAULT uuid_generate_v1(),
	procedure_called_from varchar(64) NULL,
	base_url varchar(255) NULL,
	in_string varchar(2048) NULL,
	in_parameter varchar(2048) NULL,
	out_string varchar(2048) NULL,
	out_parameter varchar(2048) NULL,
	elapsed_time_performance_metrics numeric NULL,
	is_error bool NULL,
	tag varchar(8) NULL,
	ip inet NULL,
	record_comment varchar(32) NULL,
	update_datetime timestamptz NULL,
	creation_datetime timestamptz NULL DEFAULT now(),
	enabled bool NULL DEFAULT true,
	CONSTRAINT tbl_upstream_access_log_pkey PRIMARY KEY (id_upstream_access_log)
);

-- Permissions

ALTER TABLE public.tbl_upstream_access_log OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON TABLE public.tbl_upstream_access_log TO u5p3hgrt8h7nt4;
