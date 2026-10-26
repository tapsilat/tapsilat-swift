import CryptoKit
import XCTest
@testable import Tapsilat

final class WebhookTests: XCTestCase {
    // An order_lite callback and a known-good Tapsilat-Signature for this body and secret; the expected
    // signature was computed with openssl, independently of the SDK.
    private let payload = #"{"data":{"id":"5f0c6f1e-1111-4a5b-9c1d-2e3f4a5b6c7d","orderReferenceId":"0b6a4f9e-2222-4c3d-8e9f-a1b2c3d4e5f6","conversationId":"wc-1001","status":"3"},"type":"order_lite","token":"9d8c7b6a-3333-4e5f-a6b7-c8d9e0f1a2b3"}"#
    private let secret = "whsec_test"
    private let timestamp: TimeInterval = 1_726_480_000
    private let signature = "3e003945e8122172a03ae1aa56fd099b56e6ac11a8472c03e33809c7c480aeb6"

    private func header(_ signature: String? = nil, timestamp: String? = nil) -> String {
        "t=\(timestamp ?? String(Int(self.timestamp))),v1=\(signature ?? self.signature)"
    }

    private func at(_ offset: TimeInterval) -> Date {
        Date(timeIntervalSince1970: timestamp + offset)
    }

    func testVerifiesTheTapsilatSignatureHeader() {
        XCTAssertEqual(TapsilatWebhook.signatureHeader, "Tapsilat-Signature")
        XCTAssertTrue(TapsilatWebhook.verify(payload: payload, signature: header(), secret: secret, now: at(10)))
        XCTAssertTrue(TapsilatWebhook.verify(payload: Data(payload.utf8), signature: header(), secret: secret, now: at(10)))
        XCTAssertTrue(TapsilatWebhook.verify(
            payload: payload,
            signature: " t=\(Int(timestamp)), v1=\(signature.uppercased()) ",
            secret: secret,
            now: at(0)
        ))
    }

    func testRejectsATamperedBodyOrTheWrongSecret() {
        let tampered = payload.replacingOccurrences(of: #""status":"3""#, with: #""status":"13""#)

        XCTAssertFalse(TapsilatWebhook.verify(payload: tampered, signature: header(), secret: secret, now: at(0)))
        XCTAssertFalse(TapsilatWebhook.verify(payload: payload, signature: header(), secret: "other", now: at(0)))
        XCTAssertFalse(TapsilatWebhook.verify(payload: payload, signature: header(), secret: "", now: at(0)))
        XCTAssertFalse(TapsilatWebhook.verify(payload: payload, signature: header(), secret: nil, now: at(0)))
        XCTAssertFalse(TapsilatWebhook.verify(payload: payload, signature: "", secret: secret, now: at(0)))
        XCTAssertFalse(TapsilatWebhook.verify(payload: payload, signature: nil, secret: secret, now: at(0)))
    }

    func testRejectsAReplayedOrMalformedHeader() {
        XCTAssertFalse(TapsilatWebhook.verify(payload: payload, signature: header(), secret: secret, now: at(301)))
        XCTAssertFalse(TapsilatWebhook.verify(payload: payload, signature: header(), secret: secret, now: at(-301)))
        XCTAssertTrue(TapsilatWebhook.verify(payload: payload, signature: header(), secret: secret, tolerance: 0, now: at(86_400)))
        XCTAssertFalse(TapsilatWebhook.verify(payload: payload, signature: "v1=\(signature)", secret: secret, tolerance: 0, now: at(0)))
        XCTAssertFalse(TapsilatWebhook.verify(payload: payload, signature: "t=\(Int(timestamp))", secret: secret, tolerance: 0, now: at(0)))
        XCTAssertFalse(TapsilatWebhook.verify(
            payload: payload,
            signature: header(timestamp: "1726480000.5"),
            secret: secret,
            tolerance: 0,
            now: at(0)
        ))
        XCTAssertFalse(TapsilatWebhook.verify(
            payload: payload,
            signature: header(timestamp: String(repeating: "9", count: 40)),
            secret: secret,
            tolerance: 0,
            now: at(0)
        ))
    }

    func testAcceptsAnyOfSeveralV1Signatures() {
        let header = "t=\(Int(timestamp)),v1=\(String(repeating: "0", count: 64)),v1=\(signature)"

        XCTAssertTrue(TapsilatWebhook.verify(payload: payload, signature: header, secret: secret, now: at(0)))
    }

    func testUsesTheCurrentTimeByDefault() {
        let now = String(Int(Date().timeIntervalSince1970))
        let mac = HMAC<SHA256>.authenticationCode(for: Data("\(now).\(payload)".utf8), using: SymmetricKey(data: Data(secret.utf8)))
        let current = mac.map { String(format: "%02x", $0) }.joined()

        XCTAssertTrue(TapsilatWebhook.verify(payload: payload, signature: header(current, timestamp: now), secret: secret))
        XCTAssertFalse(TapsilatWebhook.verify(payload: payload, signature: header(), secret: secret))
    }

    func testStillAcceptsABareHMACOfThePayload() {
        let legacy = "402b9d6616b32be533a4fc0300e8db19c304a56137d3fb274c614f30f9be6fbb"

        XCTAssertTrue(TapsilatWebhook.verify(payload: payload, signature: legacy, secret: secret))
        XCTAssertTrue(TapsilatWebhook.verify(payload: payload, signature: "sha256=\(legacy.uppercased())", secret: secret))
        XCTAssertFalse(TapsilatWebhook.verify(payload: payload, signature: legacy, secret: "other"))
    }

    func testParsesAnOrderLiteCallback() throws {
        let event = try WebhookEvent(payload: payload)

        XCTAssertEqual(event.type, WebhookEvent.typeOrderLite)
        XCTAssertEqual(event.token, "9d8c7b6a-3333-4e5f-a6b7-c8d9e0f1a2b3")
        XCTAssertEqual(event.referenceId, "0b6a4f9e-2222-4c3d-8e9f-a1b2c3d4e5f6")
        XCTAssertEqual(event.conversationId, "wc-1001")
        XCTAssertEqual(event.statusCode, .paid)
        XCTAssertEqual(event.status, "Paid")
        XCTAssertTrue(event.isPaid)
        XCTAssertFalse(event.isFailed)
    }

    func testParsesAnOrderCallback() throws {
        let event = try WebhookEvent(payload: #"""
        {"type": "order", "token": "t-1",
         "data": {"id": "o-1", "reference_id": "ref-1", "conversation_id": "c-1", "status": 13}}
        """#)

        XCTAssertEqual(event.type, WebhookEvent.typeOrder)
        XCTAssertEqual(event.referenceId, "ref-1")
        XCTAssertEqual(event.conversationId, "c-1")
        XCTAssertEqual(event.status, "Failure")
        XCTAssertTrue(event.isFailed)
    }

    func testParsesAnOrderPaymentDetailCallback() throws {
        let event = try WebhookEvent(payload: #"""
        {"type": "order_payment_detail", "token": "t-2",
         "data": {"id": "d-1", "order_reference_id": "ref-2", "conversation_id": "c-2",
                  "order": {"reference_id": "ref-2", "id": "o-2", "status": "Paid"},
                  "order_payment_status": {"code": 0}}}
        """#)

        XCTAssertEqual(event.referenceId, "ref-2")
        XCTAssertEqual(event.conversationId, "c-2")
        XCTAssertEqual(event.statusCode, .paid)
    }

    func testParsesCallbacksWithoutAStatus() throws {
        let extended = try WebhookEvent(payload: #"""
        {"type": "extended_order",
         "data": {"id": "o-3", "reference_id": "ref-3", "terms": [{"reference_id": "term-1", "status": 2}]}}
        """#)
        XCTAssertEqual(extended.referenceId, "ref-3")
        XCTAssertNil(extended.conversationId)
        XCTAssertNil(extended.statusCode)
        XCTAssertFalse(extended.isPaid)

        let facilitator = WebhookEvent(payload: [
            "type": .string(WebhookEvent.typePaymentFacilitator),
            "data": .object(["id": .string("p-1"), "payment_id": .string("pay-1"), "reference_id": .string("ref-4")]),
        ])
        XCTAssertEqual(facilitator.referenceId, "ref-4")
    }

    func testIgnoresAZeroUUID() {
        let event = WebhookEvent(payload: [
            "type": .string(WebhookEvent.typeOrderPaymentDetail),
            "data": .object([
                "order_reference_id": .string("00000000-0000-0000-0000-000000000000"),
                "order": .object(["reference_id": .string("ref-5")]),
            ]),
        ])

        XCTAssertEqual(event.referenceId, "ref-5")
    }

    func testRejectsAPayloadThatIsNotAJSONObject() {
        XCTAssertThrowsError(try WebhookEvent(payload: #""order""#)) { error in
            XCTAssertTrue(error is ValidationError)
        }
        XCTAssertThrowsError(try WebhookEvent(payload: "not json"))
    }

    func testOrderStatusNamesAndGroups() {
        let missing: String? = nil

        XCTAssertEqual(OrderStatus.code("waiting for payment"), .waitingForPayment)
        XCTAssertEqual(OrderStatus.code("21"), .expired)
        XCTAssertEqual(OrderStatus.code(13.0), .failure)
        XCTAssertEqual(OrderStatus.code(JSONValue.number(13)), .failure)
        XCTAssertEqual(OrderStatus.name(15), "Partially refunded")
        XCTAssertNil(OrderStatus.code("SUCCESS"))
        XCTAssertNil(OrderStatus.code(99))
        XCTAssertNil(OrderStatus.name(missing))
        XCTAssertNil(OrderStatus.name(nil))

        XCTAssertTrue(OrderStatus.isPaid("Sub merchant payment approved"))
        XCTAssertTrue(OrderStatus.isPaid(OrderStatus.Code.completed))
        XCTAssertTrue(OrderStatus.isPaid(9))
        XCTAssertFalse(OrderStatus.isPaid("Waiting for payment"))
        XCTAssertTrue(OrderStatus.isFailed("Expired"))
        XCTAssertFalse(OrderStatus.isFailed("Paid"))
        XCTAssertTrue(OrderStatus.isRefunded("10"))

        let response = OrderStatus(status: "Waiting for payment")
        XCTAssertEqual(response.code, .waitingForPayment)
        XCTAssertFalse(response.isPaid)
        XCTAssertEqual(OrderStatus.code(response), .waitingForPayment)
        XCTAssertEqual(OrderStatus.Code.allCases.count, 29)
    }

    func testOrderStatusReadsEveryRuntimeType() throws {
        XCTAssertEqual(OrderStatus.code(Int8(3)), .paid)
        XCTAssertEqual(OrderStatus.code(UInt(9)), .completed)
        XCTAssertEqual(OrderStatus.code(Int64(21)), .expired)
        XCTAssertEqual(OrderStatus.code(Float(13)), .failure)
        XCTAssertEqual(OrderStatus.code(" paid "[...]), .paid)
        XCTAssertEqual(OrderStatus.code(JSONValue.string("Refunded")), .refunded)
        XCTAssertEqual(OrderStatus.code(NSNumber(value: 1)), .received)
        XCTAssertNil(OrderStatus.code(13.5))
        XCTAssertNil(OrderStatus.code(NSNumber(value: 3.5)))
        XCTAssertNil(OrderStatus.code(true))
        XCTAssertNil(OrderStatus.code(JSONValue.bool(true)))
        XCTAssertNil(OrderStatus.code(JSONValue.null))
        XCTAssertNil(OrderStatus.code(NSNull()))
        XCTAssertNil(OrderStatus.code(String(repeating: "9", count: 40)))

        let decoded = try XCTUnwrap(JSONSerialization.jsonObject(
            with: Data(#"{"one": 1, "yes": true, "no": false, "failure": 13.0, "paid": "3"}"#.utf8)
        ) as? [String: Any])
        XCTAssertEqual(OrderStatus.code(decoded["one"]), .received)
        XCTAssertNil(OrderStatus.code(decoded["yes"]))
        XCTAssertNil(OrderStatus.code(decoded["no"]))
        XCTAssertEqual(OrderStatus.code(decoded["failure"]), .failure)
        XCTAssertTrue(OrderStatus.isPaid(decoded["paid"]))
        XCTAssertNil(OrderStatus.code(decoded["missing"]))
    }
}
