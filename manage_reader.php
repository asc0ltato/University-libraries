<?php
$serverName = "ASCOLTAT0";
$database = "Library";
$dbUsername = 'AdminUser';
$dbPassword = '111';

$adminConn = sqlsrv_connect($serverName, array(
    "Database" => $database,
    "UID" => $dbUsername,
    "PWD" => $dbPassword,
    "CharacterSet" => "UTF-8"
));

if ($adminConn === false) {
    die("Не удалось установить соединение: " . print_r(sqlsrv_errors(), true));
}

$sqlReaders = "SELECT u.id, r.role, u.groupname_id, u.studentIDcard, u.lastname, u.firstname, u.patronymic, u.birthday, u.create_at
FROM users u 
INNER JOIN role r ON u.role_id = r.id 
WHERE u.role_id = 3";

$stmtReaders = sqlsrv_query($adminConn, $sqlReaders);

if ($stmtReaders === false) {
    die("Ошибка при получении сведений: " . print_r(sqlsrv_errors(), true));
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    if (isset($_POST['updateUser'])) {
        $userId = $_POST['id'];
        $groupname_id = $_POST['groupname_id'];
        $lastname = $_POST['lastname'];
        $firstname = $_POST['firstname'];
        $patronymic = $_POST['patronymic'];
        $birthday = $_POST['birthday'];

        $sqlUpdateProcedure = "{CALL UpdateReader(?, ?, ?, ?, ?, ?)}";
        $params = array($userId, $groupname_id, $lastname, $firstname, $patronymic, $birthday);
        $stmtUpdate = sqlsrv_query($adminConn, $sqlUpdateProcedure, $params);
    
        if ($stmtUpdate === false) {
            die("Ошибка при обновлении записи: " . print_r(sqlsrv_errors(), true));
        }
    }    
    elseif (isset($_POST['DeleteUser'])) {
        $deleteUserId = $_POST['DeleteUser'];

        $sqlDelete = "{CALL DeleteUser(?)}";
        $params = array($deleteUserId);
        $stmtDelete = sqlsrv_query($adminConn, $sqlDelete, $params);

        if ($stmtDelete === false) {
            die("Ошибка при удалении библиотекаря: " . print_r(sqlsrv_errors(), true));
        }
    }       
    elseif (isset($_POST['AddReader'])) {
        $groupname_id = $_POST['groupname_id'];
        $studentIDcard = $_POST['studentIDcard'];
        $lastname = $_POST['lastname'];
        $firstname = $_POST['firstname'];
        $patronymic = $_POST['patronymic'];
        $birthday = $_POST['birthday'];
        $login = $_POST['login'];
        $password = $_POST['password'];
    
        $sqlAddUser = "{CALL AddReader(?, ?, ?, ?, ?, ?, ?, ?)}"; 
        $params = array($groupname_id, $studentIDcard, $lastname, $firstname, $patronymic, $birthday, $login, $password); 
        $stmtAddUser = sqlsrv_query($adminConn, $sqlAddUser, $params);
    
        if ($stmtAddUser === false) {
            die("Ошибка при добавлении читателя: " . print_r(sqlsrv_errors(), true));
        }
    } 
            
    if (isset($_POST['searchStudentIDCard']) && $_POST['studentIDcard'] != '') {
        $studentIDcard = $_POST['studentIDcard'];
        $sqlReaders = "SELECT * FROM SearchReaderByStudentIDCard(?)";
        $params = array($studentIDcard);
        $stmtReaders = sqlsrv_query($adminConn, $sqlReaders, $params);
    } else {
        $sqlReaders = "SELECT * FROM GetAllReaders()";        
        $stmtReaders = sqlsrv_query($adminConn, $sqlReaders);
    }

    if ($stmtReaders === false) {
        die("Ошибка при получении сведений: " . print_r(sqlsrv_errors(), true));
    }
}
?>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Управление читателем</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            color: #333;
        }

        h1, h2 {
            text-align: center;
        }

        nav {
            background-color: #333;
            padding: 10px 0;
        }

        nav ul {
            list-style-type: none;
            padding: 0;
            margin: 0;
            text-align: center;
        }

        nav ul li {
            display: inline;
        }

        nav ul li a {
            text-decoration: none;
            color: white;
            padding: 10px 20px;
            border: 1px solid #444;
            border-radius: 5px;
            transition: background-color 0.3s, color 0.3s;
        }

        nav ul li a:hover {
            background-color: #555;
            color: #fff;
        }

        table {
            width: 90%;
            margin: 20px auto;
            border-collapse: collapse;
        }

        th, td {
            padding: 10px;
            text-align: center;
            border-bottom: 1px solid #ddd;
        }

        th {
            background-color: #f2f2f2;
        }

        form {
            text-align: center;
            margin-bottom: 20px;
            width: 16%;
            margin: 0 auto;
        }

        input[type="submit"], input[type="button"] {
            padding: 10px 20px;
            background-color: #333;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin: 0 5px;
        }

        input[type="submit"]:hover, input[type="button"]:hover {
            background-color: #444;
        }

        input[type="submit"]:focus, input[type="button"]:focus {
            outline: none;
        }

        input[type="text"], input[type="date"], input[type="password"] {
            width: 100%;
            padding: 8px;
            margin: 5px 0;
            box-sizing: border-box;
        }

        .button-container {
            text-align: center;
            margin-bottom: 20px;
        }

        .button-container input[type="submit"] {
            margin: 0 5px;
        }

        .form-container {
            text-align: center;
            margin-top: 20px; 
            margin-bottom: 20px;
        }

        .form-container input[type="submit"] {
            padding: 10px 20px;
            background-color: #333;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin: 0 5px;
            display: block;
            margin-bottom: 10px;
        }

        form.search-form {
            text-align: center;
            margin-bottom: 20px;
        }

        form.search-container input[type="text"] {
            padding: 10px;
            width: 100%;
            border-radius: 4px;
            border: 1px solid #ccc;
            font-size: 16px;
            box-sizing: border-box;
            margin-bottom: 10px;
        }

        form.search-container input[type="submit"] {
            padding: 10px 20px;
            background-color: #333;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-left: 10px;
            margin-top: 10px;
        }

        form.search-container input[type="submit"]:hover {
            background-color: #444;
        }

        form.search-container input[type="submit"]:focus {
            outline: none;
        }
    </style>
</head>
<body>
    <nav>
        <ul>
            <li><a href="admin_page.php">Управление библиотекарями</a></li>
            <li><a href="manage_reader.php">Управление читателями</a></li>
            <li><a href="manage_book.php">Управление книгами</a></li>
            <li><a href="logout.php">Выход</a></li>
        </ul>
    </nav>
    <div class="form-container"> 
        <h2>Добавить читателя</h2>
        <form action="" method="post">
            <label for="groupname_id">ID группы: (до 5)</label><br>
            <input type="text" name="groupname_id" id="groupname_id" required><br>
            <label for="studentIDcard">ID студенческой карты: (6 цифр)</label><br>
            <input type="text" name="studentIDcard" id="studentIDcard" required><br>
            <label for="lastname">Фамилия:</label><br>
            <input type="text" name="lastname" id="lastname" required><br>
            <label for="firstname">Имя:</label><br>
            <input type="text" name="firstname" id="firstname" required><br>
            <label for="patronymic">Отчество:</label><br>
            <input type="text" name="patronymic" id="patronymic"><br>
            <label for="birthday">Дата рождения:</label><br>
            <input type="date" name="birthday" id="birthday" required><br>
            <label for="login">Логин:</label><br>
            <input type="text" name="login" id="login" required><br>
            <label for="password">Пароль:</label><br>
            <input type="password" name="password" id="password" required><br>
            <input type="submit" name="AddReader" value="Добавить" style="margin: auto; display: block;">
        </form>
    </div>
    
    <h2>Поиск</h2>

    <form class="search-container" action="" method="post">
        <input type="text" name="studentIDcard" id="studentIDcard" placeholder="ID студенческой карты:">
        <input type="submit" name="searchStudentIDCard" value="Поиск">
    </form>

    <h2>Информация о читателях</h2>
    
    <table>
        <tr>
            <th>ID пользователя</th>
            <th>Роль</th>
            <th>ID студенческой карты</th>
            <th>ID группы</th>
            <th>Фамилия</th>
            <th>Имя</th>
            <th>Отчество</th>
            <th>День рождения</th>
            <th>Дата создания аккаунта</th>
            <th>Cохранить</th> 
            <th>Удалить</th> 
        </tr>
        <?php
    while ($rowReader = sqlsrv_fetch_array($stmtReaders, SQLSRV_FETCH_ASSOC)) {
        echo "<tr>";
        echo "<td>" . ($rowReader['id'] ?? '') . "</td>";
        echo "<td>" . ($rowReader['role'] ?? '') . "</td>";
        echo "<td>" . ($rowReader['studentIDcard'] ?? '') .  "</td>";
        echo "<form method='POST'>";    
        echo "<td><input type='text' name='groupname_id' value='" . ($rowReader['groupname_id'] ?? '') . "' ></td>";
        echo "<td><input type='text' name='lastname' value='" . ($rowReader['lastname'] ?? '') . "' ></td>";
        echo "<td><input type='text' name='firstname' value='" . ($rowReader['firstname'] ?? '') . "' ></td>";
        echo "<td><input type='text' name='patronymic' value='" . ($rowReader['patronymic'] ?? '') . "' ></td>";
        echo "<td><input type='date' name='birthday' value='" . ($rowReader['birthday'] ? $rowReader['birthday']->format('Y-m-d') : '') . "' ></td>";
        echo "<td>" . ($rowReader['create_at'] ? $rowReader['create_at']->format('Y-m-d') : '') . "</td>";
        echo "<td>
        <input type='hidden' name='id' value='" . ($rowReader['id'] ?? '') . "'>
        <input type='submit' name='updateUser' value='Сохранить'>
        </td>";
        echo "<td>
        <input type='hidden' name='DeleteUser' value='" . ($rowReader['id'] ?? '') . "'>
        <input type='submit' value='Удалить'>
        </td>";
        echo "</form></tr>";
    }
        sqlsrv_free_stmt($stmtReaders);
        ?>
    </table>

</body>
</html>