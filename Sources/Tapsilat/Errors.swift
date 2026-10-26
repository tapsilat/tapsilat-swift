import Foundation

public struct ValidationError: Error, LocalizedError {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var errorDescription: String? {
        message
    }
}

/// An error response from the API, or a response that is not JSON.
public struct APIError: Error, LocalizedError {
    public let statusCode: Int
    /// The body's `status` field, else the HTTP status text.
    public let status: String
    /// The body's `code` field as text, such as "400000", else the `code` of its `error` object,
    /// such as "session_not_found".
    public let code: String?
    /// The body's `message` field, else its `error` field, or that object's `message`.
    public let messageText: String?
    public let rawBody: String
    /// Per-field validation messages, when the API returns them.
    public let errors: [String: JSONValue]?
    /// Whether the request can be retried, when the error object says so, as Elements errors do.
    public let retryable: Bool

    public init(
        statusCode: Int,
        status: String,
        code: String?,
        messageText: String?,
        rawBody: String,
        errors: [String: JSONValue]? = nil,
        retryable: Bool = false
    ) {
        self.statusCode = statusCode
        self.status = status
        self.code = code
        self.messageText = messageText
        self.rawBody = rawBody
        self.errors = errors
        self.retryable = retryable
    }

    /// Parses an error response body such as `{"error": "...", "code": 5}`,
    /// `{"message": "INVALID_REQUEST_BODY", "code": 400000, "errors": {...}}` or
    /// `{"error": {"code": "session_not_found", "message": "...", "retryable": false}}`.
    public init(statusCode: Int, body: Data) {
        let rawBody = String(data: body, encoding: .utf8) ?? ""
        var status = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        var code: String?
        var message: String?
        var errors: [String: JSONValue]?
        var retryable = false

        if case .object(let payload)? = try? JSONDecoder().decode(JSONValue.self, from: body) {
            if let value = payload["status"]?.text { status = value }
            code = payload["code"]?.text
            if case .object(let nested)? = payload["error"] {
                // Elements routes nest the error: {"error": {"code", "message", "retryable"}}
                code = code ?? nested["code"]?.text
                message = payload["message"]?.text ?? nested["message"]?.text
                if case .bool(let value)? = nested["retryable"] { retryable = value }
            } else {
                message = (payload["message"] ?? payload["error"])?.text
            }
            if case .object(let map)? = payload["errors"] { errors = map }
        }

        self.init(
            statusCode: statusCode,
            status: status,
            code: code,
            messageText: message,
            rawBody: rawBody,
            errors: errors,
            retryable: retryable
        )
    }

    public var errorDescription: String? {
        if let code, let messageText {
            return "API request failed with status \(statusCode) (\(status)): [\(code)] \(messageText)"
        }

        if let messageText {
            return "API request failed with status \(statusCode) (\(status)): \(messageText)"
        }

        if !rawBody.isEmpty {
            return "API request failed with status \(statusCode) (\(status)): \(rawBody)"
        }

        return "API request failed with status \(statusCode) (\(status))"
    }
}

extension JSONValue {
    /// The value as text: strings as they are, whole numbers without a fraction.
    var text: String? {
        switch self {
        case .string(let value):
            return value
        case .number(let value):
            if value.rounded() == value, abs(value) < 1e15 {
                return String(Int64(value))
            }
            return String(value)
        case .bool(let value):
            return String(value)
        case .null:
            return nil
        case .object, .array:
            guard let data = try? JSONEncoder().encode(self) else { return nil }
            return String(data: data, encoding: .utf8)
        }
    }
}
