
-- Schema for simplified network database


-- Enable postgis
CREATE EXTENSION postgis;


-- Create table
CREATE TABLE links (
  origin BIGINT,
  destination BIGINT,
  length REAL,
  speed REAL,
  roadtype VARCHAR(10),
  geography GEOGRAPHY(LINESTRING,4326)
);


-- unique index on multiple comumns
CREATE UNIQUE INDEX unique_idx ON links (origin,destination,roadtype);

-- Spatial index
CREATE INDEX links_gix ON links USING GIST (geography);

