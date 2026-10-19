import Foundation

extension SharedAPIClient {
    func send<T: Decodable>(
        _ method: String,
        _ path: String,
        version: String? = nil,
        query: [URLQueryItem] = [],
        as type: T.Type = T.self
    ) async throws -> T {
        try await request(method: method, path: path, version: version, queryItems: query, payload: Optional<String>.none, as: type)
    }

    func send<P: Encodable, T: Decodable>(
        _ method: String,
        _ path: String,
        version: String? = nil,
        payload: P,
        as type: T.Type = T.self
    ) async throws -> T {
        try await request(method: method, path: path, version: version, payload: payload, as: type)
    }
}

private func escape(_ value: String) -> String {
    SharedAPIClient.pathEscape(value)
}

private func paging(_ page: Int, _ perPage: Int) -> QueryBuilder {
    QueryBuilder().with("page", page).with("per_page", perPage)
}

public final class OrderService: @unchecked Sendable {
    private let client: SharedAPIClient

    public init(client: SharedAPIClient) {
        self.client = client
    }

    /// Creates an order. The buyer's GSM number is cleaned first, and the checkout URL is
    /// filled from the created order when it can be read.
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
        try await client.send("GET", "/order/\(escape(orderReferenceId))")
    }

    /// Returns the order with the given conversation ID; the server fills a subset of the detail fields.
    public func getOrderByConversationID(conversationId: String) async throws -> OrderDetail {
        try await client.send("GET", "/order/conversation/\(escape(conversationId))")
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
        try await getOrderList(filter: OrderListFilter(
            page: page,
            perPage: perPage,
            startDate: startDate,
            endDate: endDate,
            organizationId: organizationId,
            relatedReferenceId: relatedReferenceId,
            buyerId: buyerId
        ))
    }

    /// Lists orders with every filter the order list endpoint accepts.
    public func getOrderList(filter: OrderListFilter) async throws -> PaginatedData {
        let query = paging(filter.page, filter.perPage)
            .with("start_date", filter.startDate)
            .with("end_date", filter.endDate)
            .with("organization_id", filter.organizationId)
            .with("conversation_id", filter.conversationId)
            .with("related_reference_id", filter.relatedReferenceId)
            .with("buyer_id", filter.buyerId)
            .with("status", filter.status)
        return try await client.send("GET", "/order/list", query: query.items)
    }

    public func getOrderSubmerchants(page: Int, perPage: Int) async throws -> OrderSubmerchantListResponse {
        try await client.send("GET", "/order/submerchants", query: paging(page, perPage).items)
    }

    public func getCheckoutURL(referenceId: String) async throws -> String? {
        let order = try await getOrder(orderReferenceId: referenceId)
        return order.checkoutUrl
    }

    public func getOrderStatus(orderReferenceId: String) async throws -> OrderStatus {
        try await client.send("GET", "/order/\(escape(orderReferenceId))/status")
    }

    /// Returns an order's payment details by its reference ID, or else by its conversation ID.
    public func getOrderPaymentDetails(referenceId: String? = nil, conversationId: String? = nil) async throws -> [String: JSONValue] {
        if let referenceId, !referenceId.isEmpty {
            return try await client.send("GET", "/order/\(escape(referenceId))/payment-details")
        }
        if let conversationId, !conversationId.isEmpty {
            return try await getOrderPaymentDetailsByConversationID(conversationId: conversationId)
        }
        throw ValidationError("referenceId or conversationId is required")
    }

    public func getOrderPaymentDetailsByConversationID(conversationId: String) async throws -> [String: JSONValue] {
        try await client.post("/order/payment-details", payload: ["conversation_id": conversationId])
    }

    /// Returns the order's transactions, or nil when there are none.
    public func getOrderTransactions(referenceId: String) async throws -> [JSONValue]? {
        try await client.send("GET", "/order/\(escape(referenceId))/transactions")
    }

    /// Lists the payments made against an order, with commission totals.
    public func getOrderPayments(_ payload: GetOrderPaymentsRequest) async throws -> GetOrderPaymentsResponse {
        try await client.post("/order/payments", payload: payload)
    }

    /// Charges an order, for example with its saved card.
    public func chargeOrder(_ payload: OrderChargeRequest) async throws -> OrderChargeResponse {
        try await client.post("/order/charge", payload: payload)
    }

    public func cancelOrder(_ payload: CancelOrder) async throws -> RefundCancelOrderResponse {
        try await client.post("/order/cancel", payload: payload)
    }

    public func refundOrder(_ payload: RefundOrder) async throws -> RefundCancelOrderResponse {
        try await client.post("/order/refund", payload: payload)
    }

    /// Refunds the full paid amount of an order.
    public func refundAllOrder(referenceId: String) async throws -> RefundCancelOrderResponse {
        try await client.post("/order/refund-all", payload: CancelOrder(referenceId: referenceId))
    }

    /// Returns a payment term by its term reference ID.
    public func getOrderTerm(termReferenceId: String) async throws -> [String: JSONValue] {
        try await client.send("GET", "/order/term", query: QueryBuilder().with("term_reference_id", termReferenceId).items)
    }

    public func createOrderTerm(_ payload: OrderTermCreateRequest) async throws -> [String: JSONValue] {
        try await client.post("/order/term", payload: payload)
    }

    public func updateOrderTerm(_ payload: OrderTermUpdateRequest) async throws -> [String: JSONValue] {
        try await client.patch("/order/term", payload: payload)
    }

    /// Removes a payment term; `orderId` is the order's ID, not its reference ID.
    public func deleteOrderTerm(orderId: String, termReferenceId: String) async throws -> [String: JSONValue] {
        try await client.delete("/order/term", payload: ["order_id": orderId, "term_reference_id": termReferenceId])
    }

    public func refundOrderTerm(_ payload: OrderTermRefundRequest) async throws -> [String: JSONValue] {
        try await client.post("/order/term/refund", payload: payload)
    }

    public func orderTerminate(referenceId: String) async throws -> [String: JSONValue] {
        try await client.post("/order/terminate", payload: ["reference_id": referenceId])
    }

    /// Asks the server to resend the order's callback.
    public func orderManualCallback(referenceId: String, conversationId: String? = nil) async throws -> [String: JSONValue] {
        var payload = ["reference_id": referenceId]
        if let conversationId, !conversationId.isEmpty {
            payload["conversation_id"] = conversationId
        }
        return try await client.post("/order/callback", payload: payload)
    }

    /// Links an order to a related reference ID.
    public func orderRelatedUpdate(referenceId: String, relatedReferenceId: String) async throws -> [String: JSONValue] {
        try await client.patch("/order/releated", payload: ["reference_id": referenceId, "related_reference_id": relatedReferenceId])
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

    public func createOrganizationUser(_ payload: OrgCreateUserRequest) async throws -> OrgCreateUserResponse {
        try await client.post("/organization/user/create", payload: payload)
    }

    /// Creates an access token for an organization user; `expire` is given in minutes.
    public func createOrganizationUserToken(_ payload: OrgUserTokenCreateRequest) async throws -> OrgUserTokenCreateResponse {
        try await client.post("/organization/user/token", payload: payload)
    }

    public func getSuborganizations(page: Int, perPage: Int) async throws -> SuborganizationListResponse {
        try await client.send("GET", "/organization/suborganizations", query: paging(page, perPage).items)
    }

    /// Returns a sub-organization; the server answers 404 when it does not exist.
    public func getSuborganizationDetail(id: String) async throws -> SuborganizationDetail {
        try await client.send("GET", "/organization/suborganizations/\(escape(id))")
    }

    public func getSubmerchantBySuborganization(suborganizationId: String) async throws -> SuborganizationSubmerchantMapping {
        try await client.send("GET", "/organization/suborganizations/\(escape(suborganizationId))/submerchant")
    }
}

public final class SubmerchantService: @unchecked Sendable {
    private let client: SharedAPIClient

    public init(client: SharedAPIClient) {
        self.client = client
    }

    @available(*, deprecated, message: "Currency references are sent as given; use init(client:).")
    public convenience init(client: SharedAPIClient, currencyResolver: CurrencyReferenceResolver) {
        self.init(client: client)
    }

    /// Creates a submerchant. `currencyId` accepts a currency UUID or unit such as "TRY".
    public func createSubmerchant(_ payload: SubmerchantCreateRequest) async throws -> SubmerchantMutationResponse {
        try await client.post("/submerchants", payload: payload)
    }

    public func getSubmerchant(id: String) async throws -> Submerchant {
        try await client.send("GET", "/submerchants/\(escape(id))")
    }

    public func listSubmerchants(page: Int, perPage: Int) async throws -> SubmerchantListResponse {
        try await client.send("GET", "/submerchants", query: paging(page, perPage).items)
    }

    /// Replaces a submerchant; every field is stored as sent.
    public func updateSubmerchant(id: String, payload: SubmerchantUpdateRequest) async throws -> SubmerchantMutationResponse {
        try await client.patch("/submerchants/\(escape(id))", payload: payload)
    }

    public func deleteSubmerchant(id: String) async throws -> SubmerchantMutationResponse {
        try await client.delete("/submerchants/\(escape(id))")
    }

    public func getSuborganizationBySubmerchant(submerchantId: String) async throws -> SubmerchantSuborganizationMapping {
        try await client.send("GET", "/submerchants/\(escape(submerchantId))/suborganization")
    }

    /// Records an item business event; the server answers 202 Accepted.
    public func recordSubmerchantPayoutEvent(_ payload: SubmerchantPayoutEventRequest) async throws -> SubmerchantPayoutEventResponse {
        try await client.post("/submerchant-payout-events", payload: payload)
    }

    /// Approves settlement of an item payment to its submerchant.
    public func approveSubmerchantPayment(_ payload: SubmerchantPaymentAction) async throws -> SubmerchantPaymentActionResponse {
        try await client.post("/submerchants/payment/approve", payload: payload)
    }

    /// Withdraws settlement approval of an item payment.
    public func disapproveSubmerchantPayment(_ payload: SubmerchantPaymentAction) async throws -> SubmerchantPaymentActionResponse {
        try await client.post("/submerchants/payment/disapprove", payload: payload)
    }

    /// Changes the seller or payout of a completed marketplace item.
    public func updateSubmerchantPaymentItem(_ payload: SubmerchantPaymentItemUpdate) async throws -> SubmerchantPaymentItemUpdateResponse {
        try await client.put("/submerchants/payment/item", payload: payload)
    }
}

public final class VposService: @unchecked Sendable {
    private let client: SharedAPIClient

    public init(client: SharedAPIClient) {
        self.client = client
    }

    @available(*, deprecated, message: "Currency references are sent as given; use init(client:).")
    public convenience init(client: SharedAPIClient, currencyResolver: CurrencyReferenceResolver) {
        self.init(client: client)
    }

    public func listVpos(page: Int, perPage: Int) async throws -> VposListResponse {
        try await listVposWithFilter(page: page, perPage: perPage, filter: .init())
    }

    public func listVposWithFilter(page: Int, perPage: Int, filter: VposListFilter) async throws -> VposListResponse {
        let query = paging(page, perPage).with("suborganization_id", filter.suborganizationId)
        return try await client.send("GET", "/vpos", query: query.items)
    }

    /// Creates a VPOS. `currencies` accepts currency UUIDs or units such as "TRY".
    public func createVpos(_ payload: VposCreateRequest) async throws -> VposMutationResponse {
        try await client.post("/vpos", payload: payload)
    }

    public func getVpos(id: String) async throws -> Vpos {
        try await client.send("GET", "/vpos/\(escape(id))")
    }

    /// Replaces a VPOS configuration. Read the VPOS with `getVpos(id:)` and send every field back.
    public func updateVpos(id: String, payload: VposUpdateRequest) async throws -> VposMutationResponse {
        try await client.patch("/vpos/\(escape(id))", payload: payload)
    }

    public func deleteVpos(id: String) async throws -> VposMutationResponse {
        try await client.delete("/vpos/\(escape(id))")
    }

    public func listVposAcquirers() async throws -> VposAcquirerListResponse {
        try await client.get("/vpos/acquirers")
    }

    public func listCardSchemes() async throws -> CardSchemeListResponse {
        try await client.get("/vpos/card-schemes")
    }

    public func listVposAcquirerTemplates() async throws -> VposAcquirerTemplateListResponse {
        try await client.get("/vpos/acquirer-templates")
    }

    public func listVposSubmerchants(
        page: Int,
        perPage: Int,
        vposId: String? = nil,
        externalReferenceId: String? = nil
    ) async throws -> VposSubmerchantListResponse {
        let query = paging(page, perPage)
            .with("vpos_id", vposId)
            .with("external_reference_id", externalReferenceId)
        return try await client.send("GET", "/vpos-submerchant", query: query.items)
    }

    public func createVposSubmerchant(_ payload: VposSubmerchantCreateRequest) async throws -> VposMutationResponse {
        try await client.post("/vpos-submerchant", payload: payload)
    }

    /// Returns a VPOS submerchant; the server answers 404 when it does not exist.
    public func getVposSubmerchant(id: String) async throws -> VposSubmerchant {
        try await client.send("GET", "/vpos-submerchant/\(escape(id))")
    }

    public func updateVposSubmerchant(id: String, payload: VposSubmerchantUpdateRequest) async throws -> VposMutationResponse {
        try await client.patch("/vpos-submerchant/\(escape(id))", payload: payload)
    }

    public func deleteVposSubmerchant(id: String) async throws -> VposMutationResponse {
        try await client.delete("/vpos-submerchant/\(escape(id))")
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
        try await client.send("GET", "/subscription/list", query: paging(page, perPage).items)
    }

    public func redirectSubscription(_ payload: SubscriptionRedirectRequest) async throws -> SubscriptionRedirectResponse {
        try await client.post("/subscription/redirect", payload: payload)
    }
}

/// Card installment options and order charging.
public final class CheckoutService: @unchecked Sendable {
    private let client: SharedAPIClient

    public init(client: SharedAPIClient) {
        self.client = client
    }

    /// Returns the installment options and commission rates for a card BIN and amount.
    public func getCardInstallments(_ payload: CardInstallmentsRequest) async throws -> CardInstallmentsResponse {
        let query = QueryBuilder()
            .with("bin", payload.bin)
            .with("amount", payload.amount.queryText)
            .with("currency", payload.currency)
            .with("is_three_d", payload.isThreeD ? "true" : nil)
        return try await client.send("GET", "/card/installments", query: query.items)
    }

    /// Returns installment options grouped by bank card program, with an interest-free flag per row.
    public func getInstallmentTable(_ payload: InstallmentTableRequest) async throws -> InstallmentTableResponse {
        let query = QueryBuilder()
            .with("amount", payload.amount.queryText)
            .with("currency", payload.currency)
            .with("is_three_d", payload.isThreeD ? "true" : nil)
        return try await client.send("GET", "/card/installment-table", query: query.items)
    }

    /// Charges an order, for example with its saved card.
    public func chargeOrder(_ payload: OrderChargeRequest) async throws -> OrderChargeResponse {
        try await client.post("/order/charge", payload: payload)
    }

    @available(*, deprecated, message: "Use getCardInstallments, getInstallmentTable or chargeOrder.")
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

/// Saved card (tokenization) operations.
public final class CardService: @unchecked Sendable {
    private let client: SharedAPIClient

    public init(client: SharedAPIClient) {
        self.client = client
    }

    /// Tokenizes a card and returns 3D secure form details when required.
    public func tokenizeCard(_ payload: CardTokenizeRequest) async throws -> CardTokenizeResponse {
        try await client.post("/tokenization/card/tokenize", payload: payload)
    }

    public func listSavedCards(page: Int, perPage: Int) async throws -> ListSavedCardsResponse {
        try await client.send("GET", "/tokenization/card/list", query: paging(page, perPage).items)
    }

    public func deleteSavedCard(id: String) async throws -> DeleteSavedCardResponse {
        try await client.delete("/tokenization/card/\(escape(id))")
    }

    @available(*, deprecated, message: "Use tokenizeCard, listSavedCards or deleteSavedCard.")
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

extension Double {
    /// The shortest text that reads back as the same value, such as "100" or "100.5".
    var queryText: String {
        if rounded() == self, abs(self) < 1e15 {
            return String(Int64(self))
        }
        return String(self)
    }
}
