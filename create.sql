--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: generate_order_item_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_order_item_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if this order_id already has any order items
    IF NOT EXISTS (SELECT 1 FROM order_items WHERE order_id = NEW.order_id) THEN
        -- If no records exist for this order_id, set order_item_id to 1
        NEW.order_item_id := 1;
    ELSE
        -- If records already exist, find the maximum order_item_id for this order_id and increment it by 1
        NEW.order_item_id := COALESCE(
            (SELECT MAX(order_item_id) FROM order_items WHERE order_id = NEW.order_id) + 1,
            1
        );
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.generate_order_item_id() OWNER TO postgres;

--
-- Name: generate_order_payment_sequential(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_order_payment_sequential() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if this order_id already has any order items
    IF NOT EXISTS (SELECT 1 FROM order_payments WHERE order_id = NEW.order_id) THEN
        -- If no records exist for this order_id, set order_item_id to 1
        NEW.payment_sequential := 1;
    ELSE
        -- If records already exist, find the maximum order_item_id for this order_id and increment it by 1
        NEW.payment_sequential := COALESCE(
            (SELECT MAX(payment_sequential) FROM order_payments WHERE order_id = NEW.order_id) + 1,
            1
        );
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.generate_order_payment_sequential() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    customer_id text DEFAULT encode(public.digest(((random())::text || (clock_timestamp())::text), 'sha256'::text), 'hex'::text) NOT NULL,
    customer_unique_id text DEFAULT encode(public.digest(((random())::text || (clock_timestamp())::text), 'sha256'::text), 'hex'::text),
    geolocation_id text NOT NULL
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: geolocation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.geolocation (
    geolocation_zip_code_prefix integer,
    geolocation_city text,
    geolocation_state text,
    geolocation_id text DEFAULT encode(public.digest(((random())::text || (clock_timestamp())::text), 'sha256'::text), 'hex'::text) NOT NULL
);


ALTER TABLE public.geolocation OWNER TO postgres;

--
-- Name: geolocation_old; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.geolocation_old (
    geolocation_zip_code_prefix integer,
    geolocation_lat real,
    geolocation_lng real,
    geolocation_city text,
    geolocation_state text
);


ALTER TABLE public.geolocation_old OWNER TO postgres;

--
-- Name: leads_closed; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.leads_closed (
    mql_id text NOT NULL,
    seller_id text,
    sdr_id text,
    sr_id text,
    won_date text,
    business_segment text,
    lead_type text,
    lead_behaviour_profile text,
    has_company integer,
    has_gtin integer,
    average_stock text,
    business_type text,
    declared_product_catalog_size real,
    declared_monthly_revenue real
);


ALTER TABLE public.leads_closed OWNER TO postgres;

--
-- Name: leads_qualified; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.leads_qualified (
    mql_id text DEFAULT encode(public.digest(((random())::text || (clock_timestamp())::text), 'sha256'::text), 'hex'::text) NOT NULL,
    first_contact_date text,
    landing_page_id text,
    origin text
);


ALTER TABLE public.leads_qualified OWNER TO postgres;

--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    order_id text NOT NULL,
    order_item_id integer NOT NULL,
    product_id text,
    seller_id text,
    shipping_limit_date text,
    price real,
    freight_value real
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: order_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_payments (
    order_id text NOT NULL,
    payment_sequential integer NOT NULL,
    payment_type text,
    payment_installments integer,
    payment_value real
);


ALTER TABLE public.order_payments OWNER TO postgres;

--
-- Name: order_reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_reviews (
    review_id text NOT NULL,
    order_id text NOT NULL,
    review_score integer,
    review_comment_title text,
    review_comment_message text,
    review_creation_date text,
    review_answer_timestamp text
);


ALTER TABLE public.order_reviews OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id text NOT NULL,
    customer_id text,
    order_status text,
    order_purchase_timestamp text,
    order_approved_at text,
    order_delivered_carrier_date text,
    order_delivered_customer_date text,
    order_estimated_delivery_date text
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: product_category_name_translation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_category_name_translation (
    product_category_name text NOT NULL,
    product_category_name_english text
);


ALTER TABLE public.product_category_name_translation OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    product_id text NOT NULL,
    product_category_name text,
    product_name_lenght real,
    product_description_lenght real,
    product_photos_qty real,
    product_weight_g real,
    product_length_cm real,
    product_height_cm real,
    product_width_cm real
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: sellers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sellers (
    seller_id text NOT NULL,
    geolocation_id text NOT NULL
);


ALTER TABLE public.sellers OWNER TO postgres;

--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: geolocation geolocation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.geolocation
    ADD CONSTRAINT geolocation_pkey PRIMARY KEY (geolocation_id);


--
-- Name: leads_closed leads_closed_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leads_closed
    ADD CONSTRAINT leads_closed_pkey PRIMARY KEY (mql_id);


--
-- Name: leads_qualified leads_qualified_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leads_qualified
    ADD CONSTRAINT leads_qualified_pkey PRIMARY KEY (mql_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: order_items pk_order_items; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id);


--
-- Name: order_payments pk_order_payments; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_payments
    ADD CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_sequential);


--
-- Name: order_reviews pk_order_reviews; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT pk_order_reviews PRIMARY KEY (order_id, review_id);


--
-- Name: product_category_name_translation product_category_name_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category_name_translation
    ADD CONSTRAINT product_category_name_translation_pkey PRIMARY KEY (product_category_name);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: sellers sellers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_pkey PRIMARY KEY (seller_id);


--
-- Name: customers_customer_unique_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX customers_customer_unique_id_idx ON public.customers USING btree (customer_unique_id);


--
-- Name: geolocation_geolocation_city_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX geolocation_geolocation_city_idx ON public.geolocation USING btree (geolocation_city);


--
-- Name: orders_customer_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX orders_customer_id_idx ON public.orders USING btree (customer_id);


--
-- Name: orders_order_purchase_timestamp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX orders_order_purchase_timestamp_idx ON public.orders USING btree (order_purchase_timestamp);


--
-- Name: order_items set_order_item_id; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_order_item_id BEFORE INSERT ON public.order_items FOR EACH ROW EXECUTE FUNCTION public.generate_order_item_id();


--
-- Name: order_payments set_order_payment_sequential; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_order_payment_sequential BEFORE INSERT ON public.order_payments FOR EACH ROW EXECUTE FUNCTION public.generate_order_payment_sequential();


--
-- Name: customers fk_customers_geolocation; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT fk_customers_geolocation FOREIGN KEY (geolocation_id) REFERENCES public.geolocation(geolocation_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: orders fk_customers_orders; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_customers_orders FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: leads_closed fk_leads_closed_qualified; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leads_closed
    ADD CONSTRAINT fk_leads_closed_qualified FOREIGN KEY (mql_id) REFERENCES public.leads_qualified(mql_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: leads_closed fk_leads_closed_sellers; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leads_closed
    ADD CONSTRAINT fk_leads_closed_sellers FOREIGN KEY (seller_id) REFERENCES public.sellers(seller_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: order_items fk_order_items_orders; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_items_orders FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: order_items fk_order_items_products; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_items_products FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: order_payments fk_order_payments_orders; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_payments
    ADD CONSTRAINT fk_order_payments_orders FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: order_reviews fk_order_reviews_orders; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT fk_order_reviews_orders FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: products fk_products_product_categories; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_products_product_categories FOREIGN KEY (product_category_name) REFERENCES public.product_category_name_translation(product_category_name) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sellers fk_sellers_geolocation; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT fk_sellers_geolocation FOREIGN KEY (geolocation_id) REFERENCES public.geolocation(geolocation_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: order_items fk_sellers_order_items; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_sellers_order_items FOREIGN KEY (seller_id) REFERENCES public.sellers(seller_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

