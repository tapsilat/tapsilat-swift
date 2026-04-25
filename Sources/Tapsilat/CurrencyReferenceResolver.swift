import Foundation

public protocol OrganizationCurrencyProviding: Sendable {
    func getOrganizationCurrencies() async throws -> OrganizationCurrenciesResponse
}

public actor CurrencyReferenceResolver {
    private let organizationService: OrganizationCurrencyProviding
    private var currencyIdsByUnit: [String: String] = [:]
    private var cacheReady = false

    public init(organizationService: OrganizationCurrencyProviding) {
        self.organizationService = organizationService
    }

    public func resolveCurrencyId(_ ref: String) async throws -> String {
        let trimmedRef = ref.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedRef.isEmpty else {
            throw ValidationError("currency_id is required")
        }

        if isUUID(trimmedRef) {
            return trimmedRef
        }

        let map = try await getOrganizationCurrencyIdsByUnit()
        let normalized = trimmedRef.uppercased(with: Locale(identifier: "en_US_POSIX"))
        guard let resolved = map[normalized] else {
            throw ValidationError("unknown currency reference \"\(ref)\"; use a currency UUID or organization currency unit")
        }

        return resolved
    }

    public func resolveCurrencyIds(_ refs: [String]) async throws -> [String] {
        guard !refs.isEmpty else {
            throw ValidationError("currencies must contain at least one currency reference")
        }

        var seen: Set<String> = []
        var resolved: [String] = []

        for ref in refs {
            let value = try await resolveCurrencyId(ref)
            if seen.insert(value).inserted {
                resolved.append(value)
            }
        }

        guard !resolved.isEmpty else {
            throw ValidationError("currencies must contain at least one currency reference")
        }

        return resolved
    }

    public func invalidateCache() {
        currencyIdsByUnit = [:]
        cacheReady = false
    }

    private func getOrganizationCurrencyIdsByUnit() async throws -> [String: String] {
        if cacheReady {
            return currencyIdsByUnit
        }

        let response = try await organizationService.getOrganizationCurrencies()
        var resolved: [String: String] = [:]

        for currency in response.currencies {
            guard
                let unit = currency.currencyUnit?.trimmingCharacters(in: .whitespacesAndNewlines),
                !unit.isEmpty,
                let id = currency.id?.trimmingCharacters(in: .whitespacesAndNewlines),
                !id.isEmpty
            else {
                continue
            }

            resolved[unit.uppercased(with: Locale(identifier: "en_US_POSIX"))] = id
        }

        currencyIdsByUnit = resolved
        cacheReady = true
        return resolved
    }

    private func isUUID(_ value: String) -> Bool {
        UUID(uuidString: value) != nil
    }
}
