import Foundation

public final class OrderService: @unchecked Sendable {
    private let client: SharedAPIClient

    public init(client: SharedAPIClient) {
        self.client = client
    }

    public func createOrder(_ payload: Order) async throws -> OrderResponse {
        var normalized = payload
        normalized.buyer.gsmNumber = try Validators.validateGsmNumber(payload.buyer.gsmNumber)

        var response: OrderResponse = try await client.post("/order/create", payload: normalized)

        if let referenceId = response.referenceId, !referenceId.isEmpty {
            let checkout = try? await getCheckoutURL(referenceId: referenceId)
            response.checkoutUrl = checkout ?? response.checkoutUrl
        }

        return response
    }

    public func getOrder(orderReferenceId: String) async throws -> OrderDetail {
        try await client.get("/order/\(orderReferenceId)")
    }

    public func getOrderByConversationID(conversationId: String) async throws -> OrderDetail {
        try await client.get("/order/conversation/\(conversationId)")
    }

    public func getOrderList(
        page: Int,
        perPage: Int,
        buyerId: String? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        organizationId: String? = nil,
        relatedReferenceId: String? = nil
    ) async throws -> PaginatedData {
        var query: [String: String] = [
            "page": String(page),
            "per_page": String(perPage),
        ]

        if let buyerId, !buyerId.isEmpty { query["buyer_id"] = buyerId }
        if let startDate, !startDate.isEmpty { query["start_date"] = startDate }
        if let endDate, !endDate.isEmpty { query["end_date"] = endDate }
        if let organizationId, !organizationId.isEmpty { query["organization_id"] = organizationId }
        if let relatedReferenceId, !relatedReferenceId.isEmpty { query["related_reference_id"] = relatedReferenceId }

        return try await client.get("/order/list", query: query)
    }

    public func getCheckoutURL(referenceId: String) async throws -> String? {
        let order = try await getOrder(orderReferenceId: referenceId)
        return order.checkoutUrl
    }

    public func getOrderStatus(orderReferenceId: String) async throws -> OrderStatus {
        try await client.get("/order/\(orderReferenceId)/status")
    }

    public func getOrderPaymentDetails(referenceId: String? = nil, conversationId: String? = nil) async throws -> [String: JSONValue] {
        var query: [String: String] = [:]

        if let referenceId, !referenceId.isEmpty {
            query["reference_id"] = referenceId
        } else if let conversationId, !conversationId.isEmpty {
            query["conversation_id"] = conversationId
        }

        return try await client.getMap("/order/payment-details", query: query)
    }

    public func cancelOrder(_ payload: CancelOrder) async throws -> RefundCancelOrderResponse {
        try await client.post("/order/cancel", payload: payload)
    }

    public func refundOrder(_ payload: RefundOrder) async throws -> RefundCancelOrderResponse {
        try await client.post("/order/refund", payload: payload)
    }

    public func refundAllOrder(referenceId: String) async throws -> RefundCancelOrderResponse {
        try await refundOrder(.init(referenceId: referenceId))
    }
}

public final class OrganizationService: OrganizationCurrencyProviding, @unchecked Sendable {
    private let client: SharedAPIClient

    public init(client: SharedAPIClient) {
        self.client = client
    }

    public func getOrganizationSettings() async throws -> OrganizationSettings {
        try await client.get("/organization/settings")
    }

    public func getOrganizationCurrencies() async throws -> OrganizationCurrenciesResponse {
        try await client.get("/organization/currencies")
    }

    public func listOrganizationCurrencyPresets() async throws -> OrganizationCurrencyPresetsResponse {
        try await client.get("/organization/currency-presets")
    }

    public func createOrganizationCurrency(currencyCode: String) async throws -> CreateOrganizationCurrencyResponse {
        let payload = ["currency_code": currencyCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(with: Locale(identifier: "en_US_POSIX"))]
        return try await client.post("/organization/currencies", payload: payload)
    }
}

public final class SubmerchantService: @unchecked Sendable {
    private let client: SharedAPIClient
    private let currencyResolver: CurrencyReferenceResolver

    public init(client: SharedAPIClient, currencyResolver: CurrencyReferenceResolver) {
        self.client = client
        self.currencyResolver = currencyResolver
    }

    public func createSubmerchant(_ payload: SubmerchantCreateRequest) async throws -> SubmerchantMutationResponse {
        let resolvedCurrencyID = try await currencyResolver.resolveCurrencyId(payload.currencyId)
        var normalized = payload
        normalized.currencyId = resolvedCurrencyID
        return try await client.post("/submerchants", payload: normalized)
    }

    public func getSubmerchant(id: String) async throws -> Submerchant {
        try await client.get("/submerchants/\(id)")
    }

    public func listSubmerchants(page: Int, perPage: Int) async throws -> SubmerchantListResponse {
        try await client.get("/submerchants", query: ["page": String(page), "per_page": String(perPage)])
    }

    public func updateSubmerchant(id: String, payload: SubmerchantUpdateRequest) async throws -> SubmerchantMutationResponse {
        let resolvedCurrencyID = try await currencyResolver.resolveCurrencyId(payload.currencyId)
        var normalized = payload
        normalized.currencyId = resolvedCurrencyID
        return try await client.patch("/submerchants/\(id)", payload: normalized)
    }

    public func deleteSubmerchant(id: String) async throws -> SubmerchantMutationResponse {
        try await client.delete("/submerchants/\(id)")
    }
}

public final class VposService: @unchecked Sendable {
    private let client: SharedAPIClient
    private let currencyResolver: CurrencyReferenceResolver

    public init(client: SharedAPIClient, currencyResolver: CurrencyReferenceResolver) {
        self.client = client
        self.currencyResolver = currencyResolver
    }

    public func listVpos(page: Int, perPage: Int) async throws -> VposListResponse {
        try await listVposWithFilter(page: page, perPage: perPage, filter: .init())
    }

    public func listVposWithFilter(page: Int, perPage: Int, filter: VposListFilter) async throws -> VposListResponse {
        var query = ["page": String(page), "per_page": String(perPage)]
        if let suborganizationID = filter.suborganizationId, !suborganizationID.isEmpty {
            query["suborganization_id"] = suborganizationID
        }
        return try await client.get("/vpos", query: query)
    }

    public func createVpos(_ payload: VposCreateRequest) async throws -> VposMutationResponse {
        let resolved = try await currencyResolver.resolveCurrencyIds(payload.currencies)
        var normalized = payload
        normalized.currencies = resolved
        return try await client.post("/vpos", payload: normalized)
    }

    public func getVpos(id: String) async throws -> Vpos {
        try await client.get("/vpos/\(id)")
    }

    public func updateVpos(id: String, payload: VposUpdateRequest) async throws -> VposMutationResponse {
        let resolved = try await currencyResolver.resolveCurrencyIds(payload.currencies)
        var normalized = payload
        normalized.currencies = resolved
        return try await client.patch("/vpos/\(id)", payload: normalized)
    }

    public func deleteVpos(id: String) async throws -> VposMutationResponse {
        try await client.delete("/vpos/\(id)")
    }
}

public final class SubscriptionService: @unchecked Sendable {
    private let client: SharedAPIClient

    public init(client: SharedAPIClient) {
        self.client = client
    }

    public func getSubscription(_ payload: SubscriptionGetRequest) async throws -> SubscriptionDetail {
        try await client.post("/subscription", payload: payload)
    }

    public func cancelSubscription(_ payload: SubscriptionCancelRequest) async throws {
        _ = try await client.postMap("/subscription/cancel", payload: payload)
    }

    public func createSubscription(_ payload: SubscriptionCreateRequest) async throws -> SubscriptionCreateResponse {
        try await client.post("/subscription/create", payload: payload)
    }

    public func listSubscriptions(page: Int, perPage: Int) async throws -> PaginatedData {
        try await client.get("/subscription/list", query: ["page": String(page), "per_page": String(perPage)])
    }

    public func redirectSubscription(_ payload: SubscriptionRedirectRequest) async throws -> SubscriptionRedirectResponse {
        try await client.post("/subscription/redirect", payload: payload)
    }
}

public final class CheckoutService: @unchecked Sendable {
    private let client: SharedAPIClient

    public init(client: SharedAPIClient) {
        self.client = client
    }

    public func createCheckoutSessionPlaceholder() throws -> Never {
        throw ValidationError("Checkout module is not implemented yet")
    }
}

public final class CreditService: @unchecked Sendable {
    private let client: SharedAPIClient

    public init(client: SharedAPIClient) {
        self.client = client
    }

    public func createCreditApplicationPlaceholder() throws -> Never {
        throw ValidationError("Credit module is not implemented yet")
    }
}

public final class CardService: @unchecked Sendable {
    private let client: SharedAPIClient

    public init(client: SharedAPIClient) {
        self.client = client
    }

    public func createCardPlaceholder() throws -> Never {
        throw ValidationError("Card module is not implemented yet")
    }
}

public final class WalletService: @unchecked Sendable {
    private let client: SharedAPIClient

    public init(client: SharedAPIClient) {
        self.client = client
    }

    public func createWalletPlaceholder() throws -> Never {
        throw ValidationError("Wallet module is not implemented yet")
    }
}
