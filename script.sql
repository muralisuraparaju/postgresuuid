-- ADD UUID extension
ALTER ROLE postgres SUPERUSER;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--
-- We will create two tables: books and employees
-- Primary key of books table is UUID. 
-- Primary key of employees table is numeric (SERIAL)

CREATE TABLE books (
  id              uuid DEFAULT uuid_generate_v4 (),
  title           VARCHAR(100) NOT NULL,
  primary_author  VARCHAR(100) NULL,
  PRIMARY KEY (id)
);

CREATE TABLE employees (
  id             SERIAL,
  name           VARCHAR(100) NOT NULL,
  location       VARCHAR(100) NULL,
  PRIMARY KEY (id)	
);

CREATE TABLE address (
	id VARCHAR(100),
	city VARCHAR(100),
	state VARCHAR(100),
	PRIMARY KEY (id)
);
--
-- Create three procedures to INSERT data. These procedures take the number of rows to be inserted as input
CREATE PROCEDURE insert_books_data(recs INTEGER)
LANGUAGE plpgsql AS
$$
DECLARE 
	book_title VARCHAR;
	book_desc VARCHAR;

BEGIN
	for i in 1..recs LOOP
		SELECT CONCAT('title_' ,i) INTO book_title;
		SELECT CONCAT('desc_' ,i) INTO book_desc;
		INSERT INTO books (title, primary_author) VALUES (book_title, book_desc);
	END LOOP;
END
$$;
---
CREATE PROCEDURE insert_employees_data(recs INTEGER)
LANGUAGE plpgsql AS
$$
DECLARE 
	emp_name VARCHAR;
	emp_location VARCHAR;

BEGIN
	for i in 1..recs LOOP
		SELECT CONCAT('emp_name_' ,i) INTO emp_name;
		SELECT CONCAT('emp_loc_' ,i) INTO emp_location;
		INSERT INTO employees (name, location) VALUES (emp_name, emp_location);
	END LOOP;
END
$$;
--
CREATE PROCEDURE insert_address_data(recs INTEGER)
LANGUAGE plpgsql AS
$$
DECLARE 
    address_id VARCHAR;
	address_city VARCHAR;
	address_state VARCHAR;

BEGIN
	for i in 1..recs LOOP
		SELECT CONCAT('id0000-1234545-98756453-00' ,i) INTO address_id;
		SELECT CONCAT('city_' ,i) INTO address_city;
		SELECT CONCAT('state_' ,i) INTO address_state;
		INSERT INTO address (id, city, state) VALUES (address_id, address_city, address_state);
		IF i % 10000 = 0 THEN
			COMMIT;
		END IF;
	END LOOP;
END
$$;
--
-- INSERT 100K records in each table. Record the time from pgAdmin
CALL insert_books_data(100000);
CALL insert_employees_data(100000);
CALL insert_employees_data(100000);

--
-- Perform a SELECT and check the timing using EXPLAIN
-- replace the value of id with any random value from the tables which can be fetched using:
-- SELECT id FROM books LIMIT 100;
-- SELECT id FROM employees LIMIT 100;

EXPLAIN (FORMAT JSON, ANALYZE, TIMING, BUFFERS TRUE, VERBOSE TRUE) SELECT * FROM books WHERE id='2f5a8a79-f8f6-4e69-94aa-637bf4bb3271';
EXPLAIN (FORMAT JSON, ANALYZE, TIMING, BUFFERS TRUE, VERBOSE TRUE) SELECT * FROM employees WHERE id=1345;
EXPLAIN (FORMAT JSON, ANALYZE, TIMING, BUFFERS TRUE, VERBOSE TRUE) SELECT * FROM address WHERE id='';
