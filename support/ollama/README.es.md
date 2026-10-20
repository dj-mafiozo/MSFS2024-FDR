# Análisis con Ollama

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Seleccione Ollama (HTTP / modelo local) en Ajustes → Proveedores de IA. El servidor predeterminado es `http://localhost:11434`; debe estar activo y tener un modelo instalado. FDR no inicia servidores ni instala modelos. No necesita clave Gemini ni EXE Codex. Un servidor remoto recibe el contexto del vuelo.

GET /api/tags busca modelos en segundo plano al abrir ajustes Ollama, elegir proveedor o salir de una URL modificada. Actualizar modelos repite la consulta. La lista está ordenada, sin duplicados y permite edición; no sustituye silenciosamente un modelo guardado ausente. La petición tiene cinco segundos de límite, distingue lista vacía de error y descarta respuestas de una URL anterior. Cerrar ajustes cancela la descarga.

```ini
[ai]
provider=ollama
ollama_url=http://localhost:11434
ollama_model=NOMBRE_DE_OLLAMA_LIST
ollama_context_tokens=32768
timeout_seconds=180
```

El nombre es un marcador. Contexto: 2048–262144 tokens, predeterminado 32768; ajústelo al modelo y memoria. FDR no cuenta tokens con su tokenizador ni detecta todos los recortes del servidor. El límite compartido con Codex es de 1–1800 s e incluye cargar el modelo. La URL admite HTTP/HTTPS, prefijo de proxy inverso o /api/chat, sin consulta, fragmentos ni credenciales.

WinHTTP nativo envía POST /api/chat con modelo, tarea explícita en polaco/contexto, stream=false y options.num_ctx. Solo message.content se guarda como Markdown; se omite thinking separado. La petición en segundo plano admite límite y cancelación, incluida la espera del primer byte. No hay reintento ni cambio de proveedor automático. Se notifican errores HTTP/API, JSON inválido/incompleto, falta de done=true/message e informes vacíos. No hay autenticación ni proxy del sistema; respuesta máxima de 16 MB.

Los informes existentes se abren desde la base de datos. Tras cambiar modelo/proveedor use Mayús+clic para regenerarlos. VerifyOllama y VerifyOllamaModels usan un servidor HTTP local para UTF-8, contrato, contexto, prefijos, Markdown, errores, cancelación, listas y persistencia. No ejecutan un modelo real ni evalúan la calidad de sus conclusiones. API: https://docs.ollama.com/api/chat y https://docs.ollama.com/api/tags.
