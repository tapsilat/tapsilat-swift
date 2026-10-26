import XCTest
@testable import Tapsilat

final class ElementsSessionTests: XCTestCase {
    private var api: Tapsilat!

    override func setUp() {
        super.setUp()
        StubURLProtocol.reset()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        api = Tapsilat(endpoint: "https://panel.example/api/v1", token: "token_123", session: URLSession(configuration: config))
    }

    private func reply(_ body: String, status: Int = 200) -> StubURLProtocol.Reply {
        StubURLProtocol.Reply(status: status, body: body)
    }

    func testCreatePaySession() async throws {
        StubURLProtocol.on("POST", "/api/v1/elements/sessions", reply("""
        {
            "id": "es_test_8Kq2nV0rX4",
            "purpose": "pay",
            "status": "requires_payment_method",
            "order_reference_id": "order-ref-1",
            "attempts": 0,
            "max_attempts": 3,
            "created_at": "2026-10-22T09:00:00Z",
            "expires_at": "2026-10-22T09:30:00Z",
            "client_secret": "es_test_8Kq2nV0rX4_secret_q8Zr0bM1",
            "elements_base_url": "https://checkout.tapsilat.dev"
        }
        """))

        let session = try await api.createElementsSession(ElementsSessionCreateRequest(
            purpose: ElementsSession.purposePay,
            orderReferenceId: "order-ref-1",
            saveCard: true
        ))

        let request = try XCTUnwrap(StubURLProtocol.last("POST", "/api/v1/elements/sessions"))
        XCTAssertEqual(request.headers["Authorization"], "Bearer token_123")
        XCTAssertEqual(request.headers["Content-Type"], "application/json")
        let body = try XCTUnwrap(request.json)
        XCTAssertEqual(body as NSDictionary, ["purpose": "pay", "order_reference_id": "order-ref-1", "save_card": true] as NSDictionary)

        XCTAssertEqual(session.id, "es_test_8Kq2nV0rX4")
        XCTAssertEqual(session.purpose, ElementsSession.purposePay)
        XCTAssertEqual(session.status, ElementsSession.statusRequiresPaymentMethod)
        XCTAssertEqual(session.orderReferenceId, "order-ref-1")
        XCTAssertEqual(session.attempts, 0)
        XCTAssertEqual(session.maxAttempts, 3)
        XCTAssertEqual(session.createdAt, "2026-10-22T09:00:00Z")
        XCTAssertEqual(session.expiresAt, "2026-10-22T09:30:00Z")
        XCTAssertNil(session.completedAt)
        XCTAssertNil(session.card)
        XCTAssertNil(session.lastError)
        XCTAssertEqual(session.clientSecret, "es_test_8Kq2nV0rX4_secret_q8Zr0bM1")
        XCTAssertEqual(session.elementsBaseUrl, "https://checkout.tapsilat.dev")
        XCTAssertEqual(session.session.id, "es_test_8Kq2nV0rX4")
    }

    func testCreateTokenizeSession() async throws {
        StubURLProtocol.on("POST", "/api/v1/elements/sessions", reply(
            #"{"id":"es_test_1","purpose":"tokenize","status":"requires_payment_method","user_id":"user_123","client_secret":"es_test_1_secret_x"}"#
        ))

        let session = try await api.elements.createElementsSession(ElementsSessionCreateRequest(
            purpose: ElementsSession.purposeTokenize,
            userId: "user_123",
            userEmail: "john@doe.com",
            mode: ElementsSessionCreateRequest.modeNonSecure
        ))

        let body = try XCTUnwrap(StubURLProtocol.last("POST", "/api/v1/elements/sessions")?.json)
        XCTAssertEqual(body as NSDictionary, ["purpose": "tokenize", "user_id": "user_123", "user_email": "john@doe.com", "mode": 3] as NSDictionary)
        XCTAssertEqual(session.purpose, ElementsSession.purposeTokenize)
        XCTAssertEqual(session.userId, "user_123")
        XCTAssertEqual(session.clientSecret, "es_test_1_secret_x")
        XCTAssertNil(session.elementsBaseUrl)
    }

    func testGetSessionDecodesCardAndLastError() async throws {
        StubURLProtocol.on("GET", "/api/v1/elements/sessions/es_test_8Kq2nV0rX4", reply("""
        {
            "id": "es_test_8Kq2nV0rX4",
            "purpose": "pay",
            "status": "failed",
            "order_reference_id": "order-ref-1",
            "attempts": 3,
            "max_attempts": 3,
            "completed_at": "2026-10-22T09:12:00Z",
            "card": {"id": "card-1", "brand": "visa", "last4": "4242", "exp_month": 12, "exp_year": 2030},
            "last_error": {"code": "card_declined", "message": "The card was declined.", "retryable": false}
        }
        """))

        let session = try await api.getElementsSession(id: "es_test_8Kq2nV0rX4")

        let request = try XCTUnwrap(StubURLProtocol.last("GET", "/api/v1/elements/sessions/es_test_8Kq2nV0rX4"))
        XCTAssertEqual(request.headers["Authorization"], "Bearer token_123")
        XCTAssertTrue(request.body?.isEmpty ?? true)

        XCTAssertEqual(session.status, ElementsSession.statusFailed)
        XCTAssertEqual(session.attempts, 3)
        XCTAssertEqual(session.completedAt, "2026-10-22T09:12:00Z")
        XCTAssertEqual(session.card, ElementsCardSummary(id: "card-1", brand: ElementsCardSummary.brandVisa, last4: "4242", expMonth: 12, expYear: 2030))
        XCTAssertEqual(session.lastError, ElementsError(code: "card_declined", message: "The card was declined.", retryable: false))
    }

    func testGetSessionReadsNullCardAndLastError() async throws {
        StubURLProtocol.on("GET", "/api/v1/elements/sessions/es_mock_1", reply(
            #"{"id":"es_mock_1","purpose":"pay","status":"requires_payment_method","card":null,"last_error":null}"#
        ))

        let session = try await api.getElementsSession(id: "es_mock_1")

        XCTAssertEqual(session.id, "es_mock_1")
        XCTAssertNil(session.card)
        XCTAssertNil(session.lastError)
    }

    func testGetSessionKeepsUnknownValues() async throws {
        StubURLProtocol.on("GET", "/api/v1/elements/sessions/es_live_1", reply(
            #"{"id":"es_live_1","purpose":"subscribe","status":"on_hold","card":{"brand":"elo","last4":"0001"},"next_action":{"type":"x"}}"#
        ))

        let session = try await api.getElementsSession(id: "es_live_1")

        XCTAssertEqual(session.purpose, "subscribe")
        XCTAssertEqual(session.status, "on_hold")
        XCTAssertEqual(session.card?.brand, "elo")
        XCTAssertNil(session.card?.expMonth)
    }

    func testCancelSessionPostsWithoutABody() async throws {
        StubURLProtocol.on("POST", "/api/v1/elements/sessions/es_test_8Kq2nV0rX4/cancel", reply(
            #"{"id":"es_test_8Kq2nV0rX4","purpose":"pay","status":"canceled","attempts":0,"max_attempts":3}"#
        ))

        let session = try await api.cancelElementsSession(id: "es_test_8Kq2nV0rX4")

        let request = try XCTUnwrap(StubURLProtocol.last("POST", "/api/v1/elements/sessions/es_test_8Kq2nV0rX4/cancel"))
        XCTAssertEqual(request.headers["Authorization"], "Bearer token_123")
        XCTAssertTrue(request.body?.isEmpty ?? true)
        XCTAssertNil(request.headers["Content-Type"])
        XCTAssertEqual(session.status, ElementsSession.statusCanceled)
        XCTAssertEqual(session.maxAttempts, 3)
    }

    func testSessionIDIsPathEscaped() async throws {
        StubURLProtocol.on("GET", "/api/v1/elements/sessions/es_test_1%2F..%2Fx", reply(#"{"id":"es_test_1"}"#))
        StubURLProtocol.on("POST", "/api/v1/elements/sessions/es_test_1%3Fa%3D1/cancel", reply(#"{"id":"es_test_1"}"#))

        _ = try await api.getElementsSession(id: "es_test_1/../x")
        _ = try await api.cancelElementsSession(id: "es_test_1?a=1")

        XCTAssertNotNil(StubURLProtocol.last("GET", "/api/v1/elements/sessions/es_test_1%2F..%2Fx"))
        let cancel = try XCTUnwrap(StubURLProtocol.last("POST", "/api/v1/elements/sessions/es_test_1%3Fa%3D1/cancel"))
        XCTAssertNil(cancel.query)
    }

    func testNestedErrorsExposeCodeMessageAndRetryable() async throws {
        struct Case {
            let status: Int
            let body: String
            let code: String
            let message: String
            let retryable: Bool
            let call: (Tapsilat) async throws -> Void
        }
        let cases = [
            Case(
                status: 403,
                body: #"{"error":{"code":"elements_not_enabled","message":"Elements is not enabled for this organization"}}"#,
                code: "elements_not_enabled",
                message: "Elements is not enabled for this organization",
                retryable: false,
                call: { _ = try await $0.createElementsSession(ElementsSessionCreateRequest(purpose: ElementsSession.purposePay)) }
            ),
            Case(
                status: 404,
                body: #"{"error":{"code":"session_not_found","message":"session not found","retryable":false}}"#,
                code: "session_not_found",
                message: "session not found",
                retryable: false,
                call: { _ = try await $0.getElementsSession(id: "es_test_missing") }
            ),
            Case(
                status: 503,
                body: #"{"error":{"code":"unavailable","message":"try again","retryable":true}}"#,
                code: "unavailable",
                message: "try again",
                retryable: true,
                call: { _ = try await $0.cancelElementsSession(id: "es_test_1") }
            ),
        ]

        for item in cases {
            StubURLProtocol.reset()
            StubURLProtocol.on("POST", "/api/v1/elements/sessions", reply(item.body, status: item.status))
            StubURLProtocol.on("GET", "/api/v1/elements/sessions/es_test_missing", reply(item.body, status: item.status))
            StubURLProtocol.on("POST", "/api/v1/elements/sessions/es_test_1/cancel", reply(item.body, status: item.status))

            do {
                try await item.call(api)
                XCTFail("expected an error for \(item.code)")
            } catch let error as APIError {
                XCTAssertEqual(error.statusCode, item.status)
                XCTAssertEqual(error.code, item.code)
                XCTAssertEqual(error.messageText, item.message)
                XCTAssertEqual(error.retryable, item.retryable, item.code)
                XCTAssertEqual(error.rawBody, item.body)
                XCTAssertTrue(error.errorDescription?.contains("[\(item.code)] \(item.message)") == true, error.errorDescription ?? "")
            }
        }
    }

    func testFlatErrorsAreNotRetryable() {
        let error = APIError(statusCode: 424, body: Data(#"{"error":"payout is not eligible","code":9}"#.utf8))

        XCTAssertEqual(error.code, "9")
        XCTAssertEqual(error.messageText, "payout is not eligible")
        XCTAssertFalse(error.retryable)
    }

    func testSessionWithSecretRedactsTheSecretWhenPrinted() throws {
        let secret = "es_test_1_secret_x"
        let session = ElementsSessionWithSecret(
            session: ElementsSession(id: "es_test_1", status: ElementsSession.statusRequiresPaymentMethod),
            clientSecret: secret,
            elementsBaseUrl: "https://checkout.tapsilat.dev"
        )

        var dumped = ""
        dump(session, to: &dumped)
        var printed = ""
        print(session, to: &printed)
        var debugPrinted = ""
        debugPrint(session, to: &debugPrinted)
        let mirrored = Mirror(reflecting: session).children.map { "\($0.label ?? ""): \($0.value)" }.joined(separator: ", ")

        let forms = [
            "description": session.description,
            "debugDescription": session.debugDescription,
            "describing": String(describing: session),
            "reflecting": String(reflecting: session),
            "interpolation": "\(session)",
            "print": printed,
            "debugPrint": debugPrinted,
            "dump": dumped,
            "mirror": mirrored,
            "optional": String(describing: Optional(session)),
            "array": String(describing: [session]),
        ]
        for (name, text) in forms {
            XCTAssertFalse(text.contains(secret), "\(name): \(text)")
            XCTAssertTrue(text.contains("[redacted]"), "\(name): \(text)")
            XCTAssertTrue(text.contains("es_test_1"), "\(name): \(text)")
        }
    }

    func testSessionWithSecretEncodesTheSecret() throws {
        let session = ElementsSessionWithSecret(
            session: ElementsSession(id: "es_test_1", status: ElementsSession.statusRequiresPaymentMethod),
            clientSecret: "es_test_1_secret_x",
            elementsBaseUrl: "https://checkout.tapsilat.dev"
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(session)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object as NSDictionary, [
            "id": "es_test_1",
            "status": "requires_payment_method",
            "client_secret": "es_test_1_secret_x",
            "elements_base_url": "https://checkout.tapsilat.dev",
        ] as NSDictionary)

        let plain = try XCTUnwrap(String(data: JSONEncoder().encode(session), encoding: .utf8))
        XCTAssertTrue(plain.contains(#""clientSecret":"es_test_1_secret_x""#), plain)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        XCTAssertEqual(try decoder.decode(ElementsSessionWithSecret.self, from: data), session)
    }
}
