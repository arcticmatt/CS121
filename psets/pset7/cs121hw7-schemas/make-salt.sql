/* This function generates a specified number of characters for using as a
 * salt in passwords.
 */
DELIMITER !
CREATE FUNCTION make_salt(num_chars INTEGER) RETURNS VARCHAR(20)
NOT DETERMINISTIC
BEGIN
    DECLARE salt VARCHAR(20) DEFAULT '';

    /* Don't want to generate more than 20 characters of salt. */
    SET num_chars = LEAST(20, num_chars);

    /* Generate the salt!  Characters used are ASCII code 32 (space)
     * through 126 ('z').
     */
    WHILE num_chars > 0 DO
        SET salt = CONCAT(salt, CHAR(32 + FLOOR(RAND() * 95)));
        SET num_chars = num_chars - 1;
    END WHILE;

    RETURN salt;
END !
DELIMITER ;
