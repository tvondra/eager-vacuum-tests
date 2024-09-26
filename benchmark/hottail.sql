\set delta random_gaussian(1000, 2000, 6)
BEGIN;

INSERT INTO hottail(client_id, quantity, description)
    VALUES (:client_id, 1, 'shoe')
    RETURNING id AS last_val \gset

INSERT INTO hottail(client_id, quantity, description)
    SELECT :client_id, 1, repeat(i::TEXT, 4)
    FROM generate_series(1,200) i;

UPDATE hottail
    SET quantity = quantity + 1,
        mtime = CURRENT_TIMESTAMP
    WHERE id =
    (SELECT id FROM hottail WHERE client_id = :client_id AND
        id > :last_val::bigint - :delta::bigint LIMIT 1);

END;
