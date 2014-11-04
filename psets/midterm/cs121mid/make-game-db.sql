-- [Problem 1]
-- This table keeps tracks of people at the retirement home, and is not just
-- used for keeping track of gaming, but also for more general purposes.
CREATE TABLE geezer (
    person_id       INTEGER AUTO_INCREMENT,
    person_name     VARCHAR(100) NOT NULL,
    gender          CHAR(1) NOT NULL,
    birth_date      DATE NOT NULL,
    prescriptions   VARCHAR(1000),
    PRIMARY KEY (person_id),
    CHECK (gender IN ('M', 'F'))
);

-- This table keeps track of basic information about each game that the
-- denizens of the retirement home like to play.
CREATE TABLE game_type (
    type_id         INTEGER AUTO_INCREMENT,
    type_name       VARCHAR(20) NOT NULL UNIQUE,
    game_desc       VARCHAR(1000) NOT NULL,
    min_players     INTEGER NOT NULL,
    max_players     INTEGER,
    PRIMARY KEY (type_id),
    CHECK (min_players > 0),
    CHECK (max_players IS NULL OR max_players >= min_players)
);

-- This table tracks specific games that are played. Each game is assigned
-- an auto-generated integer ID value.
CREATE TABLE game (
    game_id         INTEGER AUTO_INCREMENT,
    type_id         INTEGER NOT NULL,
    game_date       TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (game_id),
    FOREIGN KEY (type_id) REFERENCES game_type(type_id)
);

-- This table records the final score that each person achieved in a particular
-- game.
CREATE TABLE game_score (
    game_id         INTEGER,
    person_id       INTEGER,
    score           INTEGER NOT NULL,
    PRIMARY KEY (game_id, person_id),
    FOREIGN KEY (game_id) REFERENCES game(game_id),
    FOREIGN KEY (person_id) REFERENCES geezer(person_id)
);
