<?php
session_start();

if (!isset($_SESSION['user_id']) || $_SESSION['role_id'] != 3) {
    header("Location: index.php");
    exit();
}

$serverName = "ASCOLTAT0";
$database = "Library";
$dbUsername = 'ReaderUser';
$dbPassword = '321';

$conn = sqlsrv_connect($serverName, array(
    "Database" => $database,
    "UID" => $dbUsername,
    "PWD" => $dbPassword,
    "CharacterSet" => "UTF-8"
));

if ($conn === false) {
    die("Ошибка подключения к базе данных: " . print_r(sqlsrv_errors(), true));
}

if (isset($_POST['search'])) {
    $searchTitle = $_POST['search'];
    $sqlRatings = "SELECT * FROM dbo.SearchBooksByTitleInRating(?) ORDER BY average_rating DESC";
    $params = array($searchTitle);
} else {
    $sqlRatings = "SELECT * FROM dbo.GetBookRatings() ORDER BY average_rating DESC";
    $params = array();
}

$stmtRatings = sqlsrv_query($conn, $sqlRatings, $params);

if ($stmtRatings === false) {
    die("Ошибка при получении рейтинга книг: " . print_r(sqlsrv_errors(), true));
}
?>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Рейтинги книг</title>
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
            <li><a href="reader_page.php">Главная</a></li>
            <li><a href="book_ratings.php">Рейтинг книг</a></li>
            <li><a href="logout.php">Выход</a></li>
        </ul>
    </nav>

    <h2>Рейтинг книг</h2>

    <div class="container_">
        <form class="search-form" method="POST" action="">
            <input type="text" name="search" placeholder="Поиск по названию">
            <input type="submit" value="Поиск">
        </form>
    </div>

    <table>
        <tr>
            <th>ID книги</th>
            <th>Название книги</th>
            <th>Жанры</th>
            <th>Авторы</th>
            <th>Издательство</th>
            <th>Средний рейтинг</th>
        </tr>
        <?php
        while ($row = sqlsrv_fetch_array($stmtRatings, SQLSRV_FETCH_ASSOC)) {
            $id = isset($row['id']) ? $row['id'] : '';
            $title = isset($row['title']) ? $row['title'] : '';
            $genres = isset($row['genres']) ? $row['genres'] : '';
            $authors = isset($row['authors']) ? $row['authors'] : '';
            $publishinghouse = isset($row['publishinghouse']) ? $row['publishinghouse'] : '';
            $averageRating = isset($row['average_rating']) ? $row['average_rating'] : null;
            $formattedRating = $averageRating !== null ? number_format($averageRating) : '-';
            
            echo "<tr>
                    <td>{$id}</td>
                    <td>{$title}</td>
                    <td>{$genres}</td>
                    <td>{$authors}</td>
                    <td>{$publishinghouse}</td>
                    <td>{$formattedRating}</td>
                  </tr>";
        }
        
?>
</table>
</body>
</html>
<?php
sqlsrv_close($conn);
?>