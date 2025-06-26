# deploy-app
Toate scripturile vor fi adăugate în acest repo. De asemenea configurația pentru docker-compose.yml.
Pentru pornirea containerelor trebuie să fie instalat și activat serviciul docker pe mașină, după care 
se poate folosi comanda docker compose up -d.
Configurațiile tool-urilor în particular nu sunt definite sub formă de cod, și se află pe mașina locală.

În Jenkins sunt necesare configurarea următoarelor plugin-uri:
- se descarcă implicit plugin-urile recomandate la pornirea Jenkins-ului prima dată
- Docker plugin
- Configure as Code
- Gitea plugin
- Generic Webhook Trigger
- SonarQubeScanner
- Maven plugin
- Prometheus Metrics plugin
- DSL plugin
- Rebuilder plugin
- Authorize Project
- Parameterized plugin
- Extended Email plugin

Trebuie generat un job freestyle în jenkins, configurat să asculte la DSL (pentru ca acestea să fie create din cod)
La Build Steps trebuie selectat "Process Job DSLs" și setată opțiunea "Look on Filesystem", căreia
îi vom da valoarea "jobs/*.groovy" (pentru a asculta la toate fișierele groovy din folder-ul job)
Configurațiile de sistem și credențialele trebuie gestionate personal.
