#!/bin/bash

echo "🧪 Probando integración completa de la aplicación..."

# Verificar que el backend esté funcionando
echo "1. Verificando backend..."
BACKEND_RESPONSE=$(curl -s http://localhost:8080)
if [[ $BACKEND_RESPONSE == *"ok"* ]]; then
    echo "✅ Backend funcionando correctamente"
else
    echo "❌ Backend no está funcionando. Inicia con: cd ../FastMCP+R1 && sudo docker compose up -d"
    exit 1
fi

# Crear usuario de prueba
echo ""
echo "2. Creando usuario de prueba..."
USER_RESPONSE=$(curl -s -X POST http://localhost:8080/v1/users)
USER_ID=$(echo $USER_RESPONSE | jq -r '.user_id' 2>/dev/null)

if [ "$USER_ID" != "null" ] && [ "$USER_ID" != "" ]; then
    echo "✅ Usuario creado: $USER_ID"
else
    echo "❌ Error creando usuario"
    exit 1
fi

# Probar recomendaciones sin estado de ánimo
echo ""
echo "3. Probando recomendaciones sin estado de ánimo..."
RECS_RESPONSE=$(curl -s "http://localhost:8080/v1/recommendations?user_id=$USER_ID&limit=2")
if [[ $RECS_RESPONSE == *"results"* ]]; then
    echo "✅ Recomendaciones funcionando"
    echo "   Películas encontradas: $(echo $RECS_RESPONSE | jq '.results | length')"
else
    echo "❌ Error en recomendaciones"
fi

# Probar recomendaciones con estado de ánimo
echo ""
echo "4. Probando recomendaciones con estado de ánimo 'feliz'..."
MOOD_RESPONSE=$(curl -s "http://localhost:8080/v1/recommendations?user_id=$USER_ID&limit=2&mood=feliz")
if [[ $MOOD_RESPONSE == *"results"* ]]; then
    echo "✅ Recomendaciones con estado de ánimo funcionando"
    echo "   Películas encontradas: $(echo $MOOD_RESPONSE | jq '.results | length')"
else
    echo "❌ Error en recomendaciones con estado de ánimo"
fi

# Probar búsqueda
echo ""
echo "5. Probando búsqueda de películas..."
SEARCH_RESPONSE=$(curl -s "http://localhost:8080/v1/search?q=avengers&type=movie")
if [[ $SEARCH_RESPONSE == *"results"* ]]; then
    echo "✅ Búsqueda funcionando"
    echo "   Resultados encontrados: $(echo $SEARCH_RESPONSE | jq '.results | length')"
else
    echo "❌ Error en búsqueda"
fi

echo ""
echo "🎉 ¡Todas las pruebas completadas!"
echo ""
echo "📱 Para probar la app:"
echo "   1. Instala la APK en tu dispositivo/emulador"
echo "   2. La app debería conectarse automáticamente al backend"
echo "   3. Prueba seleccionar diferentes estados de ánimo"
echo "   4. Prueba la búsqueda de películas"
echo ""
echo "🔧 Si hay problemas de conexión:"
echo "   - Verifica que el emulador use 10.0.2.2:8080"
echo "   - Para dispositivo físico, cambia la IP en ApiConfig.kt"

