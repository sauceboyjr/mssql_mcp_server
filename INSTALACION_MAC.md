# 🚀 Guía de Instalación para Mac - Servidor MCP de SQL Server

Esta guía te ayudará a configurar un servidor MCP (Model Context Protocol) para Microsoft SQL Server en tu Mac usando Docker.

## ¿Qué es esto?

El **Servidor MCP de SQL Server** permite que **Claude Desktop** se conecte de manera segura a bases de datos SQL Server y ejecute consultas. Es como un puente que permite a Claude interactuar con tus datos de SQL Server.

## 📋 Prerrequisitos

- ✅ **macOS** (cualquier versión reciente)
- ✅ **Docker Desktop** instalado y corriendo
- ✅ **Homebrew** (recomendado para dependencias)
- ✅ **Claude Desktop** instalado

## 🎯 Instalación Rápida (Automática)

### Opción 1: Script Automático

```bash
# Ejecutar el script de configuración automática
./setup_mac.sh
```

Este script hará todo automáticamente:
- ✅ Verificar prerrequisitos
- ✅ Crear configuración por defecto
- ✅ Instalar dependencias
- ✅ Levantar SQL Server con Docker
- ✅ Probar la conexión
- ✅ Mostrar configuración para Claude Desktop

## 🔧 Instalación Manual (Paso a Paso)

### Paso 1: Preparar el Entorno

```bash
# Instalar dependencias con Homebrew
brew install freetds

# Instalar dependencias de Python
pip3 install pymssql mcp
```

### Paso 2: Configurar Variables de Entorno

Crea un archivo `.env`:

```bash
# Configuración SQL Server
MSSQL_PASSWORD=StrongPassword123!
MSSQL_DATABASE=TestDB
MSSQL_USER=sa
MSSQL_SERVER=mssql
MSSQL_PORT=1433
HOST_SQL_PORT=1434

# Configuración del contenedor
SQL_MEMORY_LIMIT=2g
```

### Paso 3: Levantar SQL Server

```bash
# Levantar todos los servicios
docker-compose up -d

# Solo SQL Server (si prefieres ejecutar el MCP localmente)
docker-compose up -d mssql
```

### Paso 4: Verificar Instalación

```bash
# Probar conexión
python3 test_setup.py

# Verificar servicios Docker
docker-compose ps

# Ver logs si hay problemas
docker-compose logs
```

## 🔌 Configuración de Claude Desktop

### Ubicación del Archivo de Configuración

En Mac, edita este archivo:
```
~/Library/Application Support/Claude/claude_desktop_config.json
```

### Configuración para Conexión Dockerizada

```json
{
  "mcpServers": {
    "mssql": {
      "command": "uvx",
      "args": ["microsoft_sql_server_mcp"],
      "env": {
        "MSSQL_SERVER": "localhost",
        "MSSQL_DATABASE": "TestDB",
        "MSSQL_USER": "sa",
        "MSSQL_PASSWORD": "StrongPassword123!",
        "MSSQL_PORT": "1434"
      }
    }
  }
}
```

### Configuración para Servidor Remoto

Si tienes un SQL Server remoto:

```json
{
  "mcpServers": {
    "mssql": {
      "command": "uvx",
      "args": ["microsoft_sql_server_mcp"],
      "env": {
        "MSSQL_SERVER": "tu-servidor.com",
        "MSSQL_DATABASE": "TuBaseDeDatos",
        "MSSQL_USER": "tu_usuario",
        "MSSQL_PASSWORD": "tu_contraseña",
        "MSSQL_PORT": "1433",
        "MSSQL_ENCRYPT": "true"
      }
    }
  }
}
```

## 🧪 Comandos de Prueba

### Probar Conexión Básica

```python
import pymssql

# Configuración
config = {
    "server": "localhost",
    "port": 1434,
    "user": "sa", 
    "password": "StrongPassword123!",
    "database": "TestDB"
}

# Conectar y probar
conn = pymssql.connect(**config)
cursor = conn.cursor()
cursor.execute("SELECT @@VERSION")
print(cursor.fetchone())
```

### Comandos Docker Útiles

```bash
# Ver contenedores corriendo
docker-compose ps

# Ver logs de SQL Server
docker-compose logs mssql

# Conectar directamente al contenedor SQL Server
docker exec -it mssql_mcp_server-mssql-1 bash

# Parar servicios
docker-compose down

# Reiniciar servicios
docker-compose restart
```

## 🔍 Uso con Claude Desktop

Una vez configurado, puedes preguntar a Claude:

- 📊 **"¿Qué tablas tienes disponibles?"**
- 📈 **"Muéstrame los datos de la tabla usuarios"**
- 💾 **"Ejecuta esta consulta: SELECT * FROM productos WHERE precio > 100"**
- 🔧 **"Crea una tabla llamada pedidos con estas columnas..."**

## 🚨 Solución de Problemas

### SQL Server no inicia

```bash
# Verificar memoria disponible
docker stats

# Verificar logs
docker-compose logs mssql

# Reiniciar con más memoria
export SQL_MEMORY_LIMIT=4g
docker-compose up -d mssql
```

### Error de conexión desde Python

```bash
# Verificar puerto
lsof -i :1434

# Reinstalar dependencias
brew reinstall freetds
pip3 uninstall pymssql
pip3 install pymssql
```

### Claude Desktop no se conecta

1. ✅ Verificar que el archivo de configuración existe
2. ✅ Verificar que `uvx` está instalado: `pipx install uv`
3. ✅ Reiniciar Claude Desktop
4. ✅ Verificar logs en la consola de Claude

### Problemas de permisos

```bash
# Si hay problemas con Docker
sudo chown -R $(whoami) /var/run/docker.sock

# Si hay problemas con archivos
chmod +x setup_mac.sh test_setup.py
```

## 📱 Configuración Avanzada

### Usar Azure SQL Database

```json
{
  "mcpServers": {
    "mssql": {
      "command": "uvx",
      "args": ["microsoft_sql_server_mcp"],
      "env": {
        "MSSQL_SERVER": "tu-servidor.database.windows.net",
        "MSSQL_DATABASE": "TuBaseDeDatos",
        "MSSQL_USER": "tu_usuario",
        "MSSQL_PASSWORD": "tu_contraseña",
        "MSSQL_ENCRYPT": "true"
      }
    }
  }
}
```

### Usar Autenticación Windows (LocalDB)

```json
{
  "mcpServers": {
    "mssql": {
      "command": "uvx", 
      "args": ["microsoft_sql_server_mcp"],
      "env": {
        "MSSQL_SERVER": "(localdb)\\MSSQLLocalDB",
        "MSSQL_DATABASE": "TuBaseDeDatos",
        "MSSQL_WINDOWS_AUTH": "true"
      }
    }
  }
}
```

## 🔐 Consideraciones de Seguridad

- 🚫 **No uses credenciales de administrador** (sa) en producción
- ✅ **Crea usuarios específicos** con permisos mínimos necesarios
- 🔐 **Usa autenticación Windows** cuando sea posible
- 🔒 **Habilita cifrado** para datos sensibles
- 🌐 **Limita acceso de red** solo a IPs necesarias

## 📚 Recursos Adicionales

- [Documentación MCP](https://modelcontextprotocol.io/)
- [Claude Desktop](https://claude.ai/desktop)
- [Docker para Mac](https://docs.docker.com/desktop/mac/)
- [SQL Server en Docker](https://hub.docker.com/_/microsoft-mssql-server)

---

¡Ahora tienes SQL Server funcionando con Claude Desktop en tu Mac! 🎉 