# Analysis through Ollama

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Choose Ollama (HTTP / local model) in Settings. Default server: http://localhost:11434. Select an installed model by its exact name. Models are discovered in the background on opening Ollama settings, selecting the provider or leaving a changed URL. Refresh models retries. The sorted/deduplicated combo remains editable and preserves a saved model absent from the server, with feedback instead of silent substitution.

Context defaults to 32768 tokens, bounded to 2048–262144. Choose a size supported by the model and available memory; the recorder does not tokenize with that model or detect every server-side truncation. Timeout is shared with Codex, 1–1800 seconds, including model loading. Ollama must already run with a model installed; FDR neither starts the server nor downloads models. No Gemini key or Codex executable is needed. A remote endpoint receives the flight context.

Settings: [ai] provider=ollama, ollama_url=http://localhost:11434, ollama_model=<installed-name>, ollama_context_tokens=32768, timeout_seconds=180. The URL may include a reverse-proxy prefix or /api/chat, but no query or credentials.

Native WinHTTP sends POST /api/chat with model, an explicit Polish analysis task/context, stream=false and options.num_ctx. Only message.content becomes the Markdown report; separate thinking is omitted. Requests run in the background. Timeout/cancellation closes the active HTTP request, including first-byte waits. There is no retry or fallback provider. HTTP/API errors, invalid/incomplete JSON, missing done=true/message and empty reports fail explicitly. Authentication/system proxy are unsupported; maximum response is 16 MB.

Existing reports open from the database. Shift+click analysis regenerates after changing provider/model. GET /api/tags uses a five-second limit and cancellation during settings closure. Empty lists are distinct from connection failures; a response from the previous URL cannot replace the new server's models.

VerifyOllama and VerifyOllamaModels use a local fixture HTTP server: UTF-8, request contract, context options, path prefix, Markdown, errors, timeout, cancellation, sorting, stale URL isolation, selection and form persistence. No actual model/channels/cloud quality test is performed. API references: https://docs.ollama.com/api/chat and https://docs.ollama.com/api/tags.
