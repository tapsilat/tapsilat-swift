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

## Modules

- `order`: orders, payments, transactions, charge, refunds and payment terms
- `organization`: settings, currencies, users and sub-organizations
- `submerchant`: submerchants, settlement approval and payout events
- `vpos`: virtual POS and VPOS submerchants
- `subscription`: subscriptions
- `checkout`: card installments, the installment table and order charge
- `card`: saved cards (tokenization)
- `marketplace`: sellers, payouts, payout operations and policies (API v2)
- `credit`, `wallet`: placeholders

## Notes

- Networking is implemented with URLSession + async/await; pass `session:` to use your own `URLSession`.
- JSON keys use snake_case conversion to match API payloads.
- Currency references (a UUID or a unit such as TRY) are sent as given; the server resolves units.
- API errors are thrown as `APIError` with the HTTP status, the body's `status`, `code` and message,
  any field `errors`, and the raw body. A response that is not JSON, such as an HTML page from a wrong
  endpoint, is also an `APIError`.
