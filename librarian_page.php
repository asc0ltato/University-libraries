<?php
session_start();

if (!isset($_SESSION['user_id']) || $_SESSION['role_id'] != 2) {
    header("Location: index.php");
    exit();
}

$userId = $_SESSION['user_id'];

$serverName = "ASCOLTAT0";
$database = "Library";
$dbUsername = 'LibrarianUser';
$dbPassword = '123';

$conn = sqlsrv_connect($serverName, array(
    "Database" => $database,
    "UID" => $dbUsername,
    "PWD" => $dbPassword,
    "CharacterSet" => "UTF-8"
));

if ($conn === false) {
    die("Ошибка подключения к базе данных: " . print_r(sqlsrv_errors(), true));
}

$sqlUserInfo = "SELECT firstname, lastname FROM users WHERE id = ?";
$paramsUserInfo = array($userId);
$stmtUserInfo = sqlsrv_query($conn, $sqlUserInfo, $paramsUserInfo);
if ($stmtUserInfo === false) {
    die("Ошибка выполнения запроса: " . print_r(sqlsrv_errors(), true));
}
$userInfo = sqlsrv_fetch_array($stmtUserInfo, SQLSRV_FETCH_ASSOC);
$userFullName = $userInfo['firstname'] . ' ' . $userInfo['lastname'];

$sqlBooks = "SELECT * FROM ViewBooks()";
$stmtBooks = sqlsrv_query($conn, $sqlBooks);

if ($stmtBooks === false) {
    die("Ошибка при получении информации о книгах: " . print_r(sqlsrv_errors(), true));
}

?>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Поиск книг</title>
    <style>
         body {
            font-family: 'Arial', sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            color: #333;
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

        h2 {
            text-align: center;
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

        input[type="submit"] {
            padding: 10px 20px;
            background-color: #333;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin: 0 5px;
        }

        input[type="submit"]:hover {
            background-color: #444;
        }

        input[type="submit"]:focus {
            outline: none;
        }

        form.search-form {
        text-align: center;
        margin-bottom: 20px;
        }

        form.search-form input[type="text"] {
            padding: 10px;
            width: 100%;
            border-radius: 4px;
            border: 1px solid #ccc;
            font-size: 16px;
            box-sizing: border-box;
            margin-bottom: 10px;
        }

        form.search-form input[type="submit"] {
            padding: 10px 20px;
            background-color: #333;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-left: 10px;
        }

        form.search-form input[type="submit"]:hover {
            background-color: #444;
        }

        form.search-form input[type="submit"]:focus {
            outline: none;
        }
    </style>
</head>
<body>
    <nav>
        <ul>
            <li><a href="librarian_page.php">Поиск книги</a></li>
            <li><a href="sample_manage.php">Управление экземплярами</a></li>
            <li><a href="return_books.php">Выдача и прием книг</a></li>
            <li><a href="logout.php">Выход</a></li>
        </ul>
    </nav>
    <h2>Добро пожаловать, <?php echo $userFullName; ?>!</h2>
    <h2>Информация о книгах</h2>

    <form class="search-form" method="GET" action="">
        <input type="text" name="search" placeholder="Поиск по названию, автору или жанру">
        <input type="submit" name="submit" value="Поиск">
    </form>

    <table>
        <tr>
            <th>ID книги</th>
            <th>Название</th>
            <th>Жанры</th>
            <th>Авторы</th>
            <th>Издательство</th>
            <th>Год издания</th>
            <th>Страницы</th>
        </tr>
        <?php
        if (isset($_GET['submit']) && isset($_GET['search'])) {
            $sqlSearch = "SELECT * FROM SearchBooks(?)";
            $paramsSearch = array($_GET['search']);
            $stmtSearch = sqlsrv_query($conn, $sqlSearch, $paramsSearch);

            if ($stmtSearch === false) {
                die("Ошибка при выполнении запроса поиска: " . print_r(sqlsrv_errors(), true));
            }

            while ($rowBook = sqlsrv_fetch_array($stmtSearch, SQLSRV_FETCH_ASSOC)) {
                echo "<tr>
                        <td>{$rowBook['id']}</td>
                        <td>{$rowBook['title']}</td>
                        <td>{$rowBook['genres']}</td>
                        <td>{$rowBook['authors']}</td>
                        <td>{$rowBook['publishinghouse']}</td>
                        <td>{$rowBook['year']}</td>
                        <td>{$rowBook['pages']}</td>
                    </tr>";
            }
        } else {
            while ($rowBook = sqlsrv_fetch_array($stmtBooks, SQLSRV_FETCH_ASSOC)): 
        ?>
            <tr>
                <td><?php echo $rowBook['id']; ?></td>
                <td><?php echo $rowBook['title']; ?></td>
                <td><?php echo $rowBook['genres']; ?></td>
                <td><?php echo $rowBook['authors']; ?></td>
                <td><?php echo $rowBook['publishinghouse']; ?></td>
                <td><?php echo $rowBook['year']; ?></td>
                <td><?php echo $rowBook['pages']; ?></td>
            </tr>
        <?php endwhile; 
        }?>
    </table>
</body>
</html>
<?php
sqlsrv_close($conn);
?>