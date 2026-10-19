import Foundation

/// Marketplace sellers, payouts and policies. These routes are served by API v2, derived from
/// the configured endpoint.
public final class MarketplaceService: @unchecked Sendable {
    private let client: SharedAPIClient
    private let currencyResolver: CurrencyReferenceResolver
    private let version = "v2"

    public init(client: SharedAPIClient, currencyResolver: CurrencyReferenceResolver) {
        self.client = client
        self.currencyResolver = currencyResolver
    }

    private func escape(_ value: String) -> String {
        SharedAPIClient.pathEscape(value)
    }

    // MARK: Sellers

    /// Creates a logical seller; inspect `provisionings` for each VPOS account's readiness.
    public func createSubmerchant(_ payload: MarketplaceSubmerchantCreateRequest) async throws -> MarketplaceSubmerchantCreateResponse {
        try await client.send("POST", "/submerchants", version: version, payload: payload)
    }

    /// Returns a page of the seller directory, or an exact external ID match when `externalId` is set.
    public func listSubmerchants(page: Int, perPage: Int, externalId: String? = nil) async throws -> MarketplaceSellerList {
        let query = QueryBuilder().with("page", page).with("per_page", perPage).with("external_id", externalId)
        return try await client.send("GET", "/submerchants", version: version, query: query.items)
    }

    /// Returns the current seller profile and its revision.
    public func getSubmerchant(id: String) async throws -> MarketplaceSeller {
        try await client.send("GET", "/submerchants/\(escape(id))", version: version)
    }

    /// Replaces the profile at the supplied revision and reports whether review is required.
    public func updateSubmerchant(id: String, payload: MarketplaceProfileUpdate) async throws -> MarketplaceProfileUpdateResponse {
        try await client.send("PATCH", "/submerchants/\(escape(id))", version: version, payload: payload)
    }

    /// Returns the selected accounts' requirements for a seller operation.
    public func getSellerContracts(_ filter: MarketplaceContractFilter) async throws -> MarketplaceContracts {
        var query = QueryBuilder()
            .with("currency_id", filter.currencyId)
            .with("seller_type", filter.sellerType)
            .with("operation", filter.operation)
        for vposId in filter.vposIds {
            query = query.with("vpos_id", vposId)
        }
        return try await client.send("GET", "/marketplace/seller-contracts", version: version, query: query.items)
    }

    /// Returns account registration, synchronization and available actions.
    public func getSellerAccounts(id: String) async throws -> MarketplaceSellerAccounts {
        try await client.send("GET", "/submerchants/\(escape(id))/providers", version: version)
    }

    /// Executes an available account action at the supplied revision and environment.
    public func runSellerAccountAction(
        id: String,
        vposId: String,
        payload: MarketplaceAccountAction
    ) async throws -> MarketplaceSubmerchantProvisioning {
        try await client.send("POST", "/submerchants/\(escape(id))/providers/\(escape(vposId))/actions", version: version, payload: payload)
    }

    // MARK: Payouts

    /// Returns filtered organization-scoped payouts and their release state.
    public func listPayouts(_ filter: MarketplacePayoutFilter) async throws -> MarketplacePayoutList {
        let query = QueryBuilder()
            .with("order_id", filter.orderId)
            .with("submerchant_id", filter.submerchantId)
            .with("vpos_id", filter.vposId)
            .with("provider", filter.provider)
            .with("status", filter.status)
            .with("release_status", filter.releaseStatus)
            .with("approval_mode", filter.approvalMode)
            .with("currency", filter.currency)
            .with("eligibility", filter.eligibility)
            .with("search", filter.search)
            .with("min_amount", filter.minAmount)
            .with("max_amount", filter.maxAmount)
            .with("start_date", filter.startDate)
            .with("end_date", filter.endDate)
            .with("page", filter.page)
            .with("per_page", filter.perPage)
        return try await client.send("GET", "/submerchant-payouts", version: version, query: query.items)
    }

    /// Returns a payout's eligibility, approval and settlement state.
    public func getPayout(id: String) async throws -> MarketplacePayout {
        try await client.send("GET", "/submerchant-payouts/\(escape(id))", version: version)
    }

    /// Submits eligible payouts to the approval workflow; the server answers 202 Accepted.
    public func approvePayouts(_ payload: MarketplacePayoutApproval) async throws -> MarketplacePayoutAcceptance {
        try await client.send("POST", "/submerchant-payouts/approve", version: version, payload: payload)
    }

    /// Changes allocation or withdraws approval; inspect `status` before treating it as complete.
    public func runPayoutOperation(payoutId: String, payload: MarketplacePayoutOperationInput) async throws -> MarketplacePayoutOperation {
        try await client.send("POST", "/submerchant-payouts/\(escape(payoutId))/operations", version: version, payload: payload)
    }

    /// Returns the persisted operation receipt.
    public func getPayoutOperation(id: String) async throws -> MarketplacePayoutOperation {
        try await client.send("GET", "/marketplace/payout-operations/\(escape(id))", version: version)
    }

    /// Checks the provider result without repeating a mutation.
    public func reconcilePayoutOperation(id: String) async throws -> MarketplacePayoutOperation {
        try await client.send("POST", "/marketplace/payout-operations/\(escape(id))/reconcile", version: version)
    }

    /// Repeats an unresolved change only after verifying the previous provider state.
    public func retryPayoutOperation(id: String) async throws -> MarketplacePayoutOperation {
        try await client.send("POST", "/marketplace/payout-operations/\(escape(id))/retry", version: version)
    }

    // MARK: Approval settings and policies

    public func getApprovalSettings() async throws -> MarketplaceApprovalSettings {
        try await client.send("GET", "/marketplace/approval-settings", version: version)
    }

    public func updateApprovalSettings(_ payload: MarketplaceApprovalSettings) async throws -> MarketplaceApprovalSettings {
        try await client.send("PATCH", "/marketplace/approval-settings", version: version, payload: payload)
    }

    public func listApprovalPolicies() async throws -> MarketplaceApprovalPolicies {
        try await client.send("GET", "/marketplace/approval-policies", version: version)
    }

    public func getApprovalPolicy(id: String) async throws -> MarketplaceApprovalPolicy {
        try await client.send("GET", "/marketplace/approval-policies/\(escape(id))", version: version)
    }

    /// Creates an approval rule. A `currencyId` given as a unit such as "TRY" is resolved to its UUID.
    public func createApprovalPolicy(_ payload: MarketplaceApprovalPolicyInput) async throws {
        let resolved = try await resolvingCurrency(payload)
        let _: EmptyResponse = try await client.send("POST", "/marketplace/approval-policies", version: version, payload: resolved)
    }

    /// Replaces an approval rule. A `currencyId` given as a unit such as "TRY" is resolved to its UUID.
    public func updateApprovalPolicy(id: String, payload: MarketplaceApprovalPolicyInput) async throws {
        let resolved = try await resolvingCurrency(payload)
        let _: EmptyResponse = try await client.send("PATCH", "/marketplace/approval-policies/\(escape(id))", version: version, payload: resolved)
    }

    /// Deletes an approval rule; the server answers 204 No Content.
    public func deleteApprovalPolicy(id: String) async throws {
        let _: EmptyResponse = try await client.send("DELETE", "/marketplace/approval-policies/\(escape(id))", version: version)
    }

    public func listReleasePolicies() async throws -> MarketplaceReleasePolicies {
        try await client.send("GET", "/marketplace/release-policies", version: version)
    }

    public func getReleasePolicy(id: String) async throws -> MarketplaceReleasePolicy {
        try await client.send("GET", "/marketplace/release-policies/\(escape(id))", version: version)
    }

    public func createReleasePolicy(_ payload: MarketplaceReleasePolicyInput) async throws -> MarketplaceReleasePolicy {
        try await client.send("POST", "/marketplace/release-policies", version: version, payload: payload)
    }

    public func updateReleasePolicy(id: String, payload: MarketplaceReleasePolicyInput) async throws -> MarketplaceReleasePolicy {
        try await client.send("PATCH", "/marketplace/release-policies/\(escape(id))", version: version, payload: payload)
    }

    /// Deletes a release policy; the server answers 204 No Content.
    public func deleteReleasePolicy(id: String) async throws {
        let _: EmptyResponse = try await client.send("DELETE", "/marketplace/release-policies/\(escape(id))", version: version)
    }

    private func resolvingCurrency(_ payload: MarketplaceApprovalPolicyInput) async throws -> MarketplaceApprovalPolicyInput {
        guard !payload.currencyId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return payload
        }
        var resolved = payload
        resolved.currencyId = try await currencyResolver.resolveCurrencyId(payload.currencyId)
        return resolved
    }
}
