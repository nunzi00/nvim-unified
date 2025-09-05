return {
  "phpactor/phpactor",
  branch = "master",
  ft = "php", -- lo carga solo en buffers PHP
  build = "composer install --no-dev -o", -- instala dependencias
}

