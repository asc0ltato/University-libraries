----------------------------------------------------------------------
----------------КОРРЕКТНОСТЬ СТУДЕНЧЕСКОЙ КАРТЫ-----------------------
----------------------------------------------------------------------
CREATE TRIGGER trg_check_studentIDcard_length
ON users
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE LEN(CAST(studentIDcard AS nvarchar)) <> 6 AND studentIDcard IS NOT NULL
    )
    BEGIN
        THROW 50000, 'ID cтуденческой карты должно состоять из 6 цифр', 1;
    END
END;
----------------------------------------------------------------------
-------------------ПРОВЕРКА ГОДА ИЗДАНИЯ КНИГИ------------------------
----------------------------------------------------------------------
CREATE TRIGGER trg_check_year
ON book
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @CurrentYear INT;
    SET @CurrentYear = YEAR(GETDATE());

    IF EXISTS (SELECT 1 FROM inserted WHERE year > @CurrentYear OR year < 1000)
    BEGIN
        RAISERROR ('Год издания книги должен быть больше тысячного года и не превышать текущий год', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
----------------------------------------------------------------------
------------------ПРОВЕРКА ВОЗРАСТА ПОЛЬЗОВАТЕЛЯ----------------------
----------------------------------------------------------------------
CREATE TRIGGER trg_check_age
ON users
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @TodayDate DATETIME
    SET @TodayDate = GETDATE()

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE DATEDIFF(YEAR, inserted.birthday, @TodayDate) <= 16
    )
    BEGIN
        THROW 50001, 'Возраст пользователя должен быть больше 16 лет', 1
        ROLLBACK TRANSACTION
    END
END;
----------------------------------------------------------------------
-------------------ДУБЛИКАТ СТУДЕНЧЕСКОЙ КАРТЫ------------------------
----------------------------------------------------------------------
CREATE TRIGGER trg_check_unique_studentIDcard
ON users
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN users u ON i.studentIDcard = u.studentIDcard
        WHERE i.studentIDcard IS NOT NULL AND i.id <> u.id
    )
    BEGIN
        THROW 50002, 'ID cтуденческой карты дублируется', 1;
    END
END;
----------------------------------------------------------------------
--------------ДУБЛИКАТЫ ГОДА ПОСТУПЛЕНИЯ И НАЗВАНИЙ ГРУПП-------------
----------------------------------------------------------------------
CREATE TRIGGER trg_check_duplicate_group
ON groupname
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM (
            SELECT faculty_id, year, name, COUNT(*) AS count
            FROM inserted
            GROUP BY faculty_id, year, name
            HAVING COUNT(*) > 1
        ) AS duplicates
    )
    BEGIN
        THROW 50003, 'Найдены дубликаты года поступления и названий групп', 1;
        ROLLBACK TRANSACTION; 
        RETURN;
    END
END;
----------------------------------------------------------------------
-------------------------ДУБЛИКАТЫ АВТОРОВ---------------------------
----------------------------------------------------------------------
CREATE TRIGGER trg_check_duplicate_authors
ON author
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT lastname, firstname, birthday, COUNT(*) AS count
        FROM inserted
        GROUP BY lastname, firstname, birthday
        HAVING COUNT(*) > 1
    )
    BEGIN
        THROW 50004, 'Обнаружены дубликаты авторов', 1;
        ROLLBACK TRANSACTION; 
        RETURN;
    END
END;
----------------------------------------------------------------------
----------ОБНОВЛЕНИЕ СПИСКА БИБЛИОТЕКАРЕЙ ПОСЛЕ УДАЛЕНИЯ--------------
----------------------------------------------------------------------
CREATE TRIGGER trg_DeleteLibrarian_UpdateUsers
ON users
AFTER DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted WHERE role_id = 2) 
    BEGIN
        UPDATE u
        SET u.lastname = d.lastname,
            u.firstname = d.firstname,
            u.patronymic = d.patronymic,
            u.birthday = d.birthday
        FROM deleted d
        INNER JOIN users u ON d.id = u.id;
    END
END;
----------------------------------------------------------------------
------------ОБНОВЛЕНИЕ СПИСКА ЧИТАТЕЛЕЙ ПОСЛЕ УДАЛЕНИЯ----------------
----------------------------------------------------------------------
CREATE TRIGGER trg_DeleteReader_UpdateUsers
ON users
AFTER DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted WHERE role_id = 3) 
    BEGIN
        UPDATE u
        SET u.groupname_id = d.groupname_id, 
            u.studentIDcard = d.studentIDcard,
			u.lastname = d.lastname,
            u.firstname = d.firstname,
            u.patronymic = d.patronymic,
            u.birthday = d.birthday
        FROM deleted d
        INNER JOIN users u ON d.id = u.id;
    END
END;
----------------------------------------------------------------------
--DROP TRIGGER trg_check_studentIDcard_length;
--DROP TRIGGER trg_check_year;
--DROP TRIGGER trg_check_age;
--DROP TRIGGER trg_check_unique_studentIDcard;
--DROP TRIGGER trg_check_duplicate_group;
--DROP TRIGGER trg_check_duplicate_authors;
--DROP TRIGGER trg_DeleteLibrarian_UpdateUsers;
--DROP TRIGGER trg_DeleteReader_UpdateUsers;