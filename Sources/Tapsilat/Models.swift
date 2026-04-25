import Foundation

public struct Order: Codable, Sendable {
    public var locale: String?
    public var amount: Double?
    public var taxAmount: Double?
    public var currency: String?
    public var conversationId: String?
    public var buyer: OrderBuyer
    public var shippingAddress: OrderShippingAddress
    public var billingAddress: OrderBillingAddress
    public var basketItems: [OrderBasketItem]
    public var paymentFailureUrl: String?
    public var paymentSuccessUrl: String?
    public var enabledInstallments: [Int]
    public var paymentOptions: [String]

    public init(
        locale: String? = nil,
        amount: Double? = nil,
        taxAmount: Double? = nil,
        currency: String? = nil,
        conversationId: String? = nil,
        buyer: OrderBuyer = .init(),
        shippingAddress: OrderShippingAddress = .init(),
        billingAddress: OrderBillingAddress = .init(),
        basketItems: [OrderBasketItem] = [],
        paymentFailureUrl: String? = nil,
        paymentSuccessUrl: String? = nil,
        enabledInstallments: [Int] = [],
        paymentOptions: [String] = []
    ) {
        self.locale = locale
        self.amount = amount
        self.taxAmount = taxAmount
        self.currency = currency
        self.conversationId = conversationId
        self.buyer = buyer
        self.shippingAddress = shippingAddress
        self.billingAddress = billingAddress
        self.basketItems = basketItems
        self.paymentFailureUrl = paymentFailureUrl
        self.paymentSuccessUrl = paymentSuccessUrl
        self.enabledInstallments = enabledInstallments
        self.paymentOptions = paymentOptions
    }
}

public struct OrderBuyer: Codable, Sendable {
    public var id: String?
    public var name: String?
    public var surname: String?
    public var email: String?
    public var gsmNumber: String?
    public var identityNumber: String?
    public var registrationDate: String?
    public var registrationAddress: String?
    public var lastLoginDate: String?
    public var city: String?
    public var country: String?
    public var zipCode: String?
    public var ip: String?
    public var birthDate: String?

    public init(
        id: String? = nil,
        name: String? = nil,
        surname: String? = nil,
        email: String? = nil,
        gsmNumber: String? = nil,
        identityNumber: String? = nil,
        registrationDate: String? = nil,
        registrationAddress: String? = nil,
        lastLoginDate: String? = nil,
        city: String? = nil,
        country: String? = nil,
        zipCode: String? = nil,
        ip: String? = nil,
        birthDate: String? = nil
    ) {
        self.id = id
        self.name = name
        self.surname = surname
        self.email = email
        self.gsmNumber = gsmNumber
        self.identityNumber = identityNumber
        self.registrationDate = registrationDate
        self.registrationAddress = registrationAddress
        self.lastLoginDate = lastLoginDate
        self.city = city
        self.country = country
        self.zipCode = zipCode
        self.ip = ip
        self.birthDate = birthDate
    }
}

public struct OrderShippingAddress: Codable, Sendable {
    public var address: String?
    public var zipCode: String?
    public var city: String?
    public var country: String?
    public var contactName: String?

    public init(address: String? = nil, zipCode: String? = nil, city: String? = nil, country: String? = nil, contactName: String? = nil) {
        self.address = address
        self.zipCode = zipCode
        self.city = city
        self.country = country
        self.contactName = contactName
    }
}

public struct OrderBillingAddress: Codable, Sendable {
    public var address: String?
    public var zipCode: String?
    public var city: String?
    public var country: String?
    public var contactName: String?

    public init(address: String? = nil, zipCode: String? = nil, city: String? = nil, country: String? = nil, contactName: String? = nil) {
        self.address = address
        self.zipCode = zipCode
        self.city = city
        self.country = country
        self.contactName = contactName
    }
}

public struct OrderBasketItem: Codable, Sendable {
    public var id: String?
    public var price: Double?
    public var name: String?
    public var category1: String?
    public var category2: String?
    public var itemType: String?

    public init(
        id: String? = nil,
        price: Double? = nil,
        name: String? = nil,
        category1: String? = nil,
        category2: String? = nil,
        itemType: String? = nil
    ) {
        self.id = id
        self.price = price
        self.name = name
        self.category1 = category1
        self.category2 = category2
        self.itemType = itemType
    }
}

public struct OrderResponse: Codable, Sendable {
    public var orderId: String?
    public var referenceId: String?
    public var checkoutUrl: String?
    public var error: String?
}

public struct OrderDetail: Codable, Sendable {
    public var referenceId: String?
    public var amount: String?
    public var currency: String?
    public var status: Int?
    public var statusEnum: String?
    public var checkoutUrl: String?
    public var conversationId: String?
    public var error: String?
}

public struct OrderStatus: Codable, Sendable {
    public var status: String?
    public var error: String?
}

public struct RefundOrder: Codable, Sendable {
    public let referenceId: String
    public let amount: Double?

    public init(referenceId: String, amount: Double? = nil) {
        self.referenceId = referenceId
        self.amount = amount
    }
}

public struct CancelOrder: Codable, Sendable {
    public let referenceId: String

    public init(referenceId: String) {
        self.referenceId = referenceId
    }
}

public struct RefundCancelOrderResponse: Codable, Sendable {
    public var status: String?
    public var message: String?
    public var isSuccess: Bool?
    public var error: String?
}

public struct PaginatedData: Codable, Sendable {
    public var page: Int?
    public var perPage: Int?
    public var total: Int?
    public var totalPages: Int?
    public var rows: JSONValue?
    public var error: String?
}

public struct OrganizationSettings: Codable, Sendable {
    public var status: String?
    public var data: JSONValue?
}

public struct OrganizationCurrency: Codable, Sendable {
    public var id: String?
    public var currencyUnit: String?
    public var code: String?
    public var name: String?
    public var symbol: String?
}

public struct OrganizationCurrenciesResponse: Codable, Sendable {
    public var currencies: [OrganizationCurrency]

    public init(currencies: [OrganizationCurrency] = []) {
        self.currencies = currencies
    }
}

public struct OrganizationCurrencyPresetsResponse: Codable, Sendable {
    public var currencies: [OrganizationCurrency]

    public init(currencies: [OrganizationCurrency] = []) {
        self.currencies = currencies
    }
}

public struct CreateOrganizationCurrencyResponse: Codable, Sendable {
    public var code: Int?
    public var message: String?
    public var currency: OrganizationCurrency?
}

public struct SubmerchantCreateRequest: Codable, Sendable {
    public var name: String
    public var currencyId: String

    public init(name: String, currencyId: String) {
        self.name = name
        self.currencyId = currencyId
    }
}

public struct SubmerchantUpdateRequest: Codable, Sendable {
    public var name: String?
    public var currencyId: String

    public init(name: String? = nil, currencyId: String) {
        self.name = name
        self.currencyId = currencyId
    }
}

public struct SubmerchantMutationResponse: Codable, Sendable {
    public var code: Int?
    public var message: String?
}

public struct Submerchant: Codable, Sendable {
    public var id: String?
    public var name: String?
}

public struct SubmerchantListResponse: Codable, Sendable {
    public var page: Int?
    public var perPage: Int?
    public var total: Int?
    public var rows: [Submerchant]?
}

public struct VposCreateRequest: Codable, Sendable {
    public var title: String
    public var currencies: [String]

    public init(title: String, currencies: [String]) {
        self.title = title
        self.currencies = currencies
    }
}

public struct VposUpdateRequest: Codable, Sendable {
    public var title: String?
    public var currencies: [String]

    public init(title: String? = nil, currencies: [String]) {
        self.title = title
        self.currencies = currencies
    }
}

public struct VposMutationResponse: Codable, Sendable {
    public var code: Int?
    public var message: String?
}

public struct Vpos: Codable, Sendable {
    public var id: String?
    public var title: String?
}

public struct VposListFilter: Codable, Sendable {
    public var suborganizationId: String?

    public init(suborganizationId: String? = nil) {
        self.suborganizationId = suborganizationId
    }
}

public struct VposListResponse: Codable, Sendable {
    public var page: Int?
    public var perPage: Int?
    public var total: Int?
    public var rows: [Vpos]?
}

public struct SubscriptionGetRequest: Codable, Sendable {
    public var referenceId: String

    public init(referenceId: String) {
        self.referenceId = referenceId
    }
}

public struct SubscriptionCancelRequest: Codable, Sendable {
    public var referenceId: String

    public init(referenceId: String) {
        self.referenceId = referenceId
    }
}

public struct SubscriptionCreateRequest: Codable, Sendable {
    public var planId: String

    public init(planId: String) {
        self.planId = planId
    }
}

public struct SubscriptionRedirectRequest: Codable, Sendable {
    public var referenceId: String

    public init(referenceId: String) {
        self.referenceId = referenceId
    }
}

public struct SubscriptionDetail: Codable, Sendable {
    public var id: String?
    public var status: String?
}

public struct SubscriptionCreateResponse: Codable, Sendable {
    public var referenceId: String?
    public var checkoutUrl: String?
}

public struct SubscriptionRedirectResponse: Codable, Sendable {
    public var checkoutUrl: String?
}
