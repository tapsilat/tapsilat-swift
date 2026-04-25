import XCTest
@testable import Tapsilat

private final class OrganizationServiceStub: OrganizationCurrencyProviding, @unchecked Sendable {
    var callCount = 0
    var response = OrganizationCurrenciesResponse(
        currencies: [
            .init(id: "550e8400-e29b-41d4-a716-446655440000", currencyUnit: "TRY", code: "TRY", name: "Turkish Lira", symbol: "TL"),
            .init(id: "6ba7b810-9dad-11d1-80b4-00c04fd430c8", currencyUnit: "USD", code: "USD", name: "US Dollar", symbol: "$")
        ]
    )

    func getOrganizationCurrencies() async throws -> OrganizationCurrenciesResponse {
        callCount += 1
        return response
    }
}

final class CurrencyReferenceResolverTests: XCTestCase {
    func testUUIDPassthrough() async throws {
        let stub = OrganizationServiceStub()
        let resolver = CurrencyReferenceResolver(organizationService: stub)

        let uuid = "550e8400-e29b-41d4-a716-446655440000"
        let result = try await resolver.resolveCurrencyId(uuid)

        XCTAssertEqual(result, uuid)
        XCTAssertEqual(stub.callCount, 0)
    }

    func testResolveAndCacheByUnit() async throws {
        let stub = OrganizationServiceStub()
        let resolver = CurrencyReferenceResolver(organizationService: stub)

        let first = try await resolver.resolveCurrencyId("try")
        let second = try await resolver.resolveCurrencyId("USD")

        XCTAssertEqual(first, "550e8400-e29b-41d4-a716-446655440000")
        XCTAssertEqual(second, "6ba7b810-9dad-11d1-80b4-00c04fd430c8")
        XCTAssertEqual(stub.callCount, 1)
    }

    func testInvalidateCacheForcesRefetch() async throws {
        let stub = OrganizationServiceStub()
        let resolver = CurrencyReferenceResolver(organizationService: stub)

        _ = try await resolver.resolveCurrencyId("TRY")
        await resolver.invalidateCache()
        _ = try await resolver.resolveCurrencyId("USD")

        XCTAssertEqual(stub.callCount, 2)
    }
}
