import Foundation

public final class Tapsilat: @unchecked Sendable {
    private let client: SharedAPIClient
    private let currencyResolver: CurrencyReferenceResolver

    public let organization: OrganizationService
    public let order: OrderService
    public let submerchant: SubmerchantService
    public let vpos: VposService
    public let subscription: SubscriptionService
    public let checkout: CheckoutService
    public let credit: CreditService
    public let card: CardService
    public let wallet: WalletService
    public let marketplace: MarketplaceService

    /// Creates a client for `endpoint`, the API v1 base URL. Marketplace calls use API v2,
    /// derived from it. Pass `session` to use your own `URLSession`.
    public init(endpoint: String, token: String, timeout: TimeInterval = 30, session: URLSession? = nil) {
        let client = SharedAPIClient(endpoint: endpoint, token: token, timeout: timeout, session: session)
        let organization = OrganizationService(client: client)
        let currencyResolver = CurrencyReferenceResolver(organizationService: organization)

        self.client = client
        self.organization = organization
        self.currencyResolver = currencyResolver
        self.order = OrderService(client: client)
        self.submerchant = SubmerchantService(client: client)
        self.vpos = VposService(client: client)
        self.subscription = SubscriptionService(client: client)
        self.checkout = CheckoutService(client: client)
        self.credit = CreditService(client: client)
        self.card = CardService(client: client)
        self.wallet = WalletService(client: client)
        self.marketplace = MarketplaceService(client: client, currencyResolver: currencyResolver)
    }

    public static func newAPI(token: String, timeout: TimeInterval = 30) -> Tapsilat {
        Tapsilat(endpoint: TapsilatConstants.defaultEndpoint, token: token, timeout: timeout)
    }

    public static func newCustomAPI(endpoint: String, token: String, timeout: TimeInterval = 30) -> Tapsilat {
        Tapsilat(endpoint: endpoint, token: token, timeout: timeout)
    }

    public func createOrder(_ payload: Order) async throws -> OrderResponse {
        try await order.createOrder(payload)
    }

    public func getOrder(orderReferenceId: String) async throws -> OrderDetail {
        try await order.getOrder(orderReferenceId: orderReferenceId)
    }

    public func getOrderByConversationID(conversationId: String) async throws -> OrderDetail {
        try await order.getOrderByConversationID(conversationId: conversationId)
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
        try await order.getOrderList(
            page: page,
            perPage: perPage,
            buyerId: buyerId,
            startDate: startDate,
            endDate: endDate,
            organizationId: organizationId,
            relatedReferenceId: relatedReferenceId
        )
    }

    public func getOrderList(filter: OrderListFilter) async throws -> PaginatedData {
        try await order.getOrderList(filter: filter)
    }

    public func getOrderPayments(_ payload: GetOrderPaymentsRequest) async throws -> GetOrderPaymentsResponse {
        try await order.getOrderPayments(payload)
    }

    /// Charges an order, for example with its saved card.
    public func chargeOrder(_ payload: OrderChargeRequest) async throws -> OrderChargeResponse {
        try await order.chargeOrder(payload)
    }

    /// Returns the installment options and commission rates for a card BIN and amount.
    public func getCardInstallments(_ payload: CardInstallmentsRequest) async throws -> CardInstallmentsResponse {
        try await checkout.getCardInstallments(payload)
    }

    /// Returns installment options grouped by bank card program.
    public func getInstallmentTable(_ payload: InstallmentTableRequest) async throws -> InstallmentTableResponse {
        try await checkout.getInstallmentTable(payload)
    }

    public func getOrderStatus(orderReferenceId: String) async throws -> OrderStatus {
        try await order.getOrderStatus(orderReferenceId: orderReferenceId)
    }

    public func cancelOrder(_ payload: CancelOrder) async throws -> RefundCancelOrderResponse {
        try await order.cancelOrder(payload)
    }

    public func refundOrder(_ payload: RefundOrder) async throws -> RefundCancelOrderResponse {
        try await order.refundOrder(payload)
    }

    public func refundAllOrder(referenceId: String) async throws -> RefundCancelOrderResponse {
        try await order.refundAllOrder(referenceId: referenceId)
    }

    public func getOrganizationSettings() async throws -> OrganizationSettings {
        try await organization.getOrganizationSettings()
    }

    public func getOrganizationCurrencies() async throws -> OrganizationCurrenciesResponse {
        try await organization.getOrganizationCurrencies()
    }

    public func listOrganizationCurrencyPresets() async throws -> OrganizationCurrencyPresetsResponse {
        try await organization.listOrganizationCurrencyPresets()
    }

    public func createOrganizationCurrency(currencyCode: String) async throws -> CreateOrganizationCurrencyResponse {
        let result = try await organization.createOrganizationCurrency(currencyCode: currencyCode)
        await currencyResolver.invalidateCache()
        return result
    }

    /// Returns the organization currency UUID for `ref`. A UUID is returned unchanged; a unit
    /// such as "TRY" is looked up in the organization's currencies, which are cached. Most
    /// endpoints accept units directly, so this is only needed where a UUID is required.
    public func resolveCurrencyId(_ ref: String) async throws -> String {
        try await currencyResolver.resolveCurrencyId(ref)
    }
}
