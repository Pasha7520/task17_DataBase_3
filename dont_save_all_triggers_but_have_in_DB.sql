use storedpr_db;
DELIMITER //
CREATE TRIGGER BeforeDeletePharmacyM_Z
BEFORE DELETE
ON pharmacy FOR EACH ROW
BEGIN
DECLARE ph_id,med_id int;
SELECT s.id INTO ph_id FROM pharmacy as s where s.id = new.pharmacy_id;
SELECT c.id INTO med_id FROM medicine as c where c.id = new.medicine_id;
IF ph_id IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Medicine_zone';
END IF;
IF med_id IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Medicine_zone';
END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER AfterUpdateMedicine
  BEFORE UPDATE
  ON medicine FOR EACH ROW
    BEGIN
  IF(new.ministry_code RLIKE '0{10}') THEN 
    SET new.ministry_code = old.ministry_code;
    ELSEIF(new.ministry_code NOT RLIKE ('(?i)^[a-z&&[^mp]]{2}[[:hyphen:]]\\d{3}[[:hyphen:]]\\d{2}$')) THEN 
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Incorrect format';
  END IF;
  END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER BeforeInsertPost
  AFTER INSERT 
  ON post FOR EACH ROW
    BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post can\'t be modified';
  END//

    CREATE TRIGGER BeforeDeletePost
  AFTER Delete
  ON post FOR EACH ROW
    BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post can\'t be modified';
  END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE insInMedicine_Zone(med_id int , zon_id int) 
BEGIN
DECLARE z_id,m_id int;
SELECT s.id INTO z_id FROM zone as s where s.id = zon_id;
SELECT c.id INTO m_id FROM medicine as c where c.id = med_id;
IF ((z_id IS NULL) or (m_id IS NULL)) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Medicine_zone';
ELSE INSERT INTO medicine_zone (`medicine_id`, `zone_id`) VALUES (med_id, zon_id);
END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE insInEmployee(name_p varchar(30),sername_p varchar(30),middle_name_p varchar(30),
	identity_number_p char(10),passport_p char(10),experience_p DECIMAL(10,1),birthday_p DATE,
    post_p varchar(15),pharmacy_id_p int)
BEGIN
INSERT INTO `storedpr_db`.`employee` (`surname`, `name`, `midle_name`, `identity_number`,
 `passport`, `experience`, `birthday`, `post`, `pharmacy_id`) VALUES (sername_p, name_p, 
 middle_name_p, identity_number_p, passport_p, experience_p, birthday_p, post_p, pharmacy_id_p);
END //
DELIMITER ;

use storedpr_db;
DELIMITER //
CREATE PROCEDURE ProcCursor()
BEGIN
	DECLARE done int DEFAULT false;
	DECLARE SurnameT varchar(25);
    DECLARE NameT char(25);
	DECLARE Em_Cursor10 CURSOR
FOR SELECT s.surname, s.name FROM employee as s;
DECLARE CONTINUE HANDLER
FOR NOT FOUND SET done = true;
OPEN Em_Cursor10;
myLoop: LOOP
FETCH Em_Cursor10 INTO SurnameT, NameT;
IF done = true THEN LEAVE myLoop;
END IF;
SET @temp_query=concat(CONCAT('CREATE TABLE ',SurnameT, NameT),concat(' (',MyRandomLoop(),')'));
PREPARE myquery FROM @temp_query; 
EXECUTE myquery;
DEALLOCATE PREPARE myquery;
END LOOP;
CLOSE Em_Cursor10;

END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION MyRandomLoop() RETURNS varchar(140) DETERMINISTIC
BEGIN
DECLARE str varchar(140);
DECLARE x int;
SET str = '', x =FLOOR((RAND() * 9) + 1);
label1: LOOP

IF x <= 0 THEN LEAVE label1;

END IF;
IF x <= 1 THEN SET str = CONCAT(str, CONCAT('column_',x,' int'));
ELSE SET str = CONCAT(str, CONCAT('column_',x,' int , '));
END IF;
SET x = x - 1;
ITERATE label1;

END LOOP;
RETURN str;
END //
DELIMITER ;