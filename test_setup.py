#!/usr/bin/env python3
"""
Script de prueba para verificar la conexión a SQL Server
"""
import os
import pymssql
import sys

def test_connection():
    """Prueba la conexión a SQL Server"""
    config = {
        "server": os.getenv("MSSQL_SERVER", "localhost"),
        "port": int(os.getenv("MSSQL_PORT", "1434")),
        "user": os.getenv("MSSQL_USER", "sa"),
        "password": os.getenv("MSSQL_PASSWORD", "TuPassword123!"),
        "database": os.getenv("MSSQL_DATABASE", "master"),
    }
    
    print(f"🔗 Intentando conectar a {config['server']}:{config['port']}")
    print(f"👤 Usuario: {config['user']}")
    print(f"🗄️  Base de datos: {config['database']}")
    
    try:
        conn = pymssql.connect(**config)
        cursor = conn.cursor()
        
        # Prueba básica
        cursor.execute("SELECT @@VERSION")
        version = cursor.fetchone()
        print(f"✅ Conexión exitosa!")
        print(f"📊 Versión SQL Server: {version[0][:50]}...")
        
        # Crear base de datos de prueba si no existe
        cursor.execute(f"IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = '{config['database']}')")
        cursor.execute(f"CREATE DATABASE [{config['database']}]")
        conn.commit()
        
        print(f"🗄️  Base de datos '{config['database']}' verificada/creada")
        
        cursor.close()
        conn.close()
        return True
        
    except Exception as e:
        print(f"❌ Error de conexión: {str(e)}")
        print("\n🔧 Posibles soluciones:")
        print("1. Verificar que Docker esté corriendo: docker ps")
        print("2. Verificar el puerto: docker-compose logs mssql")
        print("3. Verificar la contraseña en el archivo .env")
        return False

def install_dependencies():
    """Instala las dependencias necesarias en Mac"""
    print("🍺 Instalando dependencias para Mac...")
    
    # Verificar si brew está instalado
    import subprocess
    try:
        subprocess.run(["brew", "--version"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Homebrew no está instalado. Instálalo desde: https://brew.sh")
        return False
    
    try:
        # Instalar freetds (requerido para pymssql en Mac)
        subprocess.run(["brew", "install", "freetds"], check=True)
        print("✅ freetds instalado correctamente")
        
        # Instalar pymssql
        subprocess.run([sys.executable, "-m", "pip", "install", "pymssql"], check=True)
        print("✅ pymssql instalado correctamente")
        
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error instalando dependencias: {e}")
        return False

if __name__ == "__main__":
    print("🧪 Script de Prueba - SQL Server MCP")
    print("=" * 40)
    
    # Verificar si pymssql está instalado
    try:
        import pymssql
        print("✅ pymssql ya está instalado")
    except ImportError:
        print("📦 pymssql no encontrado, instalando...")
        if not install_dependencies():
            sys.exit(1)
        import pymssql
    
    # Probar conexión
    if test_connection():
        print("\n🎉 ¡Todo configurado correctamente!")
        print("👆 Ya puedes usar el servidor MCP con Claude Desktop")
    else:
        print("\n🔧 Revisa la configuración y vuelve a intentar")
        sys.exit(1) 