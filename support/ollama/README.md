# Analiza przez Ollama

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


W ustawieniach wybierz **Ollama (HTTP / lokalny model)**. Ustaw:

- Serwer: domyślnie `http://localhost:11434`.
- Model: dokładna nazwa modelu zainstalowanego w Ollama, widoczna w `ollama list`.
- Lista modeli pobiera się w tle po otwarciu ustawień z wybraną Ollamą,
  wybraniu Ollamy jako dostawcy lub opuszczeniu pola zmienianego adresu.
  Przycisk **Odśwież modele** ponawia sprawdzenie serwera. Lista jest
  sortowana i pozbawiona duplikatów; można wybrać model z dropdownu.
  Pole pozostaje edytowalne, aby zachować ręcznie wpisane i starsze ustawienia.
  Nieobecny zapisany model nie jest automatycznie zastępowany innym.
- Kontekst: domyślnie 32768 tokenów; dopasuj do modelu i dostępnej pamięci.
- Limit czasu: wspólne ustawienie Codex/Ollama, 1–1800 sekund. Wczytanie modelu
  do pamięci również wlicza się do tego czasu.

Ollama musi już działać i mieć model. FDR nie instaluje modeli, nie uruchamia
serwera i nie wymaga klucza Gemini ani Codex CLI dla tej opcji. Można wskazać
inny serwer HTTP/HTTPS albo prefiks ścieżki reverse proxy. Pole URL przyjmuje
adres bazowy lub końcówkę `/api/chat`, bez query i danych logowania.
Wybór zdalnego serwera oznacza wysyłanie do niego kontekstu lotu.

```ini
[ai]
provider=ollama
ollama_url=http://localhost:11434
ollama_model=NAZWA_Z_OLLAMA_LIST
ollama_context_tokens=32768
timeout_seconds=180
```

Nazwa w przykładzie jest miejscem do uzupełnienia, nie nazwą pobieranego modelu.
Kontekst jest ograniczany w aplikacji do 2048–262144 tokenów. Ustawienie nie
gwarantuje, że dany model obsłuży taki rozmiar ani że zmieści się w pamięci.
FDR nie liczy tokenów modelem Ollama i nie zapewnia wykrycia obcięcia promptu
przez serwer. Większy kontekst trzeba dopasować do objętości danych analizy.

## Zachowanie

`analysis/OllamaAnalysisU.pas` wywołuje natywne WinHTTP; nie wymaga dodatkowego EXE
klienta. Żądanie `POST /api/chat` zawiera model, ten sam polski prompt co
pozostałe silniki, `stream=false` i `options.num_ctx`. Wynikiem jest wyłącznie
`message.content`, bez osobnego tekstu rozumowania modelu. Raport przechodzi
przez dotychczasowy zapis w bazie i renderowanie Markdown.

Żądanie działa w tle. Limit czasu i anulowanie zamykają aktywne żądanie HTTP,
również podczas oczekiwania na pierwszy bajt. Nie ma automatycznego ponawiania
ani przełączenia do innego silnika. Błędy HTTP/API, niepoprawny JSON, brak
końcowego `done=true`, brak wiadomości i pusty raport są zgłaszane jako błąd.
Klient nie obsługuje uwierzytelniania i korzysta z bezpośredniego połączenia
bez systemowego proxy. Maksymalna odpowiedź wynosi 16 MB.

Raport już zapisany dla zdarzenia nadal otwiera się z bazy. Aby ponowić analizę
po zmianie silnika lub modelu, użyj Shift podczas kliknięcia analizy.

## Weryfikacja

`VerifyOllama.dpr` używa lokalnego serwera testowego na losowym porcie:
polskie znaki w obu kierunkach, kontrakt POST i `stream=false`, `num_ctx`,
prefiks URL, tekst Markdown bez `thinking`, błędy odpowiedzi, timeout,
anulowanie i odczyt/zapis ustawień w formularzu DFM. Nie pobiera modelu
i nie wysyła zapytania do prawdziwego serwera Ollama ani do chmury.
Nie jest to test jakości analizy wybranego modelu.

Kontrakt API: [oficjalna dokumentacja Ollama](https://docs.ollama.com/api/chat).

Lista korzysta z [GET /api/tags](https://docs.ollama.com/api/tags), z limitem
5 sekund i obsługą anulowania przy zamykaniu ustawień. Pusta lista jest
odróżniana od błędu połączenia. Odpowiedź poprzedniego adresu nie zastępuje
listy nowego serwera. Zapytanie nie pobiera ani nie uruchamia modeli.
`VerifyOllamaModels` sprawdza API i formularz na lokalnym serwerze testowym:
sortowanie, duplikaty, puste/błędne odpowiedzi, zachowanie wyboru, zmianę
adresu oraz bezpieczne zakończenie pobierania podczas zamykania okna.
