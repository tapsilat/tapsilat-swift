import Foundation

// Tapsilat Elements session models. Status, purpose and brand are kept as strings so that values
// added later still decode; compare them with the constants below. Timestamps are RFC 3339 strings.

/// Opens an Elements session with `POST /elements/sessions`.
public struct ElementsSessionCreateRequest: Codable, Equatable, Sendable {
    /// Tokenize mode 1: 3D Secure.
    public static let modeSecure = 1
    /// Tokenize mode 2: half secure.
    public static let modeHalfSecure = 2
    /// Tokenize mode 3: non-secure.
    public static let modeNonSecure = 3

    /// `ElementsSession.purposePay` or `ElementsSession.purposeTokenize`.
    public var purpose: String
    /// Required for `ElementsSession.purposePay`.
    public var orderReferenceId: String?
    /// The card owner of a tokenize session, scoped to the caller's organization.
    public var userId: String?
    public var userEmail: String?
    /// The tokenize mode: `modeSecure`, `modeHalfSecure` or `modeNonSecure`.
    public var mode: Int?
    /// Lets the buyer save the card on a pay session.
    public var saveCard: Bool?

    public init(
        purpose: String,
        orderReferenceId: String? = nil,
        userId: String? = nil,
        userEmail: String? = nil,
        mode: Int? = nil,
        saveCard: Bool? = nil
    ) {
        self.purpose = purpose
        self.orderReferenceId = orderReferenceId
        self.userId = userId
        self.userEmail = userEmail
        self.mode = mode
        self.saveCard = saveCard
    }
}

/// The card a session collected: brand, last four digits and expiry.
public struct ElementsCardSummary: Codable, Equatable, Sendable {
    public static let brandVisa = "visa"
    public static let brandMastercard = "mastercard"
    public static let brandAmex = "amex"
    public static let brandTroy = "troy"
    public static let brandDiscover = "discover"
    public static let brandUnionpay = "unionpay"
    public static let brandUnknown = "unknown"

    public var id: String?
    public var brand: String?
    public var last4: String?
    public var expMonth: Int?
    public var expYear: Int?

    public init(id: String? = nil, brand: String? = nil, last4: String? = nil, expMonth: Int? = nil, expYear: Int? = nil) {
        self.id = id
        self.brand = brand
        self.last4 = last4
        self.expMonth = expMonth
        self.expYear = expYear
    }
}

/// Why a session's last attempt failed, as its `last_error` carries it, such as `card_declined`.
/// This is session data; failed requests throw `APIError`.
public struct ElementsError: Codable, Equatable, Sendable {
    public var code: String?
    public var message: String?
    public var retryable: Bool?

    public init(code: String? = nil, message: String? = nil, retryable: Bool? = nil) {
        self.code = code
        self.message = message
        self.retryable = retryable
    }
}

/// The authoritative state and outcome of an Elements session.
public struct ElementsSession: Codable, Equatable, Sendable {
    public static let purposeTokenize = "tokenize"
    public static let purposePay = "pay"

    public static let statusRequiresPaymentMethod = "requires_payment_method"
    public static let statusProcessing = "processing"
    public static let statusRequiresAction = "requires_action"
    public static let statusSucceeded = "succeeded"
    public static let statusFailed = "failed"
    public static let statusExpired = "expired"
    public static let statusCanceled = "canceled"

    /// The session ID, such as "es_test_8Kq2nV0rX4".
    public var id: String?
    public var purpose: String?
    public var status: String?
    public var orderReferenceId: String?
    public var userId: String?
    public var attempts: Int?
    public var maxAttempts: Int?
    public var createdAt: String?
    public var expiresAt: String?
    public var completedAt: String?
    /// Absent until a card was collected.
    public var card: ElementsCardSummary?
    /// Absent unless an attempt failed.
    public var lastError: ElementsError?

    public init(
        id: String? = nil,
        purpose: String? = nil,
        status: String? = nil,
        orderReferenceId: String? = nil,
        userId: String? = nil,
        attempts: Int? = nil,
        maxAttempts: Int? = nil,
        createdAt: String? = nil,
        expiresAt: String? = nil,
        completedAt: String? = nil,
        card: ElementsCardSummary? = nil,
        lastError: ElementsError? = nil
    ) {
        self.id = id
        self.purpose = purpose
        self.status = status
        self.orderReferenceId = orderReferenceId
        self.userId = userId
        self.attempts = attempts
        self.maxAttempts = maxAttempts
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.completedAt = completedAt
        self.card = card
        self.lastError = lastError
    }
}

/// A newly created Elements session and its client secret. The session's properties can be read
/// directly, as in `created.id` and `created.status`.
///
/// `clientSecret` is meant for your app, which opens the card sheet with it; the app is the only
/// thing that should receive it. It is returned only once. Do not log or store it. `print`,
/// `debugPrint`, `dump` and string interpolation show it as `[redacted]`; encoding keeps it, so
/// the session can be sent to the app as JSON.
@dynamicMemberLookup
public struct ElementsSessionWithSecret: Codable, Equatable, Sendable {
    public var session: ElementsSession
    public var clientSecret: String
    /// The Elements host the app's card sheet talks to, when the response names one.
    public var elementsBaseUrl: String?

    public init(session: ElementsSession, clientSecret: String, elementsBaseUrl: String? = nil) {
        self.session = session
        self.clientSecret = clientSecret
        self.elementsBaseUrl = elementsBaseUrl
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<ElementsSession, Value>) -> Value {
        session[keyPath: keyPath]
    }

    private enum CodingKeys: String, CodingKey {
        case clientSecret
        case elementsBaseUrl
    }

    /// Decodes the flat response: the session's fields next to `client_secret` and `elements_base_url`.
    public init(from decoder: Decoder) throws {
        session = try ElementsSession(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        clientSecret = try container.decode(String.self, forKey: .clientSecret)
        elementsBaseUrl = try container.decodeIfPresent(String.self, forKey: .elementsBaseUrl)
    }

    public func encode(to encoder: Encoder) throws {
        try session.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(clientSecret, forKey: .clientSecret)
        try container.encodeIfPresent(elementsBaseUrl, forKey: .elementsBaseUrl)
    }
}

extension ElementsSessionWithSecret: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    private static let redacted = "[redacted]"

    public var description: String {
        "ElementsSessionWithSecret(session: \(session), clientSecret: \(Self.redacted), elementsBaseUrl: \(elementsBaseUrl ?? "nil"))"
    }

    public var debugDescription: String {
        "ElementsSessionWithSecret(session: \(String(reflecting: session)), clientSecret: \"\(Self.redacted)\", elementsBaseUrl: \(String(reflecting: elementsBaseUrl)))"
    }

    public var customMirror: Mirror {
        Mirror(
            self,
            children: ["session": session, "clientSecret": Self.redacted, "elementsBaseUrl": elementsBaseUrl as Any],
            displayStyle: .struct
        )
    }
}
