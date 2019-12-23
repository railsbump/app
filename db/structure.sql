SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: gemmies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gemmies (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: gemmies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gemmies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gemmies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gemmies_id_seq OWNED BY public.gemmies.id;


--
-- Name: rails_compatibilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rails_compatibilities (
    gemmy_id bigint,
    rails_releases_id bigint,
    compatible boolean
);


--
-- Name: rails_releases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rails_releases (
    id bigint NOT NULL,
    version character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: rails_releases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rails_releases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rails_releases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rails_releases_id_seq OWNED BY public.rails_releases.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: gemmies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gemmies ALTER COLUMN id SET DEFAULT nextval('public.gemmies_id_seq'::regclass);


--
-- Name: rails_releases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rails_releases ALTER COLUMN id SET DEFAULT nextval('public.rails_releases_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: gemmies gemmies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gemmies
    ADD CONSTRAINT gemmies_pkey PRIMARY KEY (id);


--
-- Name: rails_releases rails_releases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rails_releases
    ADD CONSTRAINT rails_releases_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: index_gemmies_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gemmies_on_name ON public.gemmies USING btree (name);


--
-- Name: index_rails_compatibilities_on_gemmy_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rails_compatibilities_on_gemmy_id ON public.rails_compatibilities USING btree (gemmy_id);


--
-- Name: index_rails_compatibilities_on_rails_releases_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rails_compatibilities_on_rails_releases_id ON public.rails_compatibilities USING btree (rails_releases_id);


--
-- Name: index_rails_releases_on_version; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_rails_releases_on_version ON public.rails_releases USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20191222065024'),
('20191222065443'),
('20191222070102');


