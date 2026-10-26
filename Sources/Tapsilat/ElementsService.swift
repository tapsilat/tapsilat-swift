import Foundation

/// Tapsilat Elements sessions for the native Android and iOS card sheet.
///
/// Call these with your secret API key from your server, never from an app. Create a session,
/// hand only its `clientSecret` to your app, which opens the card sheet with it, and read the
/// outcome with `getElementsSession(id:)` before fulfilling. Card data goes from the sheet to
/// Tapsilat encrypted and never reaches your server.
///
/// Errors arrive as `{"error": {"code": "...", "message": "...", "retryable": true}}` and are thrown
/// as `APIError` with that `code`, `messageText` and `retryable`.
public final class ElementsService: @unchecked Sendable {
    private let client: SharedAPIClient

    public init(client: SharedAPIClient) {
        self.client = client
    }

    /// Opens a session with `POST /elements/sessions`. Hand the returned `clientSecret` to your
    /// app; do not log or store it.
    public func createElementsSession(_ payload: ElementsSessionCreateRequest) async throws -> ElementsSessionWithSecret {
        try await client.post("/elements/sessions", payload: payload)
    }

    /// Returns the session's authoritative state and outcome from `GET /elements/sessions/{id}`.
    /// Read it on your server before fulfilling, rather than trusting what the app reports.
    public func getElementsSession(id: String) async throws -> ElementsSession {
        try await client.send("GET", "/elements/sessions/\(SharedAPIClient.pathEscape(id))")
    }

    /// Cancels a session that is still waiting for a card with `POST /elements/sessions/{id}/cancel`.
    /// A session that is confirming or has completed comes back unchanged.
    public func cancelElementsSession(id: String) async throws -> ElementsSession {
        try await client.send("POST", "/elements/sessions/\(SharedAPIClient.pathEscape(id))/cancel")
    }
}
