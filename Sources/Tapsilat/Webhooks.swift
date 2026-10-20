import CryptoKit
import Foundation

/// Verifies the signature Tapsilat puts on every callback it sends.
///
/// Tapsilat signs callbacks to an organization's callback URLs, and to an order's
/// `payment_success_url` and `payment_failure_url`, with the webhook secret from the panel's
/// callback settings. The `Tapsilat-Signature` header reads `t=<unix time>,v1=<signature>`, where
/// the signature is the hex HMAC-SHA256 of the timestamp, a dot and the raw body.
public enum TapsilatWebhook {
    /// The header that carries the signature of every callback Tapsilat sends.
    public static let signatureHeader = "Tapsilat-Signature"

    /// How many seconds a callback's signature timestamp may differ from the current time.
    public static let defaultTolerance: TimeInterval = 300

    private static let legacyPrefix = "sha256="

    /// Returns whether `signature`, the `Tapsilat-Signature` header, signs `payload` with `secret`,
    /// the webhook secret from the panel's callback settings.
    ///
    /// `payload` must be the raw request body, before any JSON decoding. The timestamp must be
    /// within `tolerance` seconds of `now` (0 disables the check) so that a captured callback
    /// cannot be replayed. Signatures are compared in constant time.
    ///
    /// A bare hex HMAC-SHA256 of the payload, with or without a `sha256=` prefix, is also accepted
    /// for signatures made that way.
    public static func verify(
        payload: Data,
        signature: String?,
        secret: String?,
        tolerance: TimeInterval = defaultTolerance,
        now: Date = Date()
    ) -> Bool {
        guard let signature = signature?.trimmingCharacters(in: .whitespacesAndNewlines),
              !signature.isEmpty,
              let secret,
              !secret.isEmpty
        else {
            return false
        }
        let key = SymmetricKey(data: Data(secret.utf8))

        if signature.hasPrefix(legacyPrefix) || !signature.contains("=") {
            let candidate = signature.hasPrefix(legacyPrefix) ? String(signature.dropFirst(legacyPrefix.count)) : signature
            return constantTimeEquals(hex(HMAC<SHA256>.authenticationCode(for: payload, using: key)), candidate)
        }

        var timestamp: String?
        var candidates: [String] = []
        for part in signature.split(separator: ",", omittingEmptySubsequences: false) {
            let part = part.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let separator = part.firstIndex(of: "=") else {
                continue
            }
            let value = String(part[part.index(after: separator)...])
            switch part[..<separator] {
            case "t":
                timestamp = value
            case "v1":
                candidates.append(value)
            default:
                continue
            }
        }
        guard let timestamp,
              !timestamp.isEmpty,
              timestamp.utf8.allSatisfy({ (0x30...0x39).contains($0) }),
              let seconds = Int64(timestamp),
              !candidates.isEmpty
        else {
            return false
        }
        if tolerance > 0 {
            let age = (now.timeIntervalSince1970.rounded(.down) - Double(seconds)).magnitude
            guard age <= tolerance else {
                return false
            }
        }

        var hmac = HMAC<SHA256>(key: key)
        hmac.update(data: Data("\(timestamp).".utf8))
        hmac.update(data: payload)
        let expected = hex(hmac.finalize())
        return candidates.contains { constantTimeEquals(expected, $0) }
    }

    /// Verifies a payload given as text; see `verify(payload:signature:secret:tolerance:now:)`.
    public static func verify(
        payload: String,
        signature: String?,
        secret: String?,
        tolerance: TimeInterval = defaultTolerance,
        now: Date = Date()
    ) -> Bool {
        verify(payload: Data(payload.utf8), signature: signature, secret: secret, tolerance: tolerance, now: now)
    }

    private static func hex<Bytes: Sequence>(_ bytes: Bytes) -> String where Bytes.Element == UInt8 {
        let digits = Array("0123456789abcdef".utf8)
        var text: [UInt8] = []
        for byte in bytes {
            text.append(digits[Int(byte >> 4)])
            text.append(digits[Int(byte & 0x0F)])
        }
        return String(decoding: text, as: UTF8.self)
    }

    /// Compares lowercase hex `expected` with `candidate`, ignoring the case of its ASCII letters,
    /// in time that depends only on their lengths.
    private static func constantTimeEquals(_ expected: String, _ candidate: String) -> Bool {
        let lhs = Array(expected.utf8)
        let rhs = Array(candidate.utf8)
        guard lhs.count == rhs.count else {
            return false
        }
        var difference: UInt8 = 0
        for (left, right) in zip(lhs, rhs) {
            let lowered = (0x41...0x5A).contains(right) ? right | 0x20 : right
            difference |= left ^ lowered
        }
        return difference == 0
    }
}

/// A callback Tapsilat posts to an organization's callback URLs or to an order's
/// `payment_success_url` and `payment_failure_url`: `{"type": "...", "data": {...}, "token": "..."}`.
///
/// The shape of `data` depends on the type, which each organization chooses in the panel:
/// "order_lite" (the default), "order", "order_payment_detail", "extended_order" or
/// "payment_facilitator". The properties read the order's reference ID, conversation ID and status
/// from whichever shape arrived.
///
/// Verify the `Tapsilat-Signature` header with `TapsilatWebhook.verify` before trusting a callback.
public struct WebhookEvent: Equatable, Sendable {
    public static let typeOrder = "order"
    public static let typeOrderLite = "order_lite"
    public static let typeOrderPaymentDetail = "order_payment_detail"
    public static let typeExtendedOrder = "extended_order"
    public static let typePaymentFacilitator = "payment_facilitator"

    private static let zeroUUID = "00000000-0000-0000-0000-000000000000"

    public let type: String?
    /// Unique per delivery.
    public let token: String?
    /// The callback's `data` object, or the whole payload when it has none.
    public let data: [String: JSONValue]
    /// The decoded payload.
    public let payload: [String: JSONValue]

    public init(payload: [String: JSONValue]) {
        self.payload = payload
        if case .string(let type)? = payload["type"] {
            self.type = type
        } else {
            self.type = nil
        }
        if case .string(let token)? = payload["token"] {
            self.token = token
        } else {
            self.token = nil
        }
        if case .object(let data)? = payload["data"] {
            self.data = data
        } else {
            self.data = payload
        }
    }

    /// Decodes a raw callback body. Throws `ValidationError` when it is not a JSON object.
    public init(payload: Data) throws {
        guard case .object(let object)? = try? JSONDecoder().decode(JSONValue.self, from: payload) else {
            throw ValidationError("the webhook payload is not a JSON object")
        }
        self.init(payload: object)
    }

    /// Decodes a raw callback body given as text. Throws `ValidationError` when it is not a JSON object.
    public init(payload: String) throws {
        try self.init(payload: Data(payload.utf8))
    }

    /// The order's reference ID.
    public var referenceId: String? {
        Self.firstID([data["orderReferenceId"], data["order_reference_id"], data["reference_id"], order?["reference_id"]])
    }

    /// The conversation ID the order was created with.
    public var conversationId: String? {
        Self.firstID([data["conversationId"], data["conversation_id"]])
    }

    /// The order status, or nil when this callback type carries none.
    public var statusCode: OrderStatus.Code? {
        OrderStatus.code(data["status"]) ?? OrderStatus.code(order?["status"])
    }

    /// The order status name, such as "Paid".
    public var status: String? {
        statusCode?.name
    }

    public var isPaid: Bool {
        OrderStatus.isPaid(statusCode)
    }

    public var isFailed: Bool {
        OrderStatus.isFailed(statusCode)
    }

    public var isRefunded: Bool {
        OrderStatus.isRefunded(statusCode)
    }

    private var order: [String: JSONValue]? {
        if case .object(let order)? = data["order"] {
            return order
        }
        return nil
    }

    /// The first non-empty, non-zero string or whole number among `values`.
    private static func firstID(_ values: [JSONValue?]) -> String? {
        for value in values {
            switch value {
            case .string(let text)? where !text.isEmpty && text != zeroUUID:
                return text
            case .number(let number)?:
                if let whole = Int64(exactly: number) {
                    return String(whole)
                }
            default:
                continue
            }
        }
        return nil
    }
}
