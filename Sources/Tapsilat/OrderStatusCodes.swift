import Foundation

extension OrderStatus {
    /// An order status code, as callbacks and order details carry it.
    public enum Code: Int, CaseIterable, Sendable {
        case received = 1
        case unpaid = 2
        case paid = 3
        case processing = 4
        case shipped = 5
        case onHold = 6
        case waitingForPayment = 7
        case cancelled = 8
        case completed = 9
        case refunded = 10
        case fraud = 11
        case rejected = 12
        case failure = 13
        case retrying = 14
        case partiallyRefunded = 15
        case subMerchantPaymentApproved = 16
        case subMerchantPaymentDisapproved = 17
        case subMerchantPaymentErrored = 18
        case stillHasUnpaidInstallments = 19
        case stillHasUnpaidTerms = 20
        case expired = 21
        case stillHasUnpaidSubMerchantPayments = 22
        case partiallyPaid = 23
        case terminated = 24
        case cardTokenization = 25
        case preAuthorized = 26
        case disputed = 27
        case partiallyDisputed = 28
        case suspect = 29

        /// The name GET /order/{reference_id}/status returns for this status, such as "Paid".
        public var name: String {
            switch self {
            case .received: return "Received"
            case .unpaid: return "Unpaid"
            case .paid: return "Paid"
            case .processing: return "Processing"
            case .shipped: return "Shipped"
            case .onHold: return "On hold"
            case .waitingForPayment: return "Waiting for payment"
            case .cancelled: return "Cancelled"
            case .completed: return "Completed"
            case .refunded: return "Refunded"
            case .fraud: return "Fraud"
            case .rejected: return "Rejected"
            case .failure: return "Failure"
            case .retrying: return "Retrying"
            case .partiallyRefunded: return "Partially refunded"
            case .subMerchantPaymentApproved: return "Sub merchant payment approved"
            case .subMerchantPaymentDisapproved: return "Sub merchant payment disapproved"
            case .subMerchantPaymentErrored: return "Sub merchant payment errored"
            case .stillHasUnpaidInstallments: return "Still has unpaid installments"
            case .stillHasUnpaidTerms: return "Still has unpaid terms"
            case .expired: return "Expired"
            case .stillHasUnpaidSubMerchantPayments: return "Still has unpaid sub merchant payments"
            case .partiallyPaid: return "Partially Paid"
            case .terminated: return "Terminated"
            case .cardTokenization: return "Card Tokenization"
            case .preAuthorized: return "Pre Authorized"
            case .disputed: return "Disputed"
            case .partiallyDisputed: return "Partially disputed"
            case .suspect: return "Suspect"
            }
        }
    }

    /// Statuses of an order whose payment was captured.
    public static let paidCodes: Set<Code> = [.paid, .completed, .subMerchantPaymentApproved]

    /// Statuses of an order that will not be paid.
    public static let failedCodes: Set<Code> = [.cancelled, .fraud, .rejected, .failure, .expired, .terminated]

    /// Statuses of an order whose payment was refunded in full or in part.
    public static let refundedCodes: Set<Code> = [.refunded, .partiallyRefunded]

    /// Returns the status that `status` names: a `Code`, an `OrderStatus` response, a code such as 3
    /// (any integer type, a whole `Double` such as 13.0, or an `NSNumber` from `JSONSerialization`),
    /// a numeric string such as "3" (as order_lite callbacks send it), a status name such as "Paid"
    /// (case-insensitive), or a `JSONValue` holding a number or a string. Returns nil when it names
    /// no status.
    public static func code(_ status: Any?) -> Code? {
        guard let status else {
            return nil
        }
        // Bool, and true or false decoded by JSONSerialization, would otherwise read as 1 or 0
        if let number = status as? NSNumber, CFGetTypeID(number) == CFBooleanGetTypeID() {
            return nil
        }
        switch status {
        case let code as Code:
            return code
        case let response as OrderStatus:
            return code(response.status)
        case let value as JSONValue:
            switch value {
            case .number(let number):
                return code(number)
            case .string(let text):
                return code(text)
            case .bool, .object, .array, .null:
                return nil
            }
        case let text as String:
            return code(text: text)
        case let text as Substring:
            return code(text: String(text))
        case let number as any BinaryInteger:
            return Int(exactly: number).flatMap(Code.init(rawValue:))
        case let number as Double:
            return Int(exactly: number).flatMap(Code.init(rawValue:))
        case let number as Float:
            return Int(exactly: number).flatMap(Code.init(rawValue:))
        case let number as NSNumber:
            return Int(exactly: number.doubleValue).flatMap(Code.init(rawValue:))
        default:
            return nil
        }
    }

    /// Returns the status name, such as "Paid", or nil when `status` names no status.
    public static func name(_ status: Any?) -> String? {
        code(status)?.name
    }

    public static func isPaid(_ status: Any?) -> Bool {
        code(status).map(paidCodes.contains) ?? false
    }

    public static func isFailed(_ status: Any?) -> Bool {
        code(status).map(failedCodes.contains) ?? false
    }

    public static func isRefunded(_ status: Any?) -> Bool {
        code(status).map(refundedCodes.contains) ?? false
    }

    /// The code of `status`, such as `.waitingForPayment` for "Waiting for payment".
    public var code: Code? {
        Self.code(status)
    }

    public var isPaid: Bool {
        Self.isPaid(status)
    }

    public var isFailed: Bool {
        Self.isFailed(status)
    }

    public var isRefunded: Bool {
        Self.isRefunded(status)
    }

    /// A numeric string such as "3", or a status name such as "Paid" in any case.
    private static func code(text: String) -> Code? {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !value.isEmpty, value.utf8.allSatisfy({ (0x30...0x39).contains($0) }) {
            return Int(value).flatMap(Code.init(rawValue:))
        }
        return Code.allCases.first { $0.name.caseInsensitiveCompare(value) == .orderedSame }
    }
}
