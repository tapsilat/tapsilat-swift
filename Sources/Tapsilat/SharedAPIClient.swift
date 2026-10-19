import Foundation

private struct AnyEncodable: Encodable {
    private let encoderBlock: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        self.encoderBlock = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encoderBlock(encoder)
    }
}

/// Decodes a response whose body is ignored, such as a delete answered with 204 No Content.
public struct EmptyResponse: Codable, Sendable {
    public init() {}
}

public final class SharedAPIClient: @unchecked Sendable {
    private let endpoint: URL?
    private let endpointText: String
    private let token: String
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    /// Creates a client for `endpoint`, the API v1 base URL. An invalid endpoint is reported by
    /// the first request. Pass `session` to use your own `URLSession`, for example in tests.
    public init(endpoint: String, token: String, timeout: TimeInterval = 30, session: URLSession? = nil) {
        self.endpointText = endpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        self.endpoint = URL(string: endpointText).flatMap { $0.scheme == nil || $0.host == nil ? nil : $0 }
        self.token = token

        if let session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.ephemeral
            config.timeoutIntervalForRequest = timeout
            config.timeoutIntervalForResource = timeout
            self.session = URLSession(configuration: config)
        }

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    public func get<T: Decodable>(_ path: String, query: [String: String] = [:], as type: T.Type = T.self) async throws -> T {
        try await request(method: "GET", path: path, queryItems: Self.sortedItems(query), payload: Optional<String>.none, as: type)
    }

    public func post<P: Encodable, T: Decodable>(_ path: String, payload: P, as type: T.Type = T.self) async throws -> T {
        try await request(method: "POST", path: path, payload: payload, as: type)
    }

    public func put<P: Encodable, T: Decodable>(_ path: String, payload: P, as type: T.Type = T.self) async throws -> T {
        try await request(method: "PUT", path: path, payload: payload, as: type)
    }

    public func patch<P: Encodable, T: Decodable>(_ path: String, payload: P, as type: T.Type = T.self) async throws -> T {
        try await request(method: "PATCH", path: path, payload: payload, as: type)
    }

    public func delete<T: Decodable>(_ path: String, as type: T.Type = T.self) async throws -> T {
        try await request(method: "DELETE", path: path, payload: Optional<String>.none, as: type)
    }

    /// Sends a DELETE request with a JSON body.
    public func delete<P: Encodable, T: Decodable>(_ path: String, payload: P, as type: T.Type = T.self) async throws -> T {
        try await request(method: "DELETE", path: path, payload: payload, as: type)
    }

    public func getMap(_ path: String, query: [String: String] = [:]) async throws -> [String: JSONValue] {
        try await get(path, query: query, as: [String: JSONValue].self)
    }

    public func postMap<P: Encodable>(_ path: String, payload: P) async throws -> [String: JSONValue] {
        try await post(path, payload: payload, as: [String: JSONValue].self)
    }

    /// Sends a request. `version` selects another API version, such as "v2"; `queryItems` keep
    /// their order and may repeat a name.
    public func request<P: Encodable, T: Decodable>(
        method: String,
        path: String,
        version: String? = nil,
        queryItems: [URLQueryItem] = [],
        payload: P?,
        as type: T.Type = T.self
    ) async throws -> T {
        let request = try buildRequest(method: method, path: path, version: version, queryItems: queryItems, payload: payload)
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError(statusCode: -1, status: "Invalid Response", code: nil, messageText: "Non-HTTP response", rawBody: "")
        }

        let bodyString = String(data: data, encoding: .utf8) ?? ""

        guard http.statusCode < 400 else {
            throw APIError(statusCode: http.statusCode, body: data)
        }

        // A deployment serving the panel UI answers unknown routes with its HTML page and status 200
        let contentType = http.value(forHTTPHeaderField: "Content-Type") ?? ""
        if contentType.lowercased().contains("text/html") || bodyString.drop(while: { $0.isWhitespace }).hasPrefix("<") {
            throw APIError(
                statusCode: http.statusCode,
                status: HTTPURLResponse.localizedString(forStatusCode: http.statusCode),
                code: nil,
                messageText: "unexpected non-JSON response (Content-Type \"\(contentType)\"); check that the endpoint URL and route are correct",
                rawBody: bodyString
            )
        }

        if bodyString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return try decoder.decode(T.self, from: Data("{}".utf8))
        }

        return try decoder.decode(T.self, from: data)
    }

    /// Returns the endpoint for another API version: a trailing `/api/vN` is replaced with
    /// `/api/{version}`, otherwise `/api/{version}` is appended.
    public func versionedEndpoint(_ version: String) throws -> URL {
        guard let endpoint, var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            throw ValidationError("Invalid endpoint: \(endpointText)")
        }

        var segments = components.percentEncodedPath.split(separator: "/").map(String.init)
        if segments.count >= 2, segments[segments.count - 2] == "api", Self.isVersion(segments[segments.count - 1]) {
            segments[segments.count - 1] = version
        } else {
            segments += ["api", version]
        }
        components.percentEncodedPath = "/" + segments.joined(separator: "/")

        guard let url = components.url else {
            throw ValidationError("Invalid endpoint: \(endpointText)")
        }
        return url
    }

    /// Escapes a value for use as a single URL path segment.
    public static func pathEscape(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: unreserved) ?? value
    }

    private static let unreserved = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")

    private static func isVersion(_ segment: String) -> Bool {
        segment.count > 1 && segment.hasPrefix("v") && segment.dropFirst().allSatisfy(\.isNumber)
    }

    private static func sortedItems(_ query: [String: String]) -> [URLQueryItem] {
        query
            .filter { !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
            .sorted { $0.name < $1.name }
    }

    private func buildRequest<P: Encodable>(
        method: String,
        path: String,
        version: String?,
        queryItems: [URLQueryItem],
        payload: P?
    ) throws -> URLRequest {
        guard let endpoint else {
            throw ValidationError("Invalid endpoint: \(endpointText)")
        }
        let base = try version.map { try versionedEndpoint($0) } ?? endpoint
        guard var components = URLComponents(url: base, resolvingAgainstBaseURL: false) else {
            throw ValidationError("Invalid endpoint: \(endpointText)")
        }

        let basePath = components.percentEncodedPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let requestPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.percentEncodedPath = "/" + [basePath, requestPath].filter { !$0.isEmpty }.joined(separator: "/")

        if !queryItems.isEmpty {
            components.percentEncodedQuery = queryItems
                .map { "\(Self.pathEscape($0.name))=\(Self.pathEscape($0.value ?? ""))" }
                .joined(separator: "&")
        }

        guard let url = components.url else {
            throw ValidationError("Invalid URL for path: \(path)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let payload {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try encoder.encode(AnyEncodable(payload))
        }

        return request
    }
}

/// Builds query items, skipping absent and empty values.
struct QueryBuilder {
    private(set) var items: [URLQueryItem] = []

    func with(_ name: String, _ value: CustomStringConvertible?) -> QueryBuilder {
        guard let value, !value.description.isEmpty else { return self }
        var copy = self
        copy.items.append(URLQueryItem(name: name, value: value.description))
        return copy
    }
}
