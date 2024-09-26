DROP TABLE IF EXISTS hottail;
CREATE TABLE hottail (
    id BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    client_id BIGINT NOT NULL,
    quantity BIGINT NOT NULL,
    itime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    mtime TIMESTAMPTZ DEFAULT NULL,
    description TEXT)
    WITH (fillfactor=80);

CREATE INDEX ON hottail(id);
CREATE INDEX ON hottail(quantity);
CREATE INDEX ON hottail(client_id);
CREATE INDEX ON hottail(itime);
