# bzapper

SDK oficial em **Ruby** da API do [bZapper](https://bzapper.com.br) (WhatsApp): mensagens de
todos os tipos (e OTP), números e QR, grupos, conversas, contatos, campanhas, webhooks com
verificação de assinatura e o **bZapper Connect**.

Zero dependências de runtime (só biblioteca padrão: `net/http`, `json`, `openssl`,
`securerandom`) · Ruby 3.0+ · novas tentativas e idempotência automáticas.

## Instalação

```bash
gem install bzapper -v 0.8.0
```

Ou no `Gemfile` — **fixe a versão exata** (cada release declara se muda a superfície pública):

```ruby
gem "bzapper", "0.8.0"
```

## Hello world

```ruby
require "bzapper"

client = Bzapper::Client.new(ENV.fetch("BZAPPER_API_KEY"))

sent = client.messages.send_text(to: "+5511999999999", body: "Olá do bZapper!")
puts sent["message_id"], sent["status"] # => "queued"
```

Só `to` é obrigatório além do conteúdo: sem `instance_id`, o bZapper escolhe o número do seu
pool (rotação + afinidade de conversa). `to` é um telefone E.164 (`+5511999999999`) ou um JID.

## Autenticação

Crie a chave no painel do bZapper em **Chaves de API** (`bz_live_...`). Ela vai em
`Authorization: Bearer <chave>` em toda requisição — a SDK cuida disso. A chave já carrega o
projeto dela; numa chave de conta, escolha o projeto com `project_id:`.

```ruby
client = Bzapper::Client.new(
  "bz_live_...",
  base_url: "https://api.bzapper.com.br", # padrão; em dev: "http://localhost:8080"
  timeout: 30,                             # segundos, por tentativa
  max_retries: 2,                          # novas tentativas além da primeira (0 desliga)
  locale: "pt-BR",                         # Accept-Language: mensagens de erro traduzidas
  project_id: "…"                          # X-Project-Id: escopo de projeto
)
```

Construir o cliente não faz nenhuma chamada de rede. Um cliente pode ser compartilhado entre
threads.

### Trocar a chave sem derrubar a integração (rotação)

`rotate_my_key` (admin) cria uma chave **nova** herdando papel, escopos, projeto e nome da
antiga, e mantém a antiga funcionando por um período de graça — dá tempo de fazer o deploy sem
janela de erro. A chave crua aparece **uma única vez**, no retorno. Depois do prazo a antiga
responde `401 key_expired`; `revoke_in_seconds: 0` revoga na hora (padrão 86400 s, máximo 30
dias). Chave de parceiro (bZapper Connect) roda pelo `PartnerClient#rotate_partner_connection_key`.

```ruby
rotated = client.accounts.rotate_my_key(key_id, revoke_in_seconds: 3600) # 1 h de graça

rotated["api_key"]                 # a chave NOVA, crua — guarde agora, não volta
rotated["key"]["id"]               # metadados da nova
rotated["previous_key"]["expires_at"] # quando a antiga para de funcionar (nil se revogada já)
rotated["old_key_expires_at"]      # o mesmo instante, no topo do retorno
rotated["previous_key"]["rotated_to"] # id da chave que substituiu a antiga
```

Uma chave já revogada ou já vencida responde `409` (`key_already_revoked` /
`key_already_expired`).

## Como os métodos funcionam

Os métodos ficam em **recursos**, um por área da API, e se chamam como o `operationId` da
spec OpenAPI em snake_case (`sendText` → `send_text`):

| Recurso | O que tem |
| --- | --- |
| `client.messages` | `send_text`, `send_image`, `send_video`, `send_document`, `send_audio`, `send_sticker`, `send_location`, `send_contact`, `send_poll`, `send_reaction`, `send_buttons`, `send_list`, `send_otp`, `mark_read`, `presence_chat` |
| `client.scheduling` | `list_scheduled`, `cancel_scheduled` |
| `client.instances` | números: `list_instances`, `create_instance`, `connect_instance` (QR/código), `get_instance`, `disconnect_instance`, `logout_instance`, `clear_instance_session`, `archive_instance`, proxy, filtros de entrada, conta oficial… |
| `client.groups` | `list_groups`, `create_group`, `get_group`, `update_group`, `update_group_participants`, `group_invite_link`, `join_group`, `preview_group_invite`, `leave_group`, pedidos de entrada |
| `client.conversations` | `list_conversations`, `conversation_history` |
| `client.advanced` | editar/apagar/encaminhar mensagem, perfil, privacidade, arquivar/fixar/ler/silenciar chat, etiquetas, bloqueio, chamadas |
| `client.contacts` | CRM (`list_contacts`, `create_contact`, `update_contact`…), `import_contacts` (lote), `export_contacts` (CSV), tags, grupos de contatos, opt-in/out, supressões, `contacts_check` |
| `client.campaigns` | `create_campaign`, `estimate_campaign`, destinatários, `dry_run_campaign`, `start/pause/resume/cancel_campaign` |
| `client.pools` | pools de números |
| `client.webhooks` | `create_webhook`, `update_webhook`, `test_webhook`, `list_webhook_deliveries`… |
| `client.advisories` | avisos "atualize sua integração" |
| `client.usage` / `client.billing` | consumo; plano, assinatura, add-ons, faturas, preços |
| `client.accounts` | perfil, chaves de API (`rotate_my_key`), marca, projetos, usuários |
| `client.connect` | apps parceiros conectados à sua conta |
| `client.system` | `get_health` |

Convenções (iguais em todos os métodos):

* Parâmetros de **caminho** são posicionais (`client.instances.get_instance(id)`); **query** e
  **corpo** são keyword args com os nomes da API (`to:`, `instance_id:`…).
* Campo de corpo que você não passa **não é enviado**. `nil` explícito vai como `null` (num
  PATCH, limpa o campo): `client.contacts.update_contact(id, email: nil)`.
* Filtros de query com `nil` são omitidos; listas vão como CSV; `Time` vira ISO 8601 UTC (`Z`).
* Toda chamada aceita `timeout:`; as escritas aceitam `idempotency_key:`.
* O retorno é o **JSON inteiro** da resposta — `Hash`/`Array` com chaves **string**. Listas
  vêm como `{"data" => [...], ...}` (a SDK não desembrulha, para não perder paginação e
  metadados). Campos novos da API aparecem sem quebrar nada. `204` → `nil`.
* Parâmetro de caminho vazio, `"."` ou `".."` → `ArgumentError` antes de qualquer requisição.
* Uma exceção ao retorno: `client.contacts.export_contacts` devolve **`String`** (o CSV cru),
  porque a rota responde `text/csv` e não JSON.

## Mensagens

```ruby
to = "+5511999999999"
m = client.messages

m.send_text(to: to, body: "Pedido #42 confirmado", idempotency_key: "pedido-42")
m.send_image(to: to, media: { url: "https://picsum.photos/600", caption: "Oi" })
m.send_video(to: to, media: { url: "https://example.com/clip.mp4" })
m.send_document(to: to, media: { url: "https://example.com/nota.pdf", filename: "nota.pdf" })
m.send_audio(to: to, media: { url: "https://example.com/audio.ogg", ptt: true }) # ptt = mensagem de voz
m.send_sticker(to: to, media: { url: "https://example.com/sticker.webp" })
m.send_location(to: to, latitude: -23.5613, longitude: -46.6565, name: "Av. Paulista")
m.send_contact(to: to, contact_name: "Berni Software", contact_vcard: "BEGIN:VCARD…")
m.send_poll(to: to, name: "Pizza ou sushi?", options: %w[Pizza Sushi], selectable_count: 1)
m.send_reaction(to: to, quoted_message_id: "ABCD1234", emoji: "👍") # emoji "" remove
m.send_buttons(to: to, body: "Escolha:", buttons: [{ id: "a", title: "Opção A" }, { id: "b", title: "Opção B" }])
m.send_list(to: to, body: "Cardápio:", button_text: "Abrir",
            sections: [{ title: "Bebidas", rows: [{ id: "1", title: "Café" }, { id: "2", title: "Chá" }] }])

# OTP: o código vai sozinho numa bolha (copiável); o texto de contexto é gerado se omitido.
m.send_otp(to: to, code: "482913", expiry_minutes: 5)

# Agendar: qualquer envio aceita scheduled_at (Time ou RFC 3339).
m.send_text(to: to, body: "Lembrete", scheduled_at: Time.now + 3600)
client.scheduling.list_scheduled

# Presença ("digitando…") e confirmação de leitura
m.presence_chat(instance_id: "…", to: to, state: "typing") # typing, recording, paused
m.mark_read("wa_message_id", instance_id: "…", chat: "5511999999999@s.whatsapp.net")
```

**MediaInput** (`media:`): `{ url:, base64:, caption:, filename:, mimetype:, ptt: }` — use
`url` **ou** `base64`, nunca os dois.

**Botões e listas** não são confiáveis no WhatsApp (pior em grupos): a API **sempre** manda
também um **menu de texto numerado** equivalente. Desenhe o fluxo para funcionar só com ele.

## Números (instâncias) e QR

```ruby
inst = client.instances.create_instance(phone: "+5511999999999", nickname: "Vendas")
qr = client.instances.connect_instance(inst["id"], method: "qr") # ou method: "code" (código de pareamento)
puts qr["qr_code"] || qr["pair_code"]

client.instances.get_instance(inst["id"])["status"] # => "connected"
client.instances.list_instances["data"].each { |i| puts "#{i['phone']} #{i['status']}" }
```

## Grupos e conversas

```ruby
g = client.groups.create_group(instance_id: "…", name: "Clientes VIP", participants: ["+5511988887777"])
client.groups.update_group_participants(g["jid"], instance_id: "…", action: "add", participants: ["+5511977776666"])
client.groups.group_invite_link(g["jid"], instance_id: "…")

client.conversations.list_conversations(instance_id: "…")
client.conversations.conversation_history("5511999999999@s.whatsapp.net", instance_id: "…", limit: 50)
client.advanced.archive_chat("5511999999999@s.whatsapp.net", instance_id: "…", on: true)
```

## Contatos

```ruby
c = client.contacts.create_contact(phone: "+5511999999999", name: "Ana", email: "ana@example.com")
client.contacts.mutate_contact_tags(c["id"], add: ["vip"])
client.contacts.list_contacts(tags: %w[vip], has_email: true, limit: 100)
client.contacts.opt_out_contact(c["id"])
client.contacts.contacts_check(instance_id: "…", phones: ["+5511999999999"]) # está no WhatsApp?
```

O vínculo contato ↔ projeto/número é mantido **automaticamente** pela API.

### Importar em lote

Até **1000** contatos por chamada, upsert por telefone: o novo entra como
`pending_validation` (precisa de opt-in antes de campanha), o que já existe só recebe os campos
informados — valor em branco não apaga o que está lá. Linha ruim vai para `errors` e **não**
derruba o resto; contato suprimido/opt-out/bloqueado aparece em `skipped_rows` e nunca
ressuscita. Tags e grupos são criados na hora. `dry_run: true` valida tudo e não grava nada.

```ruby
result = client.contacts.import_contacts(
  contacts: [
    { phone: "+5511999999999", name: "Ana", email: "ana@example.com", tags: %w[vip] },
    { phone: "+5511888888888", name: "Bruno", document: "12345678900", document_type: "cpf",
      address: { city: "São Paulo", state: "SP", country: "BR" }, groups: %w[clientes] }
  ],
  dry_run: true # ensaio: nada é gravado
)
result["created"] # => 2
result["errors"].each { |row| warn "linha #{row['index']} (#{row['phone']}): #{row['reason']}" }
```

### Exportar em CSV

`export_contacts` aceita os **mesmos filtros** do `list_contacts` (menos `offset`; use `limit`
para limitar as linhas) e devolve o **texto do CSV** — uma `String` UTF-8, não JSON. Colunas:
`phone,name,email,status,source,tags,groups,created_at,last_activity_at`, com tags e grupos
unidos por `;` e instantes em RFC 3339 UTC.

```ruby
require "csv"

csv = client.contacts.export_contacts(status: "active", tags: %w[vip], has_email: true,
                                      created_after: Time.utc(2026, 1, 1), limit: 50_000)

File.write("contatos.csv", csv)                       # gravar como veio
CSV.parse(csv, headers: true) { |row| puts row["phone"] } # ou percorrer linha a linha
```

Vírgulas e aspas dentro dos campos vêm escapadas pelo servidor — não monte o CSV de novo,
entregue o texto ao parser. Para bases muito grandes, exporte em fatias com os filtros
(`created_after`/`created_before`, `limit`) em vez de puxar tudo de uma vez.

## Campanhas

```ruby
camp = client.campaigns.create_campaign(
  name: "Black Friday",
  variations: [{ body: "Oi {{name}}, 30% hoje!", weight: 1 }],
  pacing_profile: "conservative"
)
client.campaigns.add_campaign_recipients(camp["id"], contact_filter: { tags: ["vip"] })
client.campaigns.dry_run_campaign(camp["id"])
client.campaigns.start_campaign(camp["id"])
```

## Webhooks

```ruby
hook = client.webhooks.create_webhook(url: "https://seu.app/bzapper", event_types: ["message.received"])
secret = hook["secret"] # mostrado uma vez — guarde
```

No seu endpoint, verifique a assinatura (`X-Bzapper-Signature: sha256=<hex>`, HMAC-SHA256 do
**corpo cru**, comparação em tempo constante) antes de processar:

```ruby
# Rack / Rails
raw = request.body.read
signature = request.get_header("HTTP_X_BZAPPER_SIGNATURE")

Bzapper::Webhook.verify(secret, raw, signature) # => true / false

event = Bzapper::Webhook.construct_event(secret, raw, signature) # SignatureError se não confere
event.id      # estável: use para ignorar reentregas
event.type    # "message.received"
event.payload # dados do evento

# Ou com roteamento por tipo:
router = Bzapper::Webhook::Router.new(secret)
router.on("message.received") { |ev| puts ev.sender&.dig("name"), ev.payload["body"] }
router.on("instance.banned") { |ev| alertar(ev.instance_id) }
router.handle(raw, signature)
```

## bZapper Connect (parceiros)

Seu software deixa os clientes **dele** assinarem o bZapper Pro e conectarem o WhatsApp sem
sair do seu produto. Use o `Bzapper::PartnerClient` com a chave de **parceiro** — só no
backend, nunca no navegador:

```ruby
partner = Bzapper::PartnerClient.new(ENV.fetch("BZAPPER_PARTNER_KEY"))

# 1) backend: cria a sessão e entrega o token ao front
session = partner.create_connect_session(
  external_id: "cliente-42",
  customer: { name: "Ana Souza", email: "ana@boxy.com", phone: "+5511988887777" }
)
# 2) front: BzapperConnect.open({ session: session["session_token"] }) → emite um `code`
# 3) backend: troca o code pela chave do cliente
conn = partner.exchange_connect_code(code: params[:code])
cliente = Bzapper::Client.new(conn["api_key"])
cliente.messages.send_text(to: "+5511999999999", body: "Conectado!")

partner.list_partner_connections(status: "active")
partner.rotate_partner_connection_key(conn["id"])
partner.revoke_partner_connection(conn["id"])
```

Conectado, a chave do cliente responde **402 `connect_suspended`** enquanto o Pro dele estiver
em aberto e **401 `connect_revoked`** depois que a conexão termina. O ciclo de vida chega ao
webhook do parceiro como `connect.completed`, `connect.suspended`, `connect.resumed` e
`connect.revoked` (mesma verificação de assinatura).

Do lado do cliente, `client.connect.list_connected_apps` / `revoke_connected_app(id)` mostram e
cortam os apps parceiros conectados.

## Erros

Toda resposta fora de 2xx vira um `Bzapper::Error` (alias `Bzapper::BzapperError`) — ou a
subclasse do status. **Use `code` na sua lógica**: é estável. `message` é texto para humanos,
traduzido conforme `locale:`, e pode mudar.

```ruby
begin
  client.messages.send_text(to: "+5511999999999", body: "oi")
rescue Bzapper::RateLimitError => e
  sleep(e.retry_after || 1) # segundos do Retry-After
rescue Bzapper::PermissionDeniedError => e
  warn "falta o escopo #{e.required_scope}" if e.code == "insufficient_scope"
rescue Bzapper::Error => e
  warn "#{e.code} (HTTP #{e.status}) request_id=#{e.request_id}: #{e.message}"
end
```

| Classe | Quando |
| --- | --- |
| `Bzapper::AuthenticationError` | 401 |
| `Bzapper::PermissionDeniedError` | 403 (`required_scope` = header `X-Required-Scope`) |
| `Bzapper::NotFoundError` | 404 |
| `Bzapper::ConflictError` | 409 |
| `Bzapper::ValidationError` | 400 e 422 |
| `Bzapper::RateLimitError` | 429 (`retry_after` em segundos) |
| `Bzapper::ServerError` | 5xx |
| `Bzapper::NetworkError` | conexão/timeout (`status == 0`, `code == "NETWORK_ERROR"`) |
| `Bzapper::Error` | qualquer outro status; `INVALID_RESPONSE` se um 2xx chega com corpo que não é JSON |

Campos: `code` (`body.code` → `body.error` → `HTTP_<status>`), `message`, `status`,
`request_id` (header `X-Request-Id` da resposta, senão o que a SDK enviou — **informe ao
suporte**), `retry_after`, `required_scope`, `locale` e `body` (o corpo decodificado).
`e.detailed_message` junta tudo numa linha.

Argumento inválido no seu código (chave vazia, parâmetro de caminho vazio) **não** é
`Bzapper::Error`: é `ArgumentError`/`TypeError`, na hora, sem requisição.

## Novas tentativas e idempotência

A SDK tenta de novo (até `max_retries`, padrão 2) em erro de rede/timeout, `429`, `502`, `503`
e `504` — nada mais (um `500` ou `4xx` volta na hora). Espera o `Retry-After` quando houver
(teto 60 s), senão `min(8, 0.5 × 2^tentativa)` s + até 25% de jitter.

Cada chamada gera um `X-Request-Id` e, nas escritas (POST/PUT/PATCH/DELETE), uma
`Idempotency-Key` — **as mesmas em todas as tentativas**. A API guarda a resposta por 24 h e,
numa repetição, devolve a original (`Idempotent-Replayed: true`) em vez de executar de novo:
é o que torna a nova tentativa segura (a mensagem não sai duas vezes).

Para amarrar a idempotência a algo do **seu** sistema (ex.: o id do pedido), passe a sua chave:

```ruby
client.messages.send_text(to: "+5511999999999", body: "Pedido #42 confirmado", idempotency_key: "pedido-42")
```

## Versões

A gem segue a versão das SDKs do bZapper (todas as linguagens saem na mesma versão). Cada
release declara se muda a superfície pública (assinatura) ou se é só aditiva — por isso fixe a
versão exata no `Gemfile` e atualize de propósito. `Bzapper::VERSION` vai no header
`X-Bzapper-Client` (`bzapper-ruby/<versão>`): é por ele que o bZapper avisa **só** quem roda
uma versão afetada por uma correção.

## Exemplo

[`examples/quickstart.rb`](examples/quickstart.rb):

```bash
BZAPPER_API_KEY=bz_live_... BZAPPER_TO=+5511999999999 ruby examples/quickstart.rb
```

## Desenvolvimento

```bash
bundle install
bundle exec rake test   # conformidade (test/fixtures/conformance/cases.json) + unitários + versão
```

Os métodos em `lib/bzapper/resources/` são gerados da spec (`ruby script/generate.rb`, só no
monorepo); a suíte falha se algum endpoint da spec ficar sem método.

## Licença

MIT — Berni Software.
