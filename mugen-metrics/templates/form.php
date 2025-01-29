<?php
// Recoger los datos del formulario
$minYear = $_POST['min_year'] ?? 1940;
$maxYear = $_POST['max_year'] ?? 2024;
$minKm = $_POST['min_km'] ?? 1;
$maxKm = $_POST['max_km'] ?? 300000;
$minSalePrice = $_POST['min_sale_price'] ?? 1;
$maxSalePrice = $_POST['max_sale_price'] ?? 90000;
$keywords = $_POST['keywords'] ?? "";
$gearbox = $_POST['gearbox_types'] ?? 'automatic,manual';
$engine = $_POST['engine_types'] ?? 'gasoline,gasoil';
$brand = $_POST['brand'] ?? "";
$model = $_POST['model'] ?? "";
$latitude = $_POST['latitude'] ?? 40.578494;
$longitude = $_POST['longitude'] ?? -3.892771;
$minHorsepower = $_POST['min_horsepower'] ?? 1;
$maxHorsepower = $_POST['max_horsepower'] ?? 1000;

// Validación de los datos recibidos
echo '<pre>';
print_r($_POST);  // Muestra todos los datos que se están enviando por POST
echo '</pre>';

// Convertir arrays (gearbox y engine) en cadenas de texto separadas por comas
$gearbox = !empty($gearbox) ? implode(',', (array)$gearbox) : 'automatic,manual';
$engine = !empty($engine) ? implode(',', (array)$engine) : 'gasoline,gasoil';

// Construir el comando para ejecutar el script de Python
$command = "python3 /usr/share/nginx/html/templates/scripts/script_python.py " . 
    escapeshellarg($minYear) . " " . escapeshellarg($maxYear) . " " . 
    escapeshellarg($minKm) . " " . escapeshellarg($maxKm) . " " . 
    escapeshellarg($minSalePrice) . " " . escapeshellarg($maxSalePrice) . " " . 
    escapeshellarg($keywords) . " " . 
    escapeshellarg($gearbox) . " " . 
    escapeshellarg($engine) . " " . 
    escapeshellarg($brand) . " " . 
    escapeshellarg($model) . " " . 
    escapeshellarg($latitude) . " " . 
    escapeshellarg($longitude) . " " . 
    escapeshellarg($minHorsepower) . " " . 
    escapeshellarg($maxHorsepower);

// Ejecutar el script de Python y capturar la salida
$output = shell_exec($command . ' 2>&1');  // Redirige los errores al mismo flujo de salida

// Mostrar la salida del script Python
echo "<pre>$output</pre>";
?>
