#!/bin/bash

# Script de configuración automática para Mac
# Servidor MCP de Microsoft SQL Server

set -e

echo "🚀 Configuración Automática - SQL Server MCP para Mac"
echo "=================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes coloreados
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar prerrequisitos
print_status "Verificando prerrequisitos..."

# Verificar Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado. Instálalo desde: https://docker.com"
    exit 1
fi

if ! docker info &> /dev/null; then
    print_error "Docker no está corriendo. Inicia Docker Desktop."
    exit 1
fi

print_success "Docker está corriendo"

# Verificar docker-compose
if ! command -v docker-compose &> /dev/null; then
    print_error "docker-compose no está instalado"
    exit 1
fi

print_success "docker-compose encontrado"

# Crear archivo .env si no existe
if [ ! -f .env ]; then
    print_status "Creando archivo .env con configuración por defecto..."
    cat > .env << EOF
# Configuración SQL Server
MSSQL_PASSWORD=StrongPassword123!
MSSQL_DATABASE=TestDB
MSSQL_USER=sa
MSSQL_SERVER=mssql
MSSQL_PORT=1433
HOST_SQL_PORT=1434

# Configuración del contenedor
SQL_MEMORY_LIMIT=2g
EOF
    print_success "Archivo .env creado"
else
    print_warning "Archivo .env ya existe, usando configuración existente"
fi

# Instalar dependencias de Python para pruebas locales
print_status "Verificando dependencias de Python..."

if command -v brew &> /dev/null; then
    print_status "Instalando freetds con Homebrew..."
    brew install freetds || print_warning "freetds ya podría estar instalado"
else
    print_warning "Homebrew no encontrado. Instálalo desde: https://brew.sh"
fi

# Instalar pymssql para pruebas
print_status "Instalando pymssql..."
pip3 install pymssql mcp || print_warning "Error instalando dependencias Python"

# Levantar servicios con Docker
print_status "Levantando servicios con Docker Compose..."
docker-compose up -d

# Esperar a que SQL Server esté listo
print_status "Esperando a que SQL Server esté listo..."
sleep 30

# Verificar que los servicios estén corriendo
print_status "Verificando servicios..."
if docker-compose ps | grep -q "Up"; then
    print_success "Servicios están corriendo"
else
    print_error "Error levantando servicios"
    docker-compose logs
    exit 1
fi

# Crear base de datos de prueba
print_status "Creando base de datos de prueba..."
docker-compose exec -T mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "${MSSQL_PASSWORD:-StrongPassword123!}" -Q "IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'TestDB') CREATE DATABASE TestDB" || print_warning "Error creando base de datos"

# Probar conexión
print_status "Probando conexión..."
python3 test_setup.py

# Mostrar información de configuración para Claude Desktop
print_success "¡Configuración completada!"
echo ""
print_status "Configuración para Claude Desktop:"
echo ""
echo "Archivo: ~/Library/Application Support/Claude/claude_desktop_config.json"
echo ""
echo '{'
echo '  "mcpServers": {'
echo '    "mssql": {'
echo '      "command": "uvx",'
echo '      "args": ["microsoft_sql_server_mcp"],'
echo '      "env": {'
echo '        "MSSQL_SERVER": "localhost",'
echo '        "MSSQL_DATABASE": "TestDB",'
echo '        "MSSQL_USER": "sa",'
echo '        "MSSQL_PASSWORD": "StrongPassword123!",'
echo '        "MSSQL_PORT": "1434"'
echo '      }'
echo '    }'
echo '  }'
echo '}'
echo ""
print_status "Servicios corriendo en:"
print_status "- SQL Server: localhost:1434"
print_status "- Usuario: sa"
print_status "- Contraseña: StrongPassword123!"
print_status "- Base de datos: TestDB"
echo ""
print_success "¡Ya puedes usar el servidor MCP con Claude Desktop!" 