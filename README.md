# Tapsilat (Swift SPM)

Swift Package Manager SDK for Tapsilat APIs.

## Installation

```swift
.package(url: "https://github.com/tapsilat/tapsilat-ios.git", from: "1.0.0")
```

## Usage

```swift
import Tapsilat

let api = Tapsilat.newAPI(token: "YOUR_TOKEN")

let order = Order(
    locale: "tr",
    amount: 100,
    currency: "TRY",
    buyer: OrderBuyer(
        id: "buyer-1",
        name: "John",
        surname: "Doe",
        email: "john@doe.com",
        gsmNumber: "+90 555 123 45 67"
    ),
    basketItems: [
        OrderBasketItem(
            id: "item-1",
            price: 100,
            name: "Product",
            category1: "General",
            itemType: "VIRTUAL"
        )
    ]
)

Task {
    do {
        let response = try await api.createOrder(order)
        print("reference: \(response.referenceId ?? "-")")
    } catch {
        print("error: \(error)")
    }
}
```

## Current Modules

- Order
- Organization + currency resolving
- Submerchant
- VPOS
- Subscription
- Checkout/Credit/Card/Wallet placeholders

## Notes

- Networking is implemented with URLSession + async/await.
- JSON keys use snake_case conversion to match API payloads.
- Currency references can be UUID or currency unit (TRY, USD, EUR).
