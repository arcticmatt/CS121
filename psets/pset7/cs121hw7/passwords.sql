-- [Problem 1a]
DROP TABLE IF EXISTS user_info;
-- This table stores the data for the salt+hash password mechanism.
-- It includes users; more specifically, for each user, it contains
-- their username, their hashed password, and the salt for their password.
CREATE TABLE user_info (
    username      VARCHAR(20),          -- usernames can be up to 20 chars
    salt          VARCHAR(20) NOT NULL, -- salts can be up to 20 chars
    password_hash CHAR(64) NOT NULL,    -- password hashes will be 64 chars,
                                        -- as we generate them with SHA2(256)
    PRIMARY KEY (username),
    CHECK (LEN(salt) >= 6)
);


-- [Problem 1b]
DROP PROCEDURE IF EXISTS sp_add_user;
DELIMITER !

-- This procedure generates a new salt and adds a new record to the
-- user_info table with the passed-in username, salt, and newly created
-- password. The newly created password is created by concatenating the
-- generated salt and the passed-in password, then hashing that string.
CREATE PROCEDURE sp_add_user (
    IN new_username VARCHAR(20),
    IN password     VARCHAR(20)
)
BEGIN
    DECLARE new_salt          CHAR(10);
    DECLARE new_password_hash CHAR(64);
    -- Generate new salt
    SELECT make_salt(10) INTO new_salt;
    -- Hash salt/password concatentation
    SELECT SHA2(CONCAT(new_salt, password), 256) INTO new_password_hash;
    -- Insert new row into table
    INSERT INTO user_info VALUES (new_username, new_salt, new_password_hash);
END!

DELIMITER ;


-- [Problem 1c]
DROP PROCEDURE IF EXISTS sp_change_password;
DELIMITER !

-- This procedure is virtually identical to the previous procedure, except that
-- an existing user record will be updated, rather than adding a new record.
-- More specifically, this procedure updates the user with the passed-in
-- username by giving them a new password.
CREATE PROCEDURE sp_change_password(
    IN username     VARCHAR(20),
    IN new_password VARCHAR(20)
)
BEGIN
    DECLARE new_salt          CHAR(10);
    DECLARE new_password_hash CHAR(64);
    -- Generate new salt
    SELECT make_salt(10) INTO new_salt;
    -- Hash salt/password concatentation
    SELECT SHA2(CONCAT(new_salt, new_password), 256) INTO new_password_hash;
    -- Update table
    UPDATE user_info AS u
        SET salt = new_salt,
            password_hash = new_password_hash
        WHERE u.username = username;
END!

DELIMITER ;


-- [Problem 1d]
DROP FUNCTION IF EXISTS authenticate;
DELIMITER !

-- This function returns a BOOLEAN value of TRUE or FALSE, based on whether
-- valid username and password have been provided. It returns TRUE iff:
--     - The username actually appears in the user_info table, and
--     - When the specified password is salted and hashed, the resulting hash
--       matches the hash stored in the database
-- If the username is not present, or the hashed password doesn't match the
-- value stored in the database, authentication fails and FALSE should be
-- returned.
CREATE FUNCTION authenticate(
    fn_username VARCHAR(20),
    fn_password VARCHAR(20)
) RETURNS BOOLEAN BEGIN
    DECLARE fn_salt          VARCHAR(20);
    -- Check if username is present in user_info table
    IF fn_username IN (SELECT username FROM user_info) THEN
        SELECT salt INTO fn_salt FROM user_info WHERE username = fn_username;
        -- Check if salted password hash matches the hash stored in table
        IF SHA2(CONCAT(fn_salt, fn_password), 256) IN
        (SELECT password_hash FROM user_info WHERE username = fn_username)
        THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    ELSE
        RETURN FALSE;
    END IF;
END!

DELIMITER ;

-- TESTING
-- CALL sp_add_user('alice', 'hello');
-- CALL sp_add_user('bob', 'goodbye');

-- SELECT authenticate('carl', 'hello');
-- SELECT authenticate('alice', 'goodbye');
-- SELECT authenticate('alice', 'hello');
-- SELECT authenticate('bob', 'goodbye');

-- CALL sp_change_password('alice', 'greetings');

-- SELECT authenticate('alice', 'hello');
-- SELECT authenticate('alice', 'greetings');
-- SELECT authenticate('bob', 'greetings');
