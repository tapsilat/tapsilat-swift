import XCTest
@testable import Tapsilat

/// Records requests and answers them with canned responses.
final class StubURLProtocol: URLProtocol {
    struct Recorded {
        let method: String
        let path: String
        let query: String?
        let headers: [String: String]
        let body: Data?

        var json: [String: Any]? {
            body.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
        }
    }

    struct Reply {
        var status = 200
        var contentType = "application/json"
        var body = "{}"
    }

    private static let lock = NSLock()
    private static var _replies: [String: Reply] = [:]
    private static var _requests: [Recorded] = []

    static func reset() {
        lock.withLock {
            _replies = [:]
            _requests = []
        }
    }

    /// Answers `method path` (the percent-encoded path, without the query) with `reply`.
    static func on(_ method: String, _ path: String, _ reply: Reply) {
        lock.withLock { _replies["\(method) \(path)"] = reply }
    }

    static var requests: [Recorded] {
        lock.withLock { _requests }
    }

    static func last(_ method: String, _ path: String) -> Recorded? {
        requests.last { $0.method == method && $0.path == path }
    }

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let url = request.url!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let method = request.httpMethod ?? "GET"
        let recorded = Recorded(
            method: method,
            path: components.percentEncodedPath,
            query: components.percentEncodedQuery,
            headers: request.allHTTPHeaderFields ?? [:],
            body: request.httpBody ?? request.httpBodyStream.map(Self.read)
        )
        let reply = Self.lock.withLock { () -> Reply in
            Self._requests.append(recorded)
            return Self._replies["\(method) \(recorded.path)"] ?? Reply(status: 501, body: #"{"error":"no stub"}"#)
        }

        let response = HTTPURLResponse(
            url: url,
            statusCode: reply.status,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": reply.contentType]
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(reply.body.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    private static func read(_ stream: InputStream) -> Data {
        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            guard count > 0 else { break }
            data.append(buffer, count: count)
        }
        return data
    }
}

final class PanelParityTests: XCTestCase {
    private var api: Tapsilat!

    override func setUp() {
        super.setUp()
        StubURLProtocol.reset()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        api = Tapsilat(endpoint: "https://panel.example/api/v1", token: "test-token", session: URLSession(configuration: config))
    }

    private func reply(_ body: String, status: Int = 200) -> StubURLProtocol.Reply {
        StubURLProtocol.Reply(status: status, body: body)
    }

    func testRequestsCarryAuthorizationAndAcceptHeaders() async throws {
        StubURLProtocol.on("GET", "/api/v1/order/ref-1/status", reply(#"{"status":"Paid"}"#))

        let status = try await api.getOrderStatus(orderReferenceId: "ref-1")

        XCTAssertEqual(status.status, "Paid")
        let request = try XCTUnwrap(StubURLProtocol.last("GET", "/api/v1/order/ref-1/status"))
        XCTAssertEqual(request.headers["Authorization"], "Bearer test-token")
        XCTAssertEqual(request.headers["Accept"], "application/json")
    }

    func testCreateOrderCleansGsmAndFillsCheckoutURL() async throws {
        StubURLProtocol.on("POST", "/api/v1/order/create", reply(#"{"order_id":"order-1","reference_id":"ref-1"}"#))
        StubURLProtocol.on("GET", "/api/v1/order/ref-1", reply(#"{"reference_id":"ref-1","checkout_url":"https://checkout.example/ref-1"}"#))

        let response = try await api.createOrder(Order(
            locale: "tr",
            amount: 100,
            currency: "TRY",
            buyer: OrderBuyer(name: "John", gsmNumber: "+90 (555) 123 45 67", birthDate: "1990-01-02"),
            checkoutDesign: OrderCheckoutDesign(accentColor: "#123456", darkModeEnabled: true, darkColors: ["text_color": "#ffffff"]),
            paymentTerms: [OrderPaymentTerm(amount: 50, dueDate: "2026-01-15T00:00:00Z", termSequence: 1)],
            orderCards: [OrderCard(cardId: "card-1", cardSequence: 1)]
        ))

        XCTAssertEqual(response.orderId, "order-1")
        XCTAssertEqual(response.checkoutUrl, "https://checkout.example/ref-1")
        let body = try XCTUnwrap(StubURLProtocol.last("POST", "/api/v1/order/create")?.json)
        let buyer = try XCTUnwrap(body["buyer"] as? [String: Any])
        XCTAssertEqual(buyer["gsm_number"] as? String, "+905551234567")
        XCTAssertEqual(buyer["birth_date"] as? String, "1990-01-02")
        XCTAssertEqual((body["order_cards"] as? [[String: Any]])?.first?["card_id"] as? String, "card-1")
        XCTAssertEqual((body["payment_terms"] as? [[String: Any]])?.first?["due_date"] as? String, "2026-01-15T00:00:00Z")
        let design = try XCTUnwrap(body["checkout_design"] as? [String: Any])
        XCTAssertEqual(design["accent_color"] as? String, "#123456")
        XCTAssertEqual(design["dark_colors"] as? [String: String], ["text_color": "#ffffff"])
        XCTAssertNil(body["redirect_success_url"])
    }

    func testOrderDetailDecodesThePanelShape() async throws {
        StubURLProtocol.on("GET", "/api/v1/order/ref%2F1", reply(#"""
        {"reference_id":"ref/1","status":3,"customer_paid_amount":101.5,"buyer":{"birth_date":"1990-01-02"},
         "basket_items":[{"id":"item-1","mcc":"5411","item_payments":[{"id":"pay-1","type":"CREDIT_CARD"}]}],
         "payment_terms":[{"id":"term-1","term_reference_id":"t-1","due_date":"2026-01-15T00:00:00Z"}],
         "payment_requests":[{"id":"req-1","paid":true}],"refund_cancel_requests":[{"id":"rc-1","type":2}]}
        """#))

        let order = try await api.getOrder(orderReferenceId: "ref/1")

        XCTAssertEqual(order.status, 3)
        XCTAssertEqual(order.customerPaidAmount, 101.5)
        XCTAssertEqual(order.buyer?.birthDate, "1990-01-02")
        XCTAssertEqual(order.basketItems?.first?.mcc, "5411")
        XCTAssertEqual(order.basketItems?.first?.itemPayments?.first?.type, "CREDIT_CARD")
        XCTAssertEqual(order.paymentTerms?.first?.id, "term-1")
        XCTAssertEqual(order.paymentRequests?.first?.paid, true)
        XCTAssertEqual(order.refundCancelRequests?.first?.type, 2)
    }

    func testOrderListSendsEveryFilter() async throws {
        StubURLProtocol.on("GET", "/api/v1/order/list", reply(#"{"rows":[],"total":0}"#))

        _ = try await api.getOrderList(filter: OrderListFilter(
            page: 2,
            perPage: 50,
            startDate: "2026-01-01",
            conversationId: "c+1",
            buyerId: "b-1",
            status: 3
        ))

        XCTAssertEqual(
            StubURLProtocol.last("GET", "/api/v1/order/list")?.query,
            "page=2&per_page=50&start_date=2026-01-01&conversation_id=c%2B1&buyer_id=b-1&status=3"
        )
    }

    func testSubmerchantsAndTransactionsDecodeThePanelShapes() async throws {
        StubURLProtocol.on("GET", "/api/v1/order/submerchants", reply(#"{"row":[{"id":"sm-1","submerchant_key":"key-1"}],"total":1}"#))
        StubURLProtocol.on("GET", "/api/v1/order/ref-1/transactions", reply(#"[{"id":"tx-1"}]"#))
        StubURLProtocol.on("GET", "/api/v1/order/ref-2/transactions", reply("null"))

        let page = try await api.order.getOrderSubmerchants(page: 1, perPage: 10)
        let transactions = try await api.order.getOrderTransactions(referenceId: "ref-1")
        let none = try await api.order.getOrderTransactions(referenceId: "ref-2")

        XCTAssertEqual(page.rows?.first?.submerchantKey, "key-1")
        XCTAssertEqual(transactions, [.object(["id": .string("tx-1")])])
        XCTAssertNil(none)
    }

    func testPaymentTermsUseTheTermRoutes() async throws {
        StubURLProtocol.on("GET", "/api/v1/order/term", reply(#"{"term_sequence":1}"#))
        StubURLProtocol.on("POST", "/api/v1/order/term", reply(#"{"message":"ok","code":0}"#))
        StubURLProtocol.on("PATCH", "/api/v1/order/term", reply(#"{"message":"ok"}"#))
        StubURLProtocol.on("DELETE", "/api/v1/order/term", reply(#"{"message":"ok"}"#))
        StubURLProtocol.on("POST", "/api/v1/order/term/refund", reply(#"{"is_success":true}"#))

        _ = try await api.order.getOrderTerm(termReferenceId: "t+1")
        _ = try await api.order.createOrderTerm(OrderTermCreateRequest(orderId: "order-1", required: true, amount: 10, dueDate: "2026-02-01"))
        _ = try await api.order.updateOrderTerm(OrderTermUpdateRequest(termReferenceId: "t-1", amount: 12))
        _ = try await api.order.deleteOrderTerm(orderId: "order-1", termReferenceId: "t-1")
        _ = try await api.order.refundOrderTerm(OrderTermRefundRequest(referenceId: "ref-1", termId: "term-1", amount: 5))

        XCTAssertEqual(StubURLProtocol.last("GET", "/api/v1/order/term")?.query, "term_reference_id=t%2B1")
        let created = try XCTUnwrap(StubURLProtocol.last("POST", "/api/v1/order/term")?.json)
        XCTAssertEqual(created["order_id"] as? String, "order-1")
        XCTAssertEqual(created["due_date"] as? String, "2026-02-01")
        XCTAssertEqual(created["required"] as? Bool, true)
        XCTAssertEqual(StubURLProtocol.last("PATCH", "/api/v1/order/term")?.json?["amount"] as? Double, 12)
        let deleted = try XCTUnwrap(StubURLProtocol.last("DELETE", "/api/v1/order/term")?.json)
        XCTAssertEqual(deleted as? [String: String], ["order_id": "order-1", "term_reference_id": "t-1"])
        let refunded = try XCTUnwrap(StubURLProtocol.last("POST", "/api/v1/order/term/refund")?.json)
        XCTAssertEqual(refunded["reference_id"] as? String, "ref-1")
        XCTAssertEqual(refunded["term_id"] as? String, "term-1")
    }

    func testOrderActionsUseThePanelRoutes() async throws {
        StubURLProtocol.on("POST", "/api/v1/order/callback", reply(#"{"message":"ok"}"#))
        StubURLProtocol.on("PATCH", "/api/v1/order/releated", reply(#"{"status":1,"is_success":true}"#))
        StubURLProtocol.on("POST", "/api/v1/order/refund-all", reply(#"{"status":"OK","is_success":true}"#))
        StubURLProtocol.on("GET", "/api/v1/order/ref-1/payment-details", reply(#"{"rows":[]}"#))
        StubURLProtocol.on("POST", "/api/v1/order/payment-details", reply(#"{"rows":[]}"#))

        _ = try await api.order.orderManualCallback(referenceId: "ref-1", conversationId: "conv-1")
        _ = try await api.order.orderRelatedUpdate(referenceId: "ref-1", relatedReferenceId: "ref-0")
        let refunded = try await api.refundAllOrder(referenceId: "ref-1")
        _ = try await api.order.getOrderPaymentDetails(referenceId: "ref-1")
        _ = try await api.order.getOrderPaymentDetails(conversationId: "conv-1")

        XCTAssertEqual(StubURLProtocol.last("POST", "/api/v1/order/callback")?.json as? [String: String], ["reference_id": "ref-1", "conversation_id": "conv-1"])
        XCTAssertEqual(StubURLProtocol.last("PATCH", "/api/v1/order/releated")?.json as? [String: String], ["reference_id": "ref-1", "related_reference_id": "ref-0"])
        XCTAssertEqual(StubURLProtocol.last("POST", "/api/v1/order/refund-all")?.json as? [String: String], ["reference_id": "ref-1"])
        XCTAssertEqual(refunded.isSuccess, true)
        XCTAssertEqual(StubURLProtocol.last("POST", "/api/v1/order/payment-details")?.json as? [String: String], ["conversation_id": "conv-1"])
    }

    func testPaymentsAndCharge() async throws {
        StubURLProtocol.on("POST", "/api/v1/order/payments", reply(#"{"payments":[{"id":"p-1","type":"CREDIT_CARD","merchant_net_amount":97.5}],"total_merchant_net_amount":97.5}"#))
        StubURLProtocol.on("POST", "/api/v1/order/charge", reply(#"{"isSuccess":true,"message":"charged","statusCode":"00","errorCode":""}"#))

        let payments = try await api.getOrderPayments(GetOrderPaymentsRequest(orderReferenceId: "ref-1"))
        let charged = try await api.chargeOrder(OrderChargeRequest(orderReferenceId: "ref-1", retry: true))

        XCTAssertEqual(payments.payments?.first?.type, "CREDIT_CARD")
        XCTAssertEqual(payments.totalMerchantNetAmount, 97.5)
        XCTAssertEqual(charged.isSuccess, true)
        XCTAssertEqual(charged.statusCode, "00")
        XCTAssertEqual(StubURLProtocol.last("POST", "/api/v1/order/payments")?.json as? [String: String], ["order_reference_id": "ref-1"])
        let charge = try XCTUnwrap(StubURLProtocol.last("POST", "/api/v1/order/charge")?.json)
        XCTAssertEqual(charge["order_reference_id"] as? String, "ref-1")
        XCTAssertEqual(charge["retry"] as? Bool, true)
    }

    func testCardInstallmentsAndInstallmentTable() async throws {
        StubURLProtocol.on("GET", "/api/v1/card/installments", reply(#"{"is_installment_available":true,"installments":[{"installment":3,"commission_rate":1.5,"monthly_payment":"34.00"}]}"#))
        StubURLProtocol.on("GET", "/api/v1/card/installment-table", reply(#"{"groups":[{"bank":"Bank","program_code":"BONUS","rows":[{"installment":2,"is_interest_free":true}]}]}"#))

        let options = try await api.getCardInstallments(CardInstallmentsRequest(bin: "54066200", amount: 100.5, isThreeD: true))
        let table = try await api.getInstallmentTable(InstallmentTableRequest(amount: 100))

        XCTAssertEqual(options.isInstallmentAvailable, true)
        XCTAssertEqual(options.installments?.first?.commissionRate, 1.5)
        XCTAssertEqual(table.groups?.first?.rows?.first?.isInterestFree, true)
        XCTAssertEqual(StubURLProtocol.last("GET", "/api/v1/card/installments")?.query, "bin=54066200&amount=100.5&currency=TRY&is_three_d=true")
        XCTAssertEqual(StubURLProtocol.last("GET", "/api/v1/card/installment-table")?.query, "amount=100&currency=TRY")
    }

    func testOrganizationRoutes() async throws {
        StubURLProtocol.on("GET", "/api/v1/organization/settings", reply(#"{"ttl":30,"has_kyb_kyx_template":true}"#))
        StubURLProtocol.on("GET", "/api/v1/organization/currency-presets", reply(#"{"items":[{"currency_code":"EUR","minor_unit":2}]}"#))
        StubURLProtocol.on("POST", "/api/v1/organization/user/token", reply(#"{"token":"tok","user_id":"u-1"}"#))
        StubURLProtocol.on("GET", "/api/v1/organization/suborganizations/sub-1", reply(#"{"id":"sub-1","parent_id":"org-1"}"#))

        let settings = try await api.getOrganizationSettings()
        let presets = try await api.listOrganizationCurrencyPresets()
        let token = try await api.organization.createOrganizationUserToken(OrgUserTokenCreateRequest(email: "a@example.com", expire: 60))
        let detail = try await api.organization.getSuborganizationDetail(id: "sub-1")

        XCTAssertEqual(settings.ttl, 30)
        XCTAssertEqual(settings.hasKybKyxTemplate, true)
        XCTAssertEqual(presets.items?.first?.minorUnit, 2)
        XCTAssertEqual(token.token, "tok")
        XCTAssertEqual(detail.parentId, "org-1")
        let tokenBody = try XCTUnwrap(StubURLProtocol.last("POST", "/api/v1/organization/user/token")?.json)
        XCTAssertEqual(tokenBody["email"] as? String, "a@example.com")
        XCTAssertEqual(tokenBody["expire"] as? Int, 60)
    }

    func testSubmerchantRoutesSendCurrencyReferencesAsGiven() async throws {
        StubURLProtocol.on("GET", "/api/v1/submerchants", reply(#"{"row":[{"id":"sm-1","status":"ACTIVE"}],"total":1}"#))
        StubURLProtocol.on("POST", "/api/v1/submerchants", reply(#"{"code":0,"message":"created"}"#))
        StubURLProtocol.on("PUT", "/api/v1/submerchants/payment/item", reply(#"{"operation_id":"op-1"}"#))
        StubURLProtocol.on("POST", "/api/v1/submerchant-payout-events", reply(#"{"id":"ev-1"}"#, status: 202))

        let page = try await api.submerchant.listSubmerchants(page: 1, perPage: 20)
        let created = try await api.submerchant.createSubmerchant(SubmerchantCreateRequest(name: "Seller", currencyId: "TRY", subMerchantType: "PERSONAL"))
        _ = try await api.submerchant.updateSubmerchantPaymentItem(SubmerchantPaymentItemUpdate(
            locale: "tr", conversationId: "c-1", paymentTransactionId: "tx-1", subMerchantKey: "key-1", subMerchantPrice: "10.50", acquirer: "acq"
        ))
        let event = try await api.submerchant.recordSubmerchantPayoutEvent(SubmerchantPayoutEventRequest(
            idempotencyKey: "k-1", orderReference: "ref-1", itemId: "item-1", eventType: "DELIVERED"
        ))

        XCTAssertEqual(page.rows?.first?.status, "ACTIVE")
        XCTAssertEqual(created.message, "created")
        XCTAssertEqual(event.id, "ev-1")
        let body = try XCTUnwrap(StubURLProtocol.last("POST", "/api/v1/submerchants")?.json)
        XCTAssertEqual(body["currency_id"] as? String, "TRY")
        XCTAssertEqual(body["sub_merchant_type"] as? String, "PERSONAL")
        XCTAssertNil(StubURLProtocol.last("GET", "/api/v1/organization/currencies"))
        XCTAssertEqual(StubURLProtocol.last("PUT", "/api/v1/submerchants/payment/item")?.json?["sub_merchant_price"] as? String, "10.50")
    }

    func testVposUpdateSendsTheFullConfiguration() async throws {
        StubURLProtocol.on("PATCH", "/api/v1/vpos/vpos-1", reply(#"{"code":0,"message":"updated"}"#))
        StubURLProtocol.on("GET", "/api/v1/vpos", reply(#"{"rows":[{"id":"vpos-1","name":"Main"}]}"#))

        _ = try await api.vpos.updateVpos(id: "vpos-1", payload: VposUpdateRequest(
            name: "Main", type: "BANK", currencies: ["TRY"], failover: true, pfId: "pf-1", tls: true, rootCa: "ca", mainInstallment: true
        ))
        let page = try await api.vpos.listVposWithFilter(page: 1, perPage: 10, filter: VposListFilter(suborganizationId: "sub-1"))

        let body = try XCTUnwrap(StubURLProtocol.last("PATCH", "/api/v1/vpos/vpos-1")?.json)
        XCTAssertEqual(body["name"] as? String, "Main")
        XCTAssertEqual(body["type"] as? String, "BANK")
        XCTAssertEqual(body["currencies"] as? [String], ["TRY"])
        XCTAssertEqual(body["failover"] as? Bool, true)
        XCTAssertEqual(body["pf_id"] as? String, "pf-1")
        XCTAssertEqual(body["root_ca"] as? String, "ca")
        XCTAssertEqual(body["main_installment"] as? Bool, true)
        XCTAssertEqual(page.rows?.first?.name, "Main")
        XCTAssertEqual(StubURLProtocol.last("GET", "/api/v1/vpos")?.query, "page=1&per_page=10&suborganization_id=sub-1")
    }

    func testSavedCardRoutes() async throws {
        StubURLProtocol.on("GET", "/api/v1/tokenization/card/list", reply(#"{"rows":[{"id":"card-1","last_four":"0004"}]}"#))
        StubURLProtocol.on("DELETE", "/api/v1/tokenization/card/card-1", reply(#"{"success":true}"#))

        let cards = try await api.card.listSavedCards(page: 1, perPage: 10)
        let deleted = try await api.card.deleteSavedCard(id: "card-1")

        XCTAssertEqual(cards.rows?.first?.lastFour, "0004")
        XCTAssertEqual(deleted.success, true)
    }

    func testMarketplaceRoutesUseAPIVersion2AndKeepRevisionsOpaque() async throws {
        let revision = "2026-10-19T10:00:00.123456789Z"
        StubURLProtocol.on("GET", "/api/v2/submerchants/s-1", reply(#"{"id":"s-1","revision":"\#(revision)","approval_mode":null}"#))
        StubURLProtocol.on("PATCH", "/api/v2/submerchants/s-1", reply(#"{"approval_required":true}"#))
        StubURLProtocol.on("POST", "/api/v2/submerchant-payouts/approve", reply(#"{"status":"accepted"}"#, status: 202))
        StubURLProtocol.on("GET", "/api/v2/marketplace/seller-contracts", reply(#"{"contracts":{"v-1":{"supported":true,"fields":{"tax_number":true}}}}"#))
        StubURLProtocol.on("DELETE", "/api/v2/marketplace/release-policies/rel-1", reply("", status: 204))

        let seller = try await api.marketplace.getSubmerchant(id: "s-1")
        let update = try await api.marketplace.updateSubmerchant(id: "s-1", payload: MarketplaceProfileUpdate(name: "Seller", revision: seller.revision ?? ""))
        let accepted = try await api.marketplace.approvePayouts(MarketplacePayoutApproval(ids: ["p-1", "p-2"]))
        let contracts = try await api.marketplace.getSellerContracts(MarketplaceContractFilter(
            currencyId: "TRY", sellerType: "PERSONAL", vposIds: ["v-1", "v-2"]
        ))
        try await api.marketplace.deleteReleasePolicy(id: "rel-1")

        XCTAssertEqual(seller.revision, revision)
        XCTAssertNil(seller.approvalMode)
        XCTAssertEqual(update.approvalRequired, true)
        XCTAssertEqual(StubURLProtocol.last("PATCH", "/api/v2/submerchants/s-1")?.json?["revision"] as? String, revision)
        XCTAssertEqual(accepted.status, "accepted")
        XCTAssertEqual(StubURLProtocol.last("POST", "/api/v2/submerchant-payouts/approve")?.json?["ids"] as? [String], ["p-1", "p-2"])
        XCTAssertEqual(contracts.contracts?["v-1"]?.fields?["tax_number"], true)
        XCTAssertEqual(
            StubURLProtocol.last("GET", "/api/v2/marketplace/seller-contracts")?.query,
            "currency_id=TRY&seller_type=PERSONAL&operation=create&vpos_id=v-1&vpos_id=v-2"
        )
    }

    func testApprovalPolicyCurrencyUnitsAreResolvedToUUIDs() async throws {
        let uuid = "3fa85f64-5717-4562-b3fc-2c963f66afa6"
        StubURLProtocol.on("GET", "/api/v1/organization/currencies", reply(#"{"currencies":[{"id":"\#(uuid)","currency_unit":"TRY"}]}"#))
        StubURLProtocol.on("POST", "/api/v2/marketplace/approval-policies", reply(#"{"id":"pol-1"}"#, status: 201))

        try await api.marketplace.createApprovalPolicy(MarketplaceApprovalPolicyInput(
            name: "Large", priority: 1, enabled: true, minAmount: "1000", currencyId: "try", mode: "manual"
        ))

        let body = try XCTUnwrap(StubURLProtocol.last("POST", "/api/v2/marketplace/approval-policies")?.json)
        XCTAssertEqual(body["currency_id"] as? String, uuid)
        XCTAssertEqual(body["min_amount"] as? String, "1000")
        XCTAssertEqual(body["mode"] as? String, "manual")
    }

    func testSubscriptionRedirectSendsTheSubscriptionID() async throws {
        StubURLProtocol.on("POST", "/api/v1/subscription/redirect", reply(#"{"url":"https://pay.example/s-1"}"#))

        let response = try await api.subscription.redirectSubscription(SubscriptionRedirectRequest(subscriptionId: "s-1"))

        XCTAssertEqual(response.url, "https://pay.example/s-1")
        XCTAssertEqual(StubURLProtocol.last("POST", "/api/v1/subscription/redirect")?.json as? [String: String], ["subscription_id": "s-1"])
    }

    func testValidationErrorsExposeCodeAndFieldErrors() async throws {
        StubURLProtocol.on("POST", "/api/v1/order/cancel", reply(#"{"message":"INVALID_REQUEST_BODY","code":400000,"errors":{"reference_id":"required"}}"#, status: 400))

        do {
            _ = try await api.cancelOrder(CancelOrder(referenceId: ""))
            XCTFail("expected an error")
        } catch let error as APIError {
            XCTAssertEqual(error.statusCode, 400)
            XCTAssertEqual(error.code, "400000")
            XCTAssertEqual(error.messageText, "INVALID_REQUEST_BODY")
            XCTAssertEqual(error.errors?["reference_id"], .string("required"))
            XCTAssertTrue(error.errorDescription?.contains("[400000] INVALID_REQUEST_BODY") == true)
        }
    }

    func testGRPCErrorsUseTheErrorField() async throws {
        StubURLProtocol.on("GET", "/api/v2/submerchant-payouts/missing", reply(#"{"error":"payout is not eligible","code":9}"#, status: 424))

        do {
            _ = try await api.marketplace.getPayout(id: "missing")
            XCTFail("expected an error")
        } catch let error as APIError {
            XCTAssertEqual(error.statusCode, 424)
            XCTAssertEqual(error.code, "9")
            XCTAssertEqual(error.messageText, "payout is not eligible")
        }
    }

    func testAnHTMLPageIsReportedAsAnAPIError() async throws {
        StubURLProtocol.on("GET", "/api/v1/order/ref-1/status", StubURLProtocol.Reply(status: 200, contentType: "text/html; charset=utf-8", body: "<!doctype html><html></html>"))

        do {
            _ = try await api.getOrderStatus(orderReferenceId: "ref-1")
            XCTFail("expected an error")
        } catch let error as APIError {
            XCTAssertEqual(error.statusCode, 200)
            XCTAssertTrue(error.messageText?.contains("unexpected non-JSON response") == true)
            XCTAssertTrue(error.rawBody.hasPrefix("<!doctype html>"))
        }
    }

    func testAnInvalidEndpointThrowsInsteadOfCrashing() async throws {
        let api = Tapsilat(endpoint: "not a url", token: "t")

        do {
            _ = try await api.getOrderStatus(orderReferenceId: "ref-1")
            XCTFail("expected an error")
        } catch let error as ValidationError {
            XCTAssertTrue(error.message.contains("Invalid endpoint"))
        }
    }

    func testVersionedEndpoint() throws {
        let client = SharedAPIClient(endpoint: "https://panel.example/api/v1/", token: "t")
        XCTAssertEqual(try client.versionedEndpoint("v2").absoluteString, "https://panel.example/api/v2")
        let bare = SharedAPIClient(endpoint: "https://panel.example", token: "t")
        XCTAssertEqual(try bare.versionedEndpoint("v2").absoluteString, "https://panel.example/api/v2")
    }
}
