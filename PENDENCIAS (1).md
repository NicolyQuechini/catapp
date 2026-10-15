# Pendências e pontos a validar

Lista do que ainda falta ou não foi confirmado. Marque `[x]` ao concluir.

## Entrega

- [ ] Tirar os prints de todas as telas (Onboarding, Descobrir, Raças, Detalhe da raça, Votar,
      Favoritos, Perfil) e salvar em `docs/prints/`.
- [ ] Conferir que a chave da API **não** está escrita no código antes do commit
      (`defaultValue` de `lib/config.dart` deve ser `'DEMO-API-KEY'`).
- [ ] Garantir que `env.json` (se existir) está no `.gitignore`.
- [ ] Rodar `flutter analyze` e corrigir os avisos restantes.
- [ ] Preencher a URL do repositório no `README.md` (`git clone <URL-DO-REPOSITORIO>`).

## A confirmar com testes

- [ ] **Envio de foto no celular** depois da correção do `content-type` (erro anterior:
      "That file type is not supported"). Testar com JPG e PNG.
- [ ] **Apagar foto** (`DELETE /images/{id}`): a documentação não diz se a API permite apagar fotos
      já aprovadas/públicas. Testar com uma foto em análise e uma aprovada.
- [ ] **Situação "Em análise"**: a API costuma concluir a análise em poucos segundos; confirmar que o
      app mostra "Em análise" quando `/images/{id}/status` devolve `to_be_reviewed`.
- [ ] Formato real das respostas de `POST /favourites` e `GET /images/{id}/status` (a documentação
      não detalha; o cliente aceita formatos parecidos).
- [ ] Filtro por categoria usa o parâmetro `category_ids` em `/images/search`, que **não consta na
      documentação** técnica. Confirmar com chave real.
- [ ] `GET /votes` e `GET /favourites`: a especificação cita autenticação `bearer`, mas o app usa
      `x-api-key` (funcionou nos testes com chave válida; confirmar em todas as contas).
- [ ] Filtros Calmas/Ativas/Sociáveis e barras do detalhe: confirmar se a conta usada recebe os
      níveis numéricos (1 a 5) ou só o `temperament`.
- [ ] Testar no celular: onboarding, votar por deslize, favoritar, "Já tenho uma conta" com o código.

## Limitações conhecidas

- [ ] **Fato do dia** não usa a API (endpoint `/facts` retorna 403 no plano Free); usa lista local.
- [ ] Chip "Engraçados" do wireframe não existe (não é categoria da API).
- [ ] As fotos enviadas só aparecem em "Minhas fotos" no aparelho que as enviou (ids ficam salvos
      localmente); ao entrar com o código em outro aparelho, só votos e favoritos voltam.
- [ ] Contadores de votos e favoritos carregam no máximo 500 registros cada (5 páginas de 100).
- [ ] A chave da API fica dentro do APK; para publicar, usar um servidor intermediário.
- [ ] Rodar no navegador (web) não é suportado (CORS).
- [ ] iOS não foi testado (falta `NSPhotoLibraryUsageDescription` no `Info.plist`).
- [ ] Fotos em formatos como HEIC/HEIF podem ser recusadas pela API no envio.
- [ ] Não há testes automatizados.
- [ ] Os modelos `CatFact`, `HealthTip` e `CatColour` seguem a documentação, mas nenhuma tela os usa.

## Melhorias possíveis

- [ ] Mostrar o motivo exato da recusa/aprovação da foto (ex.: "Recusada · unsafe").
- [ ] Botão de atualizar a situação das fotos enviadas.
- [ ] Usar `/breeds/{id}/colours`, dicas de saúde e fatos por raça se o plano permitir.
- [ ] Tela de detalhe de foto em tamanho grande.
- [ ] Testes de modelo (`fromJson`) e de widget.
