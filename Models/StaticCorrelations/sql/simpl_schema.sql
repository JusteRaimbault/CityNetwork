
-- Schema for simplified network database


-- Enable postgis
CREATE EXTENSION postgis;


-- Create table
CREATE TABLE links (
  id VARCHAR(50) PRIMARY KEY,
  origin BIGINT,
  destination BIGINT,
  length REAL,
  speed REAL,
  roadtype VARCHAR(10),
  geography GEOGRAPHY(LINESTRING,4326)
);

-- Spatial index
CREATE INDEX links_gix ON links USING GIST (geography);

