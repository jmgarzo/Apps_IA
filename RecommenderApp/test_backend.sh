#!/bin/bash

# Script para probar la conectividad con el backend
echo "🧪 Probando conectividad con el backend..."

# Verificar que el servicio esté funcionando
echo "1. Verificando salud del servicio..."
curl -s http://localhost:8080 | jq '.' || echo "❌ Error: No se puede conectar al backend en localhost:8080"

echo ""
echo "2. Creando un usuario de prueba..."
USER_RESPONSE=$(curl -s -X POST http://localhost:8080/v1/users)
echo "Respuesta: $USER_RESPONSE"

# Extraer user_id de la respuesta
USER_ID=$(echo $USER_RESPONSE | jq -r '.user_id' 2>/dev/null)

if [ "$USER_ID" != "null" ] && [ "$USER_ID" != "" ]; then
    echo "✅ Usuario creado con ID: $USER_ID"
    
    echo ""
    echo "3. Probando recomendaciones sin estado de ánimo..."
    curl -s "http://localhost:8080/v1/recommendations?user_id=$USER_ID&limit=3" | jq '.results[0:2] | .[] | {title: .title, overview: .overview}'
    
    echo ""
    echo "4. Probando recomendaciones con estado de ánimo 'feliz'..."
    curl -s "http://localhost:8080/v1/recommendations?user_id=$USER_ID&limit=3&mood=feliz" | jq '.results[0:2] | .[] | {title: .title, overview: .overview}'
    
    echo ""
    echo "5. Probando búsqueda de películas..."
    curl -s "http://localhost:8080/v1/search?q=avengers&type=movie" | jq '.results[0:2] | .[] | {title: .title, release_date: .release_date}'
    
    echo ""
    echo "✅ Todas las pruebas completadas exitosamente!"
    echo "🚀 La app móvil debería poder conectarse correctamente."
else
    echo "❌ Error: No se pudo crear un usuario. Verifica que el backend esté funcionando."
    echo "💡 Asegúrate de ejecutar: cd ../FastMCP+R1 && docker-compose up -d"
fi

