----------------------------------------------------------------------
-----------------------------XP_CMDSHELL------------------------------
----------------------------------------------------------------------
EXECUTE sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

EXECUTE sp_configure 'xp_cmdshell', 1;
GO
RECONFIGURE;
GO

EXECUTE sp_configure 'show advanced options', 0;
GO
RECONFIGURE;
GO
----------------------------------------------------------------------
-------------------------ЭКСПОРТ GENRE--------------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ExportGenreDataToJson
    @filePath NVARCHAR(500)
AS
BEGIN
    DECLARE @jsonOutput NVARCHAR(MAX);
    DECLARE @cmd NVARCHAR(4000);
    DECLARE @psCmd NVARCHAR(4000);

    SELECT @jsonOutput = (
        SELECT * 
        FROM genre 
        FOR JSON AUTO, ROOT('Genre')
    );

    SET @jsonOutput = REPLACE(@jsonOutput, '"', '\"');

    SET @psCmd = 'powershell.exe -Command "$jsonContent = ''' + @jsonOutput + '''; $filePath = ''' + @filePath + '''; $jsonContent | Out-File -FilePath $filePath -Encoding default"';

    IF LEN(@psCmd) > 2048
    BEGIN
        RAISERROR('Длина команды превышает допустимый предел в 2048 символов', 16, 1);
        RETURN;
    END

    EXEC xp_cmdshell @psCmd;
END;
----------------------------------------------------------------------
EXEC ExportGenreDataToJson @filePath = 'C:\localhost\export and import\genre.json';
----------------------------------------------------------------------
--------------------------ИМПОРТ GENRE--------------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ImportGenreDataFromJson
AS
BEGIN
    CREATE TABLE #TempGenre (
        id INT IDENTITY(1,1) PRIMARY KEY,
        genre VARCHAR(255) NOT NULL UNIQUE
    );

    DECLARE @jsonInput NVARCHAR(MAX);

    SELECT @jsonInput = BulkColumn
    FROM OPENROWSET (BULK 'C:\localhost\export and import\genre.json', SINGLE_CLOB) AS j;

    INSERT INTO #TempGenre (genre)
    SELECT genre
    FROM OPENJSON(@jsonInput, '$.Genre') 
    WITH (
        genre VARCHAR(255) '$.genre'
    );

    MERGE genre AS target
    USING #TempGenre AS source
    ON target.id = source.id
    WHEN MATCHED THEN 
        UPDATE SET 
            target.genre = source.genre
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (genre)
        VALUES (source.genre);

    DROP TABLE #TempGenre;
END;
GO
----------------------------------------------------------------------
EXEC ImportGenreDataFromJson;
----------------------------------------------------------------------
----------------------ЭКСПОРТ BOOKS_GENRES----------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ExportBooksGenresDataToJson
    @filePath NVARCHAR(500)
AS
BEGIN
    DECLARE @jsonOutput NVARCHAR(MAX);
    DECLARE @cmd NVARCHAR(4000);
    DECLARE @psCmd NVARCHAR(4000);

    SELECT @jsonOutput = (
        SELECT * 
        FROM books_genres 
        FOR JSON AUTO, ROOT('BooksGenres')
    );

    SET @jsonOutput = REPLACE(@jsonOutput, '"', '\"');

    SET @psCmd = 'powershell.exe -Command "$jsonContent = ''' + @jsonOutput + '''; $filePath = ''' + @filePath + '''; $jsonContent | Out-File -FilePath $filePath -Encoding default"';

    IF LEN(@psCmd) > 2048
    BEGIN
        RAISERROR('Длина команды превышает допустимый предел в 2048 символов', 16, 1);
        RETURN;
    END

    EXEC xp_cmdshell @psCmd;
END;
----------------------------------------------------------------------
EXEC ExportBooksGenresDataToJson @filePath = 'C:\localhost\export and import\books_genres.json';
----------------------------------------------------------------------
-----------------------ИМПОРТ BOOKS_GENRES----------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ImportBooksGenresDataFromJson
AS
BEGIN
    CREATE TABLE #TempBooksGenres (
        book_id INT,
        genre_id INT
    );

    DECLARE @jsonInput NVARCHAR(MAX);

    SELECT @jsonInput = BulkColumn
    FROM OPENROWSET (BULK 'C:\localhost\export and import\books_genres.json', SINGLE_CLOB) AS j;

    INSERT INTO #TempBooksGenres (book_id, genre_id)
    SELECT book_id, genre_id
    FROM OPENJSON(@jsonInput, '$.BooksGenres') 
    WITH (
        book_id INT '$.book_id',
        genre_id INT '$.genre_id'
    );

    MERGE books_genres AS target
    USING #TempBooksGenres AS source
    ON target.book_id = source.book_id AND target.genre_id = source.genre_id
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (book_id, genre_id)
        VALUES (source.book_id, source.genre_id);

    DROP TABLE #TempBooksGenres;
END;
----------------------------------------------------------------------
EXEC ImportBooksGenresDataFromJson;
----------------------------------------------------------------------
-------------------------ЭКСПОРТ AUTHOR--------------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ExportAuthorDataToJson
    @filePath NVARCHAR(500)
AS
BEGIN
    DECLARE @jsonOutput NVARCHAR(MAX);
    DECLARE @cmd NVARCHAR(4000);
    DECLARE @psCmd NVARCHAR(4000);

    SELECT @jsonOutput = (
        SELECT * 
        FROM author
        FOR JSON AUTO, ROOT('Author')
    );

    SET @jsonOutput = REPLACE(@jsonOutput, '"', '\"');

    SET @psCmd = 'powershell.exe -Command "$jsonContent = ''' + @jsonOutput + '''; $filePath = ''' + @filePath + '''; $jsonContent | Out-File -FilePath $filePath -Encoding default"';

    IF LEN(@psCmd) > 2048
    BEGIN
        RAISERROR('Длина команды превышает допустимый предел в 2048 символов', 16, 1);
        RETURN;
    END

    EXEC xp_cmdshell @psCmd;
END;
----------------------------------------------------------------------
EXEC ExportAuthorDataToJson @filePath = 'C:\localhost\export and import\author.json';
----------------------------------------------------------------------
--------------------------ИМПОРТ AUTHOR-------------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ImportAuthorDataFromJson
AS
BEGIN
    CREATE TABLE #TempAuthor (
        lastname VARCHAR(255) NOT NULL,
        firstname VARCHAR(255) NOT NULL,
        birthday DATE
    );

    DECLARE @jsonInput NVARCHAR(MAX);

    SELECT @jsonInput = BulkColumn
    FROM OPENROWSET (BULK 'C:\localhost\export and import\author.json', SINGLE_CLOB) AS j;

    INSERT INTO #TempAuthor (lastname, firstname, birthday)
    SELECT lastname, firstname, birthday
    FROM OPENJSON(@jsonInput, '$.Author') 
    WITH (
        lastname VARCHAR(255) '$.lastname',
        firstname VARCHAR(255) '$.firstname',
        birthday DATE '$.birthday'
    );

    MERGE author AS target
    USING #TempAuthor AS source
    ON target.lastname = source.lastname AND target.firstname = source.firstname
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (lastname, firstname, birthday)
        VALUES (source.lastname, source.firstname, source.birthday);

    DROP TABLE #TempAuthor;
END;
GO
----------------------------------------------------------------------
EXEC ImportAuthorDataFromJson;
----------------------------------------------------------------------
------------------------ЭКСПОРТ BOOKS_AUTHORS-------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ExportBooksAuthorsDataToJson
    @filePath NVARCHAR(500)
AS
BEGIN
    DECLARE @jsonOutput NVARCHAR(MAX);
    DECLARE @psCmd NVARCHAR(4000);

    SELECT @jsonOutput = (
        SELECT * 
        FROM books_authors
        FOR JSON AUTO, ROOT('BooksAuthors')
    );

    SET @jsonOutput = REPLACE(@jsonOutput, '"', '\"');

    SET @psCmd = 'powershell.exe -Command "$jsonContent = ''' + @jsonOutput + '''; $filePath = ''' + @filePath + '''; $jsonContent | Out-File -FilePath $filePath -Encoding default"';

    IF LEN(@psCmd) > 2048
    BEGIN
        RAISERROR('Длина команды превышает допустимый предел в 2048 символов', 16, 1);
        RETURN;
    END

    EXEC xp_cmdshell @psCmd;
END;
----------------------------------------------------------------------
EXEC ExportBooksAuthorsDataToJson @filePath = 'C:\localhost\export and import\books_authors.json';
----------------------------------------------------------------------
-------------------------ИМПОРТ BOOKS_AUTHORS-------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ImportBooksAuthorsDataFromJson
AS
BEGIN
    CREATE TABLE #TempBooksAuthors (
        book_id INT,
        author_id INT
    );

    DECLARE @jsonInput NVARCHAR(MAX);

    SELECT @jsonInput = BulkColumn
    FROM OPENROWSET (BULK 'C:\localhost\export and import\books_authors.json', SINGLE_CLOB) AS j;

    INSERT INTO #TempBooksAuthors (book_id, author_id)
    SELECT book_id, author_id
    FROM OPENJSON(@jsonInput, '$.BooksAuthors') 
    WITH (
        book_id INT '$.book_id',
        author_id INT '$.author_id'
    );

    MERGE books_authors AS target
    USING #TempBooksAuthors AS source
    ON target.book_id = source.book_id AND target.author_id = source.author_id
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (book_id, author_id)
        VALUES (source.book_id, source.author_id);

    DROP TABLE #TempBooksAuthors;
END;
----------------------------------------------------------------------
EXEC ImportBooksAuthorsDataFromJson;
----------------------------------------------------------------------
-----------------------ЭКСПОРТ PUBLISHINGHOUSE------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ExportPublishinghouseDataToJson
    @filePath NVARCHAR(500)
AS
BEGIN
    DECLARE @jsonOutput NVARCHAR(MAX);
    DECLARE @psCmd NVARCHAR(4000);

    SELECT @jsonOutput = (
        SELECT * 
        FROM publishinghouse
        FOR JSON AUTO, ROOT('Publishinghouse')
    );

    SET @jsonOutput = REPLACE(@jsonOutput, '"', '\"');

    SET @psCmd = 'powershell.exe -Command "$jsonContent = ''' + @jsonOutput + '''; $filePath = ''' + @filePath + '''; $jsonContent | Out-File -FilePath $filePath -Encoding default"';

    IF LEN(@psCmd) > 2048
    BEGIN
        RAISERROR('Длина команды превышает допустимый предел в 2048 символов', 16, 1);
        RETURN;
    END

    EXEC xp_cmdshell @psCmd;
END;
----------------------------------------------------------------------
EXEC ExportPublishinghouseDataToJson @filePath = 'C:\localhost\export and import\publishinghouse.json';
----------------------------------------------------------------------
-----------------------ИМПОРТ PUBLISHINGHOUSE-------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ImportPublishinghouseDataFromJson
AS
BEGIN
    CREATE TABLE #TempPublishinghouse (
        name VARCHAR(255) NOT NULL UNIQUE,
        address VARCHAR(255) NOT NULL
    );

    DECLARE @jsonInput NVARCHAR(MAX);

    SELECT @jsonInput = BulkColumn
    FROM OPENROWSET (BULK 'C:\localhost\export and import\publishinghouse.json', SINGLE_CLOB) AS j;

    INSERT INTO #TempPublishinghouse (name, address)
    SELECT name, address
    FROM OPENJSON(@jsonInput, '$.Publishinghouse') 
    WITH (
        name VARCHAR(255) '$.name',
        address VARCHAR(255) '$.address'
    );

    MERGE publishinghouse AS target
    USING #TempPublishinghouse AS source
    ON target.name = source.name
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (name, address)
        VALUES (source.name, source.address);

    DROP TABLE #TempPublishinghouse;
END;
----------------------------------------------------------------------
EXEC ImportPublishinghouseDataFromJson;
----------------------------------------------------------------------
--------------------------ЭКСПОРТ BOOK--------------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ExportBookDataToJson
    @filePath NVARCHAR(500)
AS
BEGIN
    DECLARE @jsonOutput NVARCHAR(MAX);
    DECLARE @cmd NVARCHAR(4000);
    DECLARE @psCmd NVARCHAR(4000);

    SELECT @jsonOutput = (
        SELECT * 
        FROM book 
        FOR JSON AUTO, ROOT('Book')
    );

    SET @jsonOutput = REPLACE(@jsonOutput, '"', '\"');

    SET @psCmd = 'powershell.exe -Command "$jsonContent = ''' + @jsonOutput + '''; $filePath = ''' + @filePath + '''; $jsonContent | Out-File -FilePath $filePath -Encoding default"';

    IF LEN(@psCmd) > 2048
    BEGIN
        RAISERROR('Длина команды превышает допустимый предел в 2048 символов', 16, 1);
        RETURN;
    END

    EXEC xp_cmdshell @psCmd;
END;
----------------------------------------------------------------------
EXEC ExportBookDataToJson @filePath = 'C:\localhost\export and import\book.json';
----------------------------------------------------------------------
--------------------------ИМПОРТ BOOK---------------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ImportBookDataFromJson
AS
BEGIN
    CREATE TABLE #TempBooks (
      id INT PRIMARY KEY,
      publishinghouse_id INT,
      title VARCHAR(255),
      year INT,
      pages SMALLINT
    );

    DECLARE @jsonInput NVARCHAR(MAX);

    SELECT @jsonInput = BulkColumn
    FROM OPENROWSET (BULK 'C:\localhost\export and import\book.json', SINGLE_CLOB) AS j;

    INSERT INTO #TempBooks (id, publishinghouse_id, title, year, pages)
    SELECT id, publishinghouse_id, title, year, pages
    FROM OPENJSON(@jsonInput, '$.Book') 
    WITH (
        id INT '$.id',
        publishinghouse_id INT '$.publishinghouse_id',
        title VARCHAR(255) '$.title',
        year INT '$.year',
        pages SMALLINT '$.pages'
    );

    MERGE book AS target
    USING #TempBooks AS source
    ON target.id = source.id
    WHEN MATCHED THEN 
        UPDATE SET 
            target.publishinghouse_id = source.publishinghouse_id,
            target.title = source.title,
            target.year = source.year,
            target.pages = source.pages
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (id, publishinghouse_id, title, year, pages)
        VALUES (source.id, source.publishinghouse_id, source.title, source.year, source.pages);

    DROP TABLE #TempBooks;
END;
----------------------------------------------------------------------
EXEC ImportBookDataFromJson;
----------------------------------------------------------------------
---------------------------ЭКСПОРТ SAMPLE-----------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ExportSampleDataToJson
    @filePath NVARCHAR(500)
AS
BEGIN
    DECLARE @jsonOutput NVARCHAR(MAX);
    DECLARE @cmd NVARCHAR(4000);
    DECLARE @psCmd NVARCHAR(4000);

    SELECT @jsonOutput = (
        SELECT * 
        FROM sample 
        FOR JSON AUTO, ROOT('Sample')
    );

    SET @jsonOutput = REPLACE(@jsonOutput, '"', '\"');

    SET @psCmd = 'powershell.exe -Command "$jsonContent = ''' + @jsonOutput + '''; $filePath = ''' + @filePath + '''; $jsonContent | Out-File -FilePath $filePath -Encoding default"';

    IF LEN(@psCmd) > 2048
    BEGIN
        RAISERROR('Длина команды превышает допустимый предел в 2048 символов', 16, 1);
        RETURN;
    END

    EXEC xp_cmdshell @psCmd;
END;
----------------------------------------------------------------------
EXEC ExportSampleDataToJson @filePath = 'C:\localhost\export and import\sample.json';
----------------------------------------------------------------------
----------------------------ИМПОРТ SAMPLE-----------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ImportSampleDataFromJson
AS
BEGIN
    CREATE TABLE #TempSample (
        id INT IDENTITY(1,1) PRIMARY KEY,
        book_id INT NOT NULL,
        description VARCHAR(255) NOT NULL,
        presence TINYINT CHECK (presence IN (0, 1))
    );

    DECLARE @jsonInput NVARCHAR(MAX);

    SELECT @jsonInput = BulkColumn
    FROM OPENROWSET (BULK 'C:\localhost\export and import\sample.json', SINGLE_CLOB) AS j;

    INSERT INTO #TempSample (book_id, description, presence)
    SELECT book_id, description, presence
    FROM OPENJSON(@jsonInput, '$.Sample') 
    WITH (
        book_id INT '$.book_id',
        description VARCHAR(255) '$.description',
        presence TINYINT '$.presence'
    );

    MERGE sample AS target
    USING #TempSample AS source
    ON target.id = source.id
    WHEN MATCHED THEN 
        UPDATE SET 
            target.book_id = source.book_id,
            target.description = source.description,
            target.presence = source.presence
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (book_id, description, presence)
        VALUES (source.book_id, source.description, source.presence);

    DROP TABLE #TempSample;
END;
GO
----------------------------------------------------------------------
EXEC ImportSampleDataFromJson;
----------------------------------------------------------------------
---------------------ЭКСПОРТ LISTGETBOOKS-----------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ExportListgetbooksDataToJson
    @filePath NVARCHAR(500)
AS
BEGIN
    DECLARE @jsonOutput NVARCHAR(MAX);
    DECLARE @cmd NVARCHAR(4000);
    DECLARE @psCmd NVARCHAR(4000);

    SELECT @jsonOutput = (
        SELECT * 
        FROM listgetbooks 
        FOR JSON AUTO, ROOT('Listgetbooks')
    );

    SET @jsonOutput = REPLACE(@jsonOutput, '"', '\"');

    SET @psCmd = 'powershell.exe -Command "$jsonContent = ''' + @jsonOutput + '''; $filePath = ''' + @filePath + '''; $jsonContent | Out-File -FilePath $filePath -Encoding default"';

    IF LEN(@psCmd) > 2048
    BEGIN
        RAISERROR('Длина команды превышает допустимый предел в 2048 символов', 16, 1);
        RETURN;
    END

    EXEC xp_cmdshell @psCmd;
END;
----------------------------------------------------------------------
EXEC ExportListgetbooksDataToJson @filePath = 'C:\localhost\export and import\listgetbooks.json';
----------------------------------------------------------------------
----------------------ИМПОРТ LISTGETBOOKS-----------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ImportListgetbooksDataFromJson
AS
BEGIN
    CREATE TABLE #TempListgetbooks (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        sample_id INT NOT NULL,
        takedate DATE NOT NULL,
        returndate DATE DEFAULT NULL,
        mark INT DEFAULT NULL
    );

    DECLARE @jsonInput NVARCHAR(MAX);

    SELECT @jsonInput = BulkColumn
    FROM OPENROWSET (BULK 'C:\localhost\export and import\listgetbooks.json', SINGLE_CLOB) AS j;

    INSERT INTO #TempListgetbooks (user_id, sample_id, takedate, returndate, mark)
    SELECT user_id, sample_id, takedate, returndate, mark
    FROM OPENJSON(@jsonInput, '$.Listgetbooks') 
    WITH (
        user_id INT '$.user_id',
        sample_id INT '$.sample_id',
        takedate DATE '$.takedate',
        returndate DATE '$.returndate',
        mark INT '$.mark'
    );

    MERGE listgetbooks AS target
    USING #TempListgetbooks AS source
    ON target.id = source.id
    WHEN MATCHED THEN 
        UPDATE SET 
            target.user_id = source.user_id,
            target.sample_id = source.sample_id,
            target.takedate = source.takedate,
            target.returndate = source.returndate,
            target.mark = source.mark
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (user_id, sample_id, takedate, returndate, mark)
        VALUES (source.user_id, source.sample_id, source.takedate, source.returndate, source.mark);

    DROP TABLE #TempListgetbooks;
END;
GO
----------------------------------------------------------------------
EXEC ImportListgetbooksDataFromJson;
----------------------------------------------------------------------
----------------------------ЭКСПОРТ ROLE------------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ExportRoleDataToJson
    @filePath NVARCHAR(500)
AS
BEGIN
    DECLARE @jsonOutput NVARCHAR(MAX);

    SELECT @jsonOutput = (
        SELECT * 
        FROM role 
        FOR JSON AUTO, ROOT('Role')
    );

    SET @jsonOutput = REPLACE(@jsonOutput, '"', '\"');

    DECLARE @psCmd NVARCHAR(4000);
    SET @psCmd = 'powershell.exe -Command "$jsonContent = ''' + @jsonOutput + '''; $filePath = ''' + @filePath + '''; $jsonContent | Out-File -FilePath $filePath -Encoding default"';

    IF LEN(@psCmd) > 2048
    BEGIN
        RAISERROR('Длина команды превышает допустимый предел в 2048 символов', 16, 1);
        RETURN;
    END

    EXEC xp_cmdshell @psCmd;
END;
GO
----------------------------------------------------------------------
EXEC ExportRoleDataToJson @filePath = 'C:\localhost\export and import\role.json';
----------------------------------------------------------------------
-----------------------------ИМПОРТ ROLE------------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ImportRoleDataFromJson
AS
BEGIN
    CREATE TABLE #TempRole (
      role VARCHAR(50) NOT NULL UNIQUE
    );

    DECLARE @jsonInput NVARCHAR(MAX);

    SELECT @jsonInput = BulkColumn
    FROM OPENROWSET (BULK 'C:\localhost\export and import\role.json', SINGLE_CLOB) AS j;

    INSERT INTO #TempRole (role)
    SELECT role
    FROM OPENJSON(@jsonInput, '$.Role') 
    WITH (
        role VARCHAR(50) '$.role'
    );

    MERGE role AS target
    USING #TempRole AS source
    ON target.role = source.role
    WHEN MATCHED THEN 
        UPDATE SET 
            target.role = source.role
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (role)
        VALUES (source.role);

    DROP TABLE #TempRole;
END;
GO
----------------------------------------------------------------------
EXEC ImportRoleDataFromJson;
----------------------------------------------------------------------
--------------------------ЭКСПОРТ USERS-------------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ExportUsersDataToJson
    @filePath NVARCHAR(500)
AS
BEGIN
    DECLARE @jsonOutput NVARCHAR(MAX);
    DECLARE @cmd NVARCHAR(4000);
    DECLARE @psCmd NVARCHAR(4000);

    SELECT @jsonOutput = (
        SELECT * 
        FROM users 
        FOR JSON AUTO, ROOT('Users')
    );

    SET @jsonOutput = REPLACE(@jsonOutput, '"', '\"');

    SET @psCmd = 'powershell.exe -Command "$jsonContent = ''' + @jsonOutput + '''; $filePath = ''' + @filePath + '''; $jsonContent | Out-File -FilePath $filePath -Encoding default"';

    IF LEN(@psCmd) > 2048
    BEGIN
        RAISERROR('Длина команды превышает допустимый предел в 2048 символов', 16, 1);
        RETURN;
    END

    EXEC xp_cmdshell @psCmd;
END;
----------------------------------------------------------------------
EXEC ExportUsersDataToJson @filePath = 'C:\localhost\export and import\users.json';
----------------------------------------------------------------------
--------------------------ИМПОРТ USERS--------------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ImportUsersDataFromJson
AS
BEGIN
    CREATE TABLE #TempUsers (
        role_id INT NOT NULL,
        groupname_id INT DEFAULT NULL,
        studentIDcard INT DEFAULT NULL,
        lastname VARCHAR(255) NOT NULL,
        firstname VARCHAR(255) NOT NULL,
        patronymic VARCHAR(255) NOT NULL,
        birthday DATE NOT NULL,
        login VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        create_at DATETIME NOT NULL
    );

    DECLARE @jsonInput NVARCHAR(MAX);

    SELECT @jsonInput = BulkColumn
    FROM OPENROWSET (BULK 'C:\localhost\export and import\users.json', SINGLE_CLOB) AS j;

    INSERT INTO #TempUsers (role_id, groupname_id, studentIDcard, lastname, firstname, patronymic, birthday, login, password, create_at)
    SELECT role_id, groupname_id, studentIDcard, lastname, firstname, patronymic, birthday, login, password, create_at
    FROM OPENJSON(@jsonInput, '$.Users') 
    WITH (
        role_id INT '$.role_id',
        groupname_id INT '$.groupname_id',
        studentIDcard INT '$.studentIDcard',
        lastname VARCHAR(255) '$.lastname',
        firstname VARCHAR(255) '$.firstname',
        patronymic VARCHAR(255) '$.patronymic',
        birthday DATE '$.birthday',
        login VARCHAR(255) '$.login',
        password VARCHAR(255) '$.password',
        create_at DATETIME '$.create_at'
    );

    MERGE users AS target
    USING #TempUsers AS source
    ON target.login = source.login 
    WHEN MATCHED THEN 
        UPDATE SET 
            target.role_id = source.role_id,
            target.groupname_id = source.groupname_id,
            target.studentIDcard = source.studentIDcard,
            target.lastname = source.lastname,
            target.firstname = source.firstname,
            target.patronymic = source.patronymic,
            target.birthday = source.birthday,
            target.password = source.password,
            target.create_at = source.create_at
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (role_id, groupname_id, studentIDcard, lastname, firstname, patronymic, birthday, login, password, create_at)
        VALUES (source.role_id, source.groupname_id, source.studentIDcard, source.lastname, source.firstname, source.patronymic, source.birthday, source.login, source.password, source.create_at);

    DROP TABLE #TempUsers;
END;
GO
----------------------------------------------------------------------
EXEC ImportUsersDataFromJson;
----------------------------------------------------------------------
------------------------ЭКСПОРТ GROUPNAME-----------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ExportGroupnameDataToJson
    @filePath NVARCHAR(500)
AS
BEGIN
    DECLARE @jsonOutput NVARCHAR(MAX);
    DECLARE @cmd NVARCHAR(4000);
    DECLARE @psCmd NVARCHAR(4000);

    SELECT @jsonOutput = (
        SELECT * 
        FROM groupname 
        FOR JSON AUTO, ROOT('Groupname')
    );

    SET @jsonOutput = REPLACE(@jsonOutput, '"', '\"');

    SET @psCmd = 'powershell.exe -Command "$jsonContent = ''' + @jsonOutput + '''; $filePath = ''' + @filePath + '''; $jsonContent | Out-File -FilePath $filePath -Encoding default"';

    IF LEN(@psCmd) > 2048
    BEGIN
        RAISERROR('Длина команды превышает допустимый предел в 2048 символов', 16, 1);
        RETURN;
    END

    EXEC xp_cmdshell @psCmd;
END;
----------------------------------------------------------------------
EXEC ExportGroupnameDataToJson @filePath = 'C:\localhost\export and import\groupname.json';
----------------------------------------------------------------------
------------------------ИМПОРТ GROUPNAME------------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ImportGroupnameDataFromJson
AS
BEGIN
    CREATE TABLE #TempGroupname (
        faculty_id INT NOT NULL,
        year INT NOT NULL,
        name VARCHAR(50) NOT NULL
    );

    DECLARE @jsonInput NVARCHAR(MAX);

    SELECT @jsonInput = BulkColumn
    FROM OPENROWSET (BULK 'C:\localhost\export and import\groupname.json', SINGLE_CLOB) AS j;

    INSERT INTO #TempGroupname (faculty_id, year, name)
    SELECT faculty_id, year, name
    FROM OPENJSON(@jsonInput, '$.Groupname') 
    WITH (
        faculty_id INT '$.faculty_id',
        year INT '$.year',
        name VARCHAR(50) '$.name'
    );

    MERGE groupname AS target
    USING #TempGroupname AS source
    ON target.faculty_id = source.faculty_id AND target.year = source.year AND target.name = source.name
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (faculty_id, year, name)
        VALUES (source.faculty_id, source.year, source.name);

    DROP TABLE #TempGroupname;
END;
GO
----------------------------------------------------------------------
EXEC ImportGroupnameDataFromJson;
----------------------------------------------------------------------
--------------------------ЭКСПОРТ FACULTY-----------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ExportFacultyDataToJson
    @filePath NVARCHAR(500)
AS
BEGIN
    DECLARE @jsonOutput NVARCHAR(MAX);
    DECLARE @cmd NVARCHAR(4000);
    DECLARE @psCmd NVARCHAR(4000);

    SELECT @jsonOutput = (
        SELECT * 
        FROM faculty 
        FOR JSON AUTO, ROOT('Faculty')
    );

    SET @jsonOutput = REPLACE(@jsonOutput, '"', '\"');

    SET @psCmd = 'powershell.exe -Command "$jsonContent = ''' + @jsonOutput + '''; $filePath = ''' + @filePath + '''; $jsonContent | Out-File -FilePath $filePath -Encoding default"';

    IF LEN(@psCmd) > 2048
    BEGIN
        RAISERROR('Длина команды превышает допустимый предел в 2048 символов', 16, 1);
        RETURN;
    END

    EXEC xp_cmdshell @psCmd;
END;
----------------------------------------------------------------------
EXEC ExportFacultyDataToJson @filePath = 'C:\localhost\export and import\faculty.json';
----------------------------------------------------------------------
--------------------------ИМПОРТ FACULTY------------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ImportFacultyDataFromJson
AS
BEGIN
    CREATE TABLE #TempFaculty (
        name VARCHAR(255) NOT NULL UNIQUE
    );

    DECLARE @jsonInput NVARCHAR(MAX);

    SELECT @jsonInput = BulkColumn
    FROM OPENROWSET (BULK 'C:\localhost\export and import\faculty.json', SINGLE_CLOB) AS j;

    INSERT INTO #TempFaculty (name)
    SELECT name
    FROM OPENJSON(@jsonInput, '$.Faculty') 
    WITH (
        name VARCHAR(255) '$.name'
    );

    MERGE faculty AS target
    USING #TempFaculty AS source
    ON target.name = source.name
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (name)
        VALUES (source.name);

    DROP TABLE #TempFaculty;
END;
GO
----------------------------------------------------------------------
EXEC ImportFacultyDataFromJson;