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
    /// The body's `code` field as text, such as "400000".
    public let code: String?
    /// The body's `message` field, else its `error` field.
    public let messageText: String?
    public let rawBody: String
    /// Per-field validation messages, when the API returns them.
    public let errors: [String: JSONValue]?

    public init(
        statusCode: Int,
        status: String,
        code: String?,
        messageText: String?,
        rawBody: String,
        errors: [String: JSONValue]? = nil
    ) {
        self.statusCode = statusCode
        self.status = status
        self.code = code
        self.messageText = messageText
        self.rawBody = rawBody
        self.errors = errors
    }

    /// Parses an error response body such as `{"error": "...", "code": 5}` or
    /// `{"message": "INVALID_REQUEST_BODY", "code": 400000, "errors": {...}}`.
    public init(statusCode: Int, body: Data) {
        let rawBody = String(data: body, encoding: .utf8) ?? ""
        var status = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        var code: String?
        var message: String?
        var errors: [String: JSONValue]?

        if case .object(let payload)? = try? JSONDecoder().decode(JSONValue.self, from: body) {
            if let value = payload["status"]?.text { status = value }
            code = payload["code"]?.text
            message = (payload["message"] ?? payload["error"])?.text
            if case .object(let map)? = payload["errors"] { errors = map }
        }

        self.init(statusCode: statusCode, status: status, code: code, messageText: message, rawBody: rawBody, errors: errors)
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
