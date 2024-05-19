
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

$sql = "SELECT * FROM dbo.GetIssuedBooks()";
$stmtIssuedBooks = sqlsrv_query($conn, $sql);


if ($stmtIssuedBooks === false) {
    die("Ошибка при выполнении запроса: " . print_r(sqlsrv_errors(), true));
}

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['issueBook'])) {
    $studentIDCard = $_POST['studentIDCard'];
    $bookId = $_POST['book_id'];

    $sql = "EXECUTE dbo.IssueBook @StudentIDCard = ?, @BookId = ?";
    $params = array($studentIDCard, $bookId);
    $stmt = sqlsrv_query($conn, $sql, $params);

    if ($stmt === false) {
        die("Ошибка при выдаче книги: " . print_r(sqlsrv_errors(), true));
    }
}

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['receiveBook'])) {
    $studentIDCard = $_POST['studentIDCard'];
    $sampleId = $_POST['id']; 
    $mark = $_POST['mark']; 

    $sql = "EXECUTE dbo.ReturnBookLibrarian @StudentIDCard = ?, @SampleId = ?, @mark = ?"; 
    $params = array($studentIDCard, $sampleId, $mark);
    $stmt = sqlsrv_query($conn, $sql, $params);

    if ($stmt === false) {
        die("Ошибка при приеме книги: " . print_r(sqlsrv_errors(), true));
    }
}


$stmtSamples = null; 

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['search'])) {
    $searchTerm = $_POST['searchTerm'];
    $sql = "SELECT * FROM dbo.SearchBooksByTitle(?)";
    $params = array($searchTerm);
    $stmtSearchBooks = sqlsrv_query($conn, $sql, $params);
    $stmtSamples = $stmtSearchBooks;
} else {
    $stmtSamples = sqlsrv_query($conn, "SELECT * FROM GetBookSamples()");
}

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['searchStudentIDBtn'])) {
    $searchStudentID = $_POST['searchStudentID'];
    $sql = "{CALL SearchIssuedBooksByStudentID(?)}"; 
    $params = array($searchStudentID);
    $stmtIssuedBooks = sqlsrv_query($conn, $sql, $params);
    if ($stmtIssuedBooks === false) {
        die("Ошибка при выполнении запроса: " . print_r(sqlsrv_errors(), true));
    }
}
?>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Выдача и прием книг</title>
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
            margin: 20px auto 0 auto;
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

        .container {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
            margin-bottom: 25px;
        }

        .form-containerTwo {
            width: 20%;
            background-color: #fff;
            padding-left: 30px;
            padding-bottom: 20px;
            padding-top: 10px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            margin-right: 400px;
        }

        .form-containerTwo label {
            display: block;
            margin-bottom: 10px;
        }

        .form-containerTwo input[type="text"],
        .form-containerTwo input[type="submit"] {
            display: block;
            width: 90%;
            padding: 10px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }

        .form-containerTwo input[type="submit"] {
            display: block;
            background-color: #333;
            color: white;
            border: none;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .form-containerTwo input[type="submit"]:hover {
            background-color: #444;
        }

        .form-containerOne {
            width: 20%;
            height: 30%;
            background-color: #fff;
            padding-left: 30px;
            padding-bottom: 20px;
            padding-top: 10px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            margin-left: 400px;
        }

        .form-containerOne label {
            display: block;
            margin-bottom: 10px;
        }

        .form-containerOne input[type="text"],
        .form-containerOne input[type="submit"] {
            display: block;
            width: 90%;
            padding: 10px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }

        .form-containerOne input[type="submit"] {
            display: block;
            background-color: #333;
            color: white;
            border: none;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .form-containerOne input[type="submit"]:hover {
            background-color: #444;
        }

        .container_ {
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
            margin-top: 20px;
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

        #mark {
            width: 50px;
            padding: 8px; 
            font-size: 14px; 
            border: 1px solid #ccc; 
            border-radius: 4px;
            box-sizing: border-box; 
            margin-bottom: 20px;
        }

        #mark:focus {
            outline: none; 
            border-color: #66afe9; 
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

    <div class="container">
        <div class="form-containerOne">
        <form method="post">
            <h3>Выдача книги для читателя</h3>
            <label for="studentIDCard">Номер студенческого билета:</label>
            <input type="text" id="studentIDCard" name="studentIDCard" required>
            <label for="book_id">ID книги:</label>
            <input type="text" id="book_id" name="book_id" required>
            <input type="submit" name="issueBook" value="Выдать">
        </form>
        </div>

        <div class="form-containerTwo">
            <form method="post">
                <h3>Прием книги от читателя</h3>
                <label for="studentIDCard">Номер студенческого билета:</label>
                <input type="text" id="studentIDCard" name="studentIDCard" required>
                <label for="id">ID экземпляра:</label>
                <input type="text" id="id" name="id" required>
                <label for="id">Оценка книги:</label>
                <input type="number" id="mark" name="mark" min = "1" max = "5" required>
                <input type="submit" name="receiveBook" value="Принять">
            </form>
        </div>
    </div>

    <div class="container_">
        <form class="search-form" method="POST" action="">
            <input type="text" name="searchStudentID" placeholder="Поиск по ID студенческой карты">
            <input type="submit" name="searchStudentIDBtn" value="Поиск">
        </form>
    </div>

    <h2>Список книг на руках</h2>
    <table>
    <tr>
        <th>ID студенческой карты</th>
        <th>ID экземпляра</th>
        <th>Дата взятия</th>
    </tr>
    <?php
        if ($stmtIssuedBooks !== null) {
            while ($row = sqlsrv_fetch_array($stmtIssuedBooks, SQLSRV_FETCH_ASSOC)) {
                echo "<tr>
                        <td>{$row['studentIDCard']}</td>
                        <td>{$row['id']}</td>
                        <td>" . ($row['takedate'] ? $row['takedate']->format('Y-m-d') : "") . "</td>
                    </tr>";
            }
        }
    ?>

    </table>
        <div class="container_">
            <form class="search-form" method="POST" action="">
                <input type="text" name="searchTerm" placeholder="Поиск по названию">
                <input type="submit" name="search" value="Поиск">
            </form>
        </div>

        <h2>Список экземпляров книг</h2>
        <table>
        <tr>
            <th>ID экземпляра</th>
            <th>ID книги</th>
            <th>Название книги</th>
            <th>Описание</th>
            <th>Наличие</th>
        </tr>
        <?php
        if ($stmtSamples !== null) {
            while ($row = sqlsrv_fetch_array($stmtSamples, SQLSRV_FETCH_ASSOC)) {
                echo "<tr>
                        <td>{$row['id']}</td>
                        <td>{$row['book_id']}</td>
                        <td>{$row['title']}</td>
                        <td>{$row['description']}</td>
                        <td>{$row['presence']}</td>
                    </tr>";
            }
        }        
        ?>
    </table>
    </body>
    </html>
    <?php
    sqlsrv_close($conn);
    ?>