import Foundation

private struct APIErrorPayload: Decodable {
    let code: String?
    let message: String?
    let error: String?
    let status: String?
}

private struct AnyEncodable: Encodable {
    private let encoderBlock: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        self.encoderBlock = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encoderBlock(encoder)
    }
}

public final class SharedAPIClient: @unchecked Sendable {
    private let endpoint: URL
    private let token: String
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(endpoint: String, token: String, timeout: TimeInterval = 30) {
        guard let endpointURL = URL(string: endpoint.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            preconditionFailure("Invalid endpoint: \(endpoint)")
        }

        self.endpoint = endpointURL
        self.token = token

        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        self.session = URLSession(configuration: config)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    public func get<T: Decodable>(_ path: String, query: [String: String] = [:], as type: T.Type = T.self) async throws -> T {
        try await request(path: path, method: "GET", query: query, payload: Optional<String>.none, as: type)
    }

    public func post<P: Encodable, T: Decodable>(_ path: String, payload: P, as type: T.Type = T.self) async throws -> T {
        try await request(path: path, method: "POST", query: [:], payload: payload, as: type)
    }

    public func patch<P: Encodable, T: Decodable>(_ path: String, payload: P, as type: T.Type = T.self) async throws -> T {
        try await request(path: path, method: "PATCH", query: [:], payload: payload, as: type)
    }

    public func delete<T: Decodable>(_ path: String, as type: T.Type = T.self) async throws -> T {
        try await request(path: path, method: "DELETE", query: [:], payload: Optional<String>.none, as: type)
    }

    public func getMap(_ path: String, query: [String: String] = [:]) async throws -> [String: JSONValue] {
        try await get(path, query: query, as: [String: JSONValue].self)
    }

    public func postMap<P: Encodable>(_ path: String, payload: P) async throws -> [String: JSONValue] {
        try await post(path, payload: payload, as: [String: JSONValue].self)
    }

    private func request<P: Encodable, T: Decodable>(
        path: String,
        method: String,
        query: [String: String],
        payload: P?,
        as type: T.Type
    ) async throws -> T {
        let request = try buildRequest(path: path, method: method, query: query, payload: payload)
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError(statusCode: -1, status: "Invalid Response", code: nil, messageText: "Non-HTTP response", rawBody: "")
        }

        let bodyString = String(data: data, encoding: .utf8) ?? ""

        guard (200...299).contains(http.statusCode) else {
            let payload = try? decoder.decode(APIErrorPayload.self, from: data)
            throw APIError(
                statusCode: http.statusCode,
                status: payload?.status ?? HTTPURLResponse.localizedString(forStatusCode: http.statusCode),
                code: payload?.code,
                messageText: payload?.message ?? payload?.error,
                rawBody: bodyString
            )
        }

        if data.isEmpty {
            return try decoder.decode(T.self, from: Data("{}".utf8))
        }

        return try decoder.decode(T.self, from: data)
    }

    private func buildRequest<P: Encodable>(path: String, method: String, query: [String: String], payload: P?) throws -> URLRequest {
        guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            throw ValidationError("Invalid endpoint configuration")
        }

        let basePath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let requestPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.path = "/" + [basePath, requestPath].filter { !$0.isEmpty }.joined(separator: "/")

        if !query.isEmpty {
            components.queryItems = query
                .filter { !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .map { URLQueryItem(name: $0.key, value: $0.value) }
                .sorted { $0.name < $1.name }
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
