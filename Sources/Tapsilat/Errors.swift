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

public struct APIError: Error, LocalizedError {
    public let statusCode: Int
    public let status: String
    public let code: String?
    public let messageText: String?
    public let rawBody: String

    public init(statusCode: Int, status: String, code: String?, messageText: String?, rawBody: String) {
        self.statusCode = statusCode
        self.status = status
        self.code = code
        self.messageText = messageText
        self.rawBody = rawBody
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
