# Tapsilat (Swift SPM)

Swift Package Manager SDK for Tapsilat APIs. Requires iOS 15 or macOS 12.

## Installation

```swift
.package(url: "https://github.com/tapsilat/tapsilat-ios.git", branch: "main")
```

The release tags (such as `v2026.04.25`) are not semantic versions, so Swift Package Manager
cannot resolve them with `from:`; depend on a branch or a revision.

## Usage

```swift
import Tapsilat

let api = Tapsilat.newAPI(token: "YOUR_TOKEN")
// Or point at another deployment; marketplace calls use the matching /api/v2 URL
let staging = Tapsilat.newCustomAPI(endpoint: "https://panel.tapsilat.dev/api/v1", token: "YOUR_TOKEN")

let order = Order(
    locale: "tr",
    amount: 100,
    currency: "TRY",
    buyer: OrderBuyer(
        id: "buyer-1",
        name: "John",
        surname: "Doe",
        email: "john@doe.com",
        gsmNumber: "+90 555 123 45 67", // cleaned to +905551234567
        birthDate: "1990-01-02"
    ),
    basketItems: [
        OrderBasketItem(id: "item-1", price: 100, name: "Product", category1: "General", itemType: "VIRTUAL")
    ],
    redirectSuccessUrl: "https://shop.example/success",
    redirectFailureUrl: "https://shop.example/failure"
)

Task {
    do {
        let response = try await api.createOrder(order)
        print("reference: \(response.referenceId ?? "-"), checkout: \(response.checkoutUrl ?? "-")")
    } catch let error as APIError {
        print("API error \(error.statusCode) [\(error.code ?? "-")]: \(error.messageText ?? error.rawBody)")
    } catch {
        print("error: \(error)")
    }
}
```

Payment terms sent with an order need a `dueDate`, and their dates are RFC3339 timestamps such as
`"2026-01-15T00:00:00Z"`. Terms added later with `order.createOrderTerm` use `YYYY-MM-DD`.

## Orders

```swift
let detail = try await api.getOrder(orderReferenceId: "reference-id")
let page = try await api.getOrderList(filter: OrderListFilter(page: 1, perPage: 50, startDate: "2026-01-01", status: 3))
let transactions = try await api.order.getOrderTransactions(referenceId: "reference-id")
let payments = try await api.getOrderPayments(GetOrderPaymentsRequest(orderReferenceId: "reference-id"))
let charged = try await api.chargeOrder(OrderChargeRequest(orderReferenceId: "reference-id"))

_ = try await api.refundOrder(RefundOrder(referenceId: "reference-id", amount: 50))
_ = try await api.refundAllOrder(referenceId: "reference-id")

// Payment terms: orderId is the order's ID, not its reference ID
_ = try await api.order.createOrderTerm(OrderTermCreateRequest(orderId: "order-id", required: true, amount: 50, dueDate: "2026-02-01"))
_ = try await api.order.deleteOrderTerm(orderId: "order-id", termReferenceId: "term-1")
```

## Card Installments

```swift
let options = try await api.getCardInstallments(CardInstallmentsRequest(bin: "54066200", amount: 1000, currency: "TRY"))
let table = try await api.getInstallmentTable(InstallmentTableRequest(amount: 1000))
```

## Organization, Submerchants, VPOS and Saved Cards

```swift
let settings = try await api.getOrganizationSettings()
let currencyId = try await api.resolveCurrencyId("TRY") // only needed where a UUID is required

_ = try await api.submerchant.createSubmerchant(SubmerchantCreateRequest(
    locale: "tr", conversationId: "conv-1", name: "Seller", email: "seller@example.com",
    gsmNumber: "+905551234567", currencyId: "TRY", identityNumber: "11111111111", subMerchantType: "PERSONAL"
))

// A VPOS update replaces the whole configuration: read it first and send every field back
let vpos = try await api.vpos.getVpos(id: "vpos-id")
_ = try await api.vpos.updateVpos(id: "vpos-id", payload: VposUpdateRequest(name: vpos.name, currencies: vpos.currencies ?? [], failover: true))

let cards = try await api.card.listSavedCards(page: 1, perPage: 10)
```

## Marketplace (API v2)

Seller and payout revisions are opaque strings: send them back exactly as received.

```swift
let seller = try await api.marketplace.getSubmerchant(id: "seller-id")
_ = try await api.marketplace.updateSubmerchant(id: "seller-id", payload: MarketplaceProfileUpdate(name: "New name", revision: seller.revision ?? ""))

let payouts = try await api.marketplace.listPayouts(MarketplacePayoutFilter(status: "WAITING_APPROVAL"))
_ = try await api.marketplace.approvePayouts(MarketplacePayoutApproval(ids: payouts.rows?.compactMap(\.id) ?? []))

// The approval policy currency must be a UUID; a unit such as "TRY" is resolved for you
try await api.marketplace.createApprovalPolicy(MarketplaceApprovalPolicyInput(name: "Large orders", minAmount: "1000", currencyId: "TRY", mode: "manual"))
```

## Elements Sessions

Tapsilat Elements is the native Android and iOS card sheet. Your server creates a session with its
secret API key and hands only the session's `clientSecret` to your app, which opens the sheet with
it. Card data goes from the sheet to Tapsilat encrypted and never reaches your server. These calls
need the secret API key, so make them from your server, never from the app.

```swift
let created = try await api.createElementsSession(ElementsSessionCreateRequest(
    purpose: ElementsSession.purposePay,
    orderReferenceId: "reference-id",
    saveCard: true
))
// Return created.id and created.clientSecret to your app. Do not log or store the secret.

// Later, read the outcome on your server instead of trusting what the app reports
let outcome = try await api.getElementsSession(id: "es_test_8Kq2nV0rX4")
if outcome.status == ElementsSession.statusSucceeded {
    // fulfil the order; outcome.card has the brand, last4 and expiry
}

// Cancel a session that is still waiting for a card
_ = try await api.cancelElementsSession(id: "es_test_8Kq2nV0rX4")
```

A `pay` session needs `orderReferenceId`. A `tokenize` session (`ElementsSession.purposeTokenize`)
saves a card for `userId`, with `mode` set to `ElementsSessionCreateRequest.modeSecure` (3D Secure),
`modeHalfSecure` or `modeNonSecure`. A session that is confirming or has completed comes back
unchanged from `cancelElementsSession`. Status, purpose and card brand are strings, so values added
later still decode; compare them with the `ElementsSession.status…` and `ElementsCardSummary.brand…`
constants.

`clientSecret` is returned only by `createElementsSession`. `print`, `debugPrint`, `dump` and string
interpolation show it as `[redacted]`; `JSONEncoder` keeps it, so you can send the session to your
app. Elements errors are thrown as `APIError` with a stable `code` (such as `elements_not_enabled` or
`session_not_found`) and `retryable`.

## Webhooks

Tapsilat signs every callback it sends to your callback URLs, and to an order's `payment_success_url`
and `payment_failure_url`, with the webhook secret from the panel's callback settings. The
`Tapsilat-Signature` header looks like `t=1726480000,v1=5257a8…`: `v1` is the hex HMAC-SHA256 of the
timestamp, a dot and the raw body.

`TapsilatWebhook.verify` checks it in constant time and rejects a timestamp more than 5 minutes from
the server clock, so a captured callback cannot be replayed. Pass the raw body, not re-encoded JSON.

```swift
import Tapsilat

/// Handles a callback. `signature` is the request's `Tapsilat-Signature` header
/// (`TapsilatWebhook.signatureHeader`); returns the HTTP status to answer with.
func handleCallback(body: Data, signature: String?) -> Int {
    guard TapsilatWebhook.verify(payload: body, signature: signature, secret: "your_webhook_secret"),
          let event = try? WebhookEvent(payload: body)
    else {
        return 400
    }

    print(event.type ?? "-")           // "order_lite" (the default), "order", "order_payment_detail", ...
    print(event.referenceId ?? "-")    // the order's reference ID, whatever the callback type
    print(event.conversationId ?? "-")
    print(event.status ?? "-")         // e.g. "Paid", when the callback type carries a status

    if event.isPaid {
        // fulfil the order
    }
    return 200
}
```

A different tolerance in seconds can be passed as `tolerance:` (`0` disables the timestamp check),
and `now:` replaces the current time in tests. A bare hex HMAC-SHA256 of the body, with or without
a `sha256=` prefix, is still accepted.

### Order Statuses

`OrderStatus.Code` has the numeric status codes that callbacks carry and the names
`getOrderStatus` returns, and `OrderStatus` has the groups most integrations need:

```swift
let status = try await api.getOrderStatus(orderReferenceId: "reference-id") // status.status: e.g. "Waiting for payment"
status.code      // .waitingForPayment (rawValue 7)
status.isPaid    // false

OrderStatus.isPaid("Completed")     // Paid, Completed, Sub merchant payment approved
OrderStatus.isFailed("Expired")     // Cancelled, Fraud, Rejected, Failure, Expired, Terminated
OrderStatus.isRefunded(10)          // Refunded, Partially refunded
OrderStatus.code("7")               // .waitingForPayment; also accepts 7 or "waiting for payment"
OrderStatus.Code.failure.name       // "Failure"
```

## Modules

- `order`: orders, payments, transactions, charge, refunds and payment terms
- `organization`: settings, currencies, users and sub-organizations
- `submerchant`: submerchants, settlement approval and payout events
- `vpos`: virtual POS and VPOS submerchants
- `subscription`: subscriptions
- `checkout`: card installments, the installment table and order charge
- `card`: saved cards (tokenization)
- `marketplace`: sellers, payouts, payout operations and policies (API v2)
- `elements`: Tapsilat Elements sessions for the native card sheet: `createElementsSession`
  (`POST /elements/sessions`), `getElementsSession` (`GET /elements/sessions/{id}`) and
  `cancelElementsSession` (`POST /elements/sessions/{id}/cancel`)
- `credit`, `wallet`: placeholders

## Notes

- Networking is implemented with URLSession + async/await; pass `session:` to use your own `URLSession`.
- JSON keys use snake_case conversion to match API payloads.
- Currency references (a UUID or a unit such as TRY) are sent as given; the server resolves units.
- API errors are thrown as `APIError` with the HTTP status, the body's `status`, `code` and message,
  any field `errors`, `retryable`, and the raw body. Elements routes nest the error as
  `{"error": {"code": "...", "message": "...", "retryable": true}}`; `code`, `messageText` and
  `retryable` are read from that object. A response that is not JSON, such as an HTML page from a
  wrong endpoint, is also an `APIError`.
