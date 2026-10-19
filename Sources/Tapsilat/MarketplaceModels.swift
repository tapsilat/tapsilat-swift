import Foundation

// Marketplace (API v2) models. Revisions are RFC3339 timestamps with nanosecond precision that the
// server compares exactly: keep them as the strings you received and send them back unchanged.

public struct MarketplaceAccountTarget: Codable, Sendable {
    public var vposId: String
    public var environment: String

    public init(vposId: String, environment: String) {
        self.vposId = vposId
        self.environment = environment
    }
}

/// Creates a marketplace seller. Without `vposId` or `providerAccounts` only the seller is created.
public struct MarketplaceSubmerchantCreateRequest: Codable, Sendable {
    /// Explicitly selects accounts in one environment; an empty list creates only the seller.
    /// It cannot be combined with `vposId`.
    public var providerAccounts: [MarketplaceAccountTarget]?
    public var locale: String?
    public var conversationId: String?
    public var name: String?
    public var email: String?
    public var gsmNumber: String?
    public var address: String?
    public var iban: String?
    public var taxOffice: String?
    public var legalCompanyTitle: String?
    /// A currency UUID or unit such as "TRY".
    public var currencyId: String?
    public var subMerchantExternalId: String?
    public var identityNumber: String?
    public var subMerchantType: String?
    public var taxNumber: String?
    public var labels: [String]?
    public var status: String?
    public var systemTime: Int?
    public var contactName: String?
    public var contactSurname: String?
    public var approvalMode: String?
    public var releasePolicyId: String?
    public var idempotencyKey: String?
    /// Targets only this account, using its configured environment.
    public var vposId: String?

    public init(
        providerAccounts: [MarketplaceAccountTarget]? = nil,
        locale: String? = nil,
        conversationId: String? = nil,
        name: String? = nil,
        email: String? = nil,
        gsmNumber: String? = nil,
        address: String? = nil,
        iban: String? = nil,
        taxOffice: String? = nil,
        legalCompanyTitle: String? = nil,
        currencyId: String? = nil,
        subMerchantExternalId: String? = nil,
        identityNumber: String? = nil,
        subMerchantType: String? = nil,
        taxNumber: String? = nil,
        labels: [String]? = nil,
        status: String? = nil,
        systemTime: Int? = nil,
        contactName: String? = nil,
        contactSurname: String? = nil,
        approvalMode: String? = nil,
        releasePolicyId: String? = nil,
        idempotencyKey: String? = nil,
        vposId: String? = nil
    ) {
        self.providerAccounts = providerAccounts
        self.locale = locale
        self.conversationId = conversationId
        self.name = name
        self.email = email
        self.gsmNumber = gsmNumber
        self.address = address
        self.iban = iban
        self.taxOffice = taxOffice
        self.legalCompanyTitle = legalCompanyTitle
        self.currencyId = currencyId
        self.subMerchantExternalId = subMerchantExternalId
        self.identityNumber = identityNumber
        self.subMerchantType = subMerchantType
        self.taxNumber = taxNumber
        self.labels = labels
        self.status = status
        self.systemTime = systemTime
        self.contactName = contactName
        self.contactSurname = contactSurname
        self.approvalMode = approvalMode
        self.releasePolicyId = releasePolicyId
        self.idempotencyKey = idempotencyKey
        self.vposId = vposId
    }
}

public struct MarketplaceSubmerchantProvisioning: Codable, Sendable {
    public var vposId: String?
    public var vposSubmerchantId: String?
    public var provider: String?
    public var status: String?
    public var providerSubmerchantKey: String?
    public var retryable: Bool?
    public var errorMessage: String?

    public init(
        vposId: String? = nil,
        vposSubmerchantId: String? = nil,
        provider: String? = nil,
        status: String? = nil,
        providerSubmerchantKey: String? = nil,
        retryable: Bool? = nil,
        errorMessage: String? = nil
    ) {
        self.vposId = vposId
        self.vposSubmerchantId = vposSubmerchantId
        self.provider = provider
        self.status = status
        self.providerSubmerchantKey = providerSubmerchantKey
        self.retryable = retryable
        self.errorMessage = errorMessage
    }
}

/// The created seller; inspect `provisionings` for each VPOS account's readiness.
public struct MarketplaceSubmerchantCreateResponse: Codable, Sendable {
    public var id: String?
    public var suborganizationId: String?
    public var vposSubmerchantId: String?
    public var routingReference: String?
    public var provisionings: [MarketplaceSubmerchantProvisioning]?

    public init(
        id: String? = nil,
        suborganizationId: String? = nil,
        vposSubmerchantId: String? = nil,
        routingReference: String? = nil,
        provisionings: [MarketplaceSubmerchantProvisioning]? = nil
    ) {
        self.id = id
        self.suborganizationId = suborganizationId
        self.vposSubmerchantId = vposSubmerchantId
        self.routingReference = routingReference
        self.provisionings = provisionings
    }
}

public struct MarketplaceSeller: Codable, Sendable {
    public var id: String?
    public var routingReference: String?
    /// Opaque revision; send it back unchanged when updating the seller.
    public var revision: String?
    public var name: String?
    public var email: String?
    public var gsmNumber: String?
    public var address: String?
    public var iban: String?
    public var currencyId: String?
    public var subMerchantType: String?
    public var subMerchantExternalId: String?
    public var identityNumber: String?
    public var taxNumber: String?
    public var taxOffice: String?
    public var legalCompanyTitle: String?
    public var contactName: String?
    public var contactSurname: String?
    public var locale: String?
    public var conversationId: String?
    public var status: String?
    public var labels: [String]?
    public var approvalMode: String?
    public var releasePolicyId: String?

    public init(
        id: String? = nil,
        routingReference: String? = nil,
        revision: String? = nil,
        name: String? = nil,
        email: String? = nil,
        gsmNumber: String? = nil,
        address: String? = nil,
        iban: String? = nil,
        currencyId: String? = nil,
        subMerchantType: String? = nil,
        subMerchantExternalId: String? = nil,
        identityNumber: String? = nil,
        taxNumber: String? = nil,
        taxOffice: String? = nil,
        legalCompanyTitle: String? = nil,
        contactName: String? = nil,
        contactSurname: String? = nil,
        locale: String? = nil,
        conversationId: String? = nil,
        status: String? = nil,
        labels: [String]? = nil,
        approvalMode: String? = nil,
        releasePolicyId: String? = nil
    ) {
        self.id = id
        self.routingReference = routingReference
        self.revision = revision
        self.name = name
        self.email = email
        self.gsmNumber = gsmNumber
        self.address = address
        self.iban = iban
        self.currencyId = currencyId
        self.subMerchantType = subMerchantType
        self.subMerchantExternalId = subMerchantExternalId
        self.identityNumber = identityNumber
        self.taxNumber = taxNumber
        self.taxOffice = taxOffice
        self.legalCompanyTitle = legalCompanyTitle
        self.contactName = contactName
        self.contactSurname = contactSurname
        self.locale = locale
        self.conversationId = conversationId
        self.status = status
        self.labels = labels
        self.approvalMode = approvalMode
        self.releasePolicyId = releasePolicyId
    }
}

public struct MarketplaceSellerList: Codable, Sendable {
    public var rows: [MarketplaceSeller]?
    public var page: Int?
    public var perPage: Int?
    public var total: Int?
    public var totalPages: Int?

    public init(
        rows: [MarketplaceSeller]? = nil,
        page: Int? = nil,
        perPage: Int? = nil,
        total: Int? = nil,
        totalPages: Int? = nil
    ) {
        self.rows = rows
        self.page = page
        self.perPage = perPage
        self.total = total
        self.totalPages = totalPages
    }
}

/// Replaces the saved seller profile at `revision`.
public struct MarketplaceProfileUpdate: Codable, Sendable {
    public var locale: String?
    public var conversationId: String?
    public var name: String?
    public var email: String?
    public var gsmNumber: String?
    public var address: String?
    public var iban: String?
    public var taxOffice: String?
    public var legalCompanyTitle: String?
    /// A currency UUID or unit such as "TRY".
    public var currencyId: String?
    public var subMerchantExternalId: String?
    public var identityNumber: String?
    public var subMerchantType: String?
    public var taxNumber: String?
    public var labels: [String]?
    public var status: String?
    public var systemTime: Int?
    public var contactName: String?
    public var contactSurname: String?
    public var approvalMode: String?
    public var releasePolicyId: String?
    public var idempotencyKey: String?
    /// The seller's revision, exactly as received.
    public var revision: String

    public init(
        locale: String? = nil,
        conversationId: String? = nil,
        name: String? = nil,
        email: String? = nil,
        gsmNumber: String? = nil,
        address: String? = nil,
        iban: String? = nil,
        taxOffice: String? = nil,
        legalCompanyTitle: String? = nil,
        currencyId: String? = nil,
        subMerchantExternalId: String? = nil,
        identityNumber: String? = nil,
        subMerchantType: String? = nil,
        taxNumber: String? = nil,
        labels: [String]? = nil,
        status: String? = nil,
        systemTime: Int? = nil,
        contactName: String? = nil,
        contactSurname: String? = nil,
        approvalMode: String? = nil,
        releasePolicyId: String? = nil,
        idempotencyKey: String? = nil,
        revision: String
    ) {
        self.locale = locale
        self.conversationId = conversationId
        self.name = name
        self.email = email
        self.gsmNumber = gsmNumber
        self.address = address
        self.iban = iban
        self.taxOffice = taxOffice
        self.legalCompanyTitle = legalCompanyTitle
        self.currencyId = currencyId
        self.subMerchantExternalId = subMerchantExternalId
        self.identityNumber = identityNumber
        self.subMerchantType = subMerchantType
        self.taxNumber = taxNumber
        self.labels = labels
        self.status = status
        self.systemTime = systemTime
        self.contactName = contactName
        self.contactSurname = contactSurname
        self.approvalMode = approvalMode
        self.releasePolicyId = releasePolicyId
        self.idempotencyKey = idempotencyKey
        self.revision = revision
    }
}

public struct MarketplaceProfileUpdateResponse: Codable, Sendable {
    public var approvalRequired: Bool?

    public init(approvalRequired: Bool? = nil) {
        self.approvalRequired = approvalRequired
    }
}

public struct MarketplaceSellerContract: Codable, Sendable {
    public var supported: Bool?
    public var remote: Bool?
    public var fields: [String: Bool]?
    public var immutableFields: [String]?
    public var currencies: [String]?

    public init(
        supported: Bool? = nil,
        remote: Bool? = nil,
        fields: [String: Bool]? = nil,
        immutableFields: [String]? = nil,
        currencies: [String]? = nil
    ) {
        self.supported = supported
        self.remote = remote
        self.fields = fields
        self.immutableFields = immutableFields
        self.currencies = currencies
    }
}

public struct MarketplaceContracts: Codable, Sendable {
    public var contracts: [String: MarketplaceSellerContract]?

    public init(contracts: [String: MarketplaceSellerContract]? = nil) {
        self.contracts = contracts
    }
}

public struct MarketplaceContractFilter: Sendable {
    /// A currency UUID or unit such as "TRY".
    public var currencyId: String
    public var sellerType: String
    public var operation: String
    public var vposIds: [String]

    public init(
        currencyId: String,
        sellerType: String,
        operation: String = "create",
        vposIds: [String] = []
    ) {
        self.currencyId = currencyId
        self.sellerType = sellerType
        self.operation = operation
        self.vposIds = vposIds
    }
}

public struct MarketplaceSynchronization: Codable, Sendable {
    public var status: String?
    public var operation: String?
    public var errorMessage: String?
    public var needsUpdate: Bool?
    public var attempts: Int?
    public var verifiedAt: String?
    public var missingFields: [String]?

    public init(
        status: String? = nil,
        operation: String? = nil,
        errorMessage: String? = nil,
        needsUpdate: Bool? = nil,
        attempts: Int? = nil,
        verifiedAt: String? = nil,
        missingFields: [String]? = nil
    ) {
        self.status = status
        self.operation = operation
        self.errorMessage = errorMessage
        self.needsUpdate = needsUpdate
        self.attempts = attempts
        self.verifiedAt = verifiedAt
        self.missingFields = missingFields
    }
}

public struct MarketplaceSellerAccount: Codable, Sendable {
    public var vposId: String?
    public var name: String?
    public var provider: String?
    public var environment: String?
    public var eligible: Bool?
    public var mapped: Bool?
    public var status: String?
    public var attempts: Int?
    public var updatedAt: String?
    public var errorMessage: String?
    public var retryable: Bool?
    public var revision: String?
    public var sellerRevision: String?
    public var accountRevision: String?
    public var actions: [String]?
    public var contracts: [String: MarketplaceSellerContract]?
    public var contractError: String?
    public var sync: MarketplaceSynchronization?
    public var registrationProfileChanged: Bool?
    public var registrationMissingFields: [String]?
    public var providerSubmerchantKey: String?

    public init(
        vposId: String? = nil,
        name: String? = nil,
        provider: String? = nil,
        environment: String? = nil,
        eligible: Bool? = nil,
        mapped: Bool? = nil,
        status: String? = nil,
        attempts: Int? = nil,
        updatedAt: String? = nil,
        errorMessage: String? = nil,
        retryable: Bool? = nil,
        revision: String? = nil,
        sellerRevision: String? = nil,
        accountRevision: String? = nil,
        actions: [String]? = nil,
        contracts: [String: MarketplaceSellerContract]? = nil,
        contractError: String? = nil,
        sync: MarketplaceSynchronization? = nil,
        registrationProfileChanged: Bool? = nil,
        registrationMissingFields: [String]? = nil,
        providerSubmerchantKey: String? = nil
    ) {
        self.vposId = vposId
        self.name = name
        self.provider = provider
        self.environment = environment
        self.eligible = eligible
        self.mapped = mapped
        self.status = status
        self.attempts = attempts
        self.updatedAt = updatedAt
        self.errorMessage = errorMessage
        self.retryable = retryable
        self.revision = revision
        self.sellerRevision = sellerRevision
        self.accountRevision = accountRevision
        self.actions = actions
        self.contracts = contracts
        self.contractError = contractError
        self.sync = sync
        self.registrationProfileChanged = registrationProfileChanged
        self.registrationMissingFields = registrationMissingFields
        self.providerSubmerchantKey = providerSubmerchantKey
    }
}

public struct MarketplaceSellerAccounts: Codable, Sendable {
    public var rows: [MarketplaceSellerAccount]?

    public init(rows: [MarketplaceSellerAccount]? = nil) {
        self.rows = rows
    }
}

/// Confirms a listed account action using the account's latest revision and environment.
/// Retry reuses the original snapshot; resubmit registers the current saved profile.
public struct MarketplaceAccountAction: Codable, Sendable {
    public var action: String
    public var environment: String
    public var revision: String

    public init(
        action: String,
        environment: String,
        revision: String
    ) {
        self.action = action
        self.environment = environment
        self.revision = revision
    }
}

public struct MarketplacePayout: Codable, Sendable {
    /// Opaque revision; send it back unchanged in payout operations.
    public var revision: String?
    public var activeOperationId: String?
    public var id: String?
    public var provider: String?
    public var organizationId: String?
    public var submerchantId: String?
    public var submerchantName: String?
    public var orderId: String?
    public var orderReferenceId: String?
    public var orderDisplay: String?
    public var amount: String?
    public var currency: String?
    public var approvalMode: String?
    public var approvalRuleId: String?
    public var approvalRuleName: String?
    public var releasePolicyId: String?
    public var releasePolicyName: String?
    public var eligibilityStatus: String?
    public var requiredEvent: String?
    public var itemId: String?
    public var businessEligibleAt: String?
    public var eligibleAt: String?
    public var releaseStatus: String?
    public var status: String?
    public var providerReference: String?
    public var attempts: Int?
    public var releasedAt: String?
    public var createdAt: String?
    public var errorMessage: String?

    public init(
        revision: String? = nil,
        activeOperationId: String? = nil,
        id: String? = nil,
        provider: String? = nil,
        organizationId: String? = nil,
        submerchantId: String? = nil,
        submerchantName: String? = nil,
        orderId: String? = nil,
        orderReferenceId: String? = nil,
        orderDisplay: String? = nil,
        amount: String? = nil,
        currency: String? = nil,
        approvalMode: String? = nil,
        approvalRuleId: String? = nil,
        approvalRuleName: String? = nil,
        releasePolicyId: String? = nil,
        releasePolicyName: String? = nil,
        eligibilityStatus: String? = nil,
        requiredEvent: String? = nil,
        itemId: String? = nil,
        businessEligibleAt: String? = nil,
        eligibleAt: String? = nil,
        releaseStatus: String? = nil,
        status: String? = nil,
        providerReference: String? = nil,
        attempts: Int? = nil,
        releasedAt: String? = nil,
        createdAt: String? = nil,
        errorMessage: String? = nil
    ) {
        self.revision = revision
        self.activeOperationId = activeOperationId
        self.id = id
        self.provider = provider
        self.organizationId = organizationId
        self.submerchantId = submerchantId
        self.submerchantName = submerchantName
        self.orderId = orderId
        self.orderReferenceId = orderReferenceId
        self.orderDisplay = orderDisplay
        self.amount = amount
        self.currency = currency
        self.approvalMode = approvalMode
        self.approvalRuleId = approvalRuleId
        self.approvalRuleName = approvalRuleName
        self.releasePolicyId = releasePolicyId
        self.releasePolicyName = releasePolicyName
        self.eligibilityStatus = eligibilityStatus
        self.requiredEvent = requiredEvent
        self.itemId = itemId
        self.businessEligibleAt = businessEligibleAt
        self.eligibleAt = eligibleAt
        self.releaseStatus = releaseStatus
        self.status = status
        self.providerReference = providerReference
        self.attempts = attempts
        self.releasedAt = releasedAt
        self.createdAt = createdAt
        self.errorMessage = errorMessage
    }
}

public struct MarketplacePayoutFilter: Sendable {
    public var orderId: String?
    public var submerchantId: String?
    public var vposId: String?
    public var provider: String?
    public var status: String?
    public var releaseStatus: String?
    public var approvalMode: String?
    /// A currency unit such as "TRY".
    public var currency: String?
    public var eligibility: String?
    public var search: String?
    public var minAmount: String?
    public var maxAmount: String?
    /// YYYY-MM-DD.
    public var startDate: String?
    /// YYYY-MM-DD.
    public var endDate: String?
    public var page: Int
    public var perPage: Int

    public init(
        orderId: String? = nil,
        submerchantId: String? = nil,
        vposId: String? = nil,
        provider: String? = nil,
        status: String? = nil,
        releaseStatus: String? = nil,
        approvalMode: String? = nil,
        currency: String? = nil,
        eligibility: String? = nil,
        search: String? = nil,
        minAmount: String? = nil,
        maxAmount: String? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        page: Int = 1,
        perPage: Int = 20
    ) {
        self.orderId = orderId
        self.submerchantId = submerchantId
        self.vposId = vposId
        self.provider = provider
        self.status = status
        self.releaseStatus = releaseStatus
        self.approvalMode = approvalMode
        self.currency = currency
        self.eligibility = eligibility
        self.search = search
        self.minAmount = minAmount
        self.maxAmount = maxAmount
        self.startDate = startDate
        self.endDate = endDate
        self.page = page
        self.perPage = perPage
    }
}

public struct MarketplacePayoutList: Codable, Sendable {
    public var rows: [MarketplacePayout]?
    public var page: Int?
    public var perPage: Int?
    public var total: Int?
    public var totalPages: Int?

    public init(
        rows: [MarketplacePayout]? = nil,
        page: Int? = nil,
        perPage: Int? = nil,
        total: Int? = nil,
        totalPages: Int? = nil
    ) {
        self.rows = rows
        self.page = page
        self.perPage = perPage
        self.total = total
        self.totalPages = totalPages
    }
}

public struct MarketplacePayoutApproval: Codable, Sendable {
    public var ids: [String]

    public init(ids: [String]) {
        self.ids = ids
    }
}

/// Acknowledges local approval; payout completion is reported by the payout status.
public struct MarketplacePayoutAcceptance: Codable, Sendable {
    public var status: String?

    public init(status: String? = nil) {
        self.status = status
    }
}

/// Changes a payout's allocation or withdraws its approval.
public struct MarketplacePayoutOperationInput: Codable, Sendable {
    public var kind: String
    public var idempotencyKey: String
    /// The payout's revision, exactly as received.
    public var revision: String
    public var sellerReference: String?
    public var netAmount: String?

    public init(
        kind: String,
        idempotencyKey: String,
        revision: String,
        sellerReference: String? = nil,
        netAmount: String? = nil
    ) {
        self.kind = kind
        self.idempotencyKey = idempotencyKey
        self.revision = revision
        self.sellerReference = sellerReference
        self.netAmount = netAmount
    }
}

public struct MarketplacePayoutOperation: Codable, Sendable {
    public var id: String?
    public var payoutId: String?
    public var kind: String?
    public var status: String?
    public var attempts: Int?
    public var errorMessage: String?
    public var createdAt: String?
    public var updatedAt: String?

    public init(
        id: String? = nil,
        payoutId: String? = nil,
        kind: String? = nil,
        status: String? = nil,
        attempts: Int? = nil,
        errorMessage: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.payoutId = payoutId
        self.kind = kind
        self.status = status
        self.attempts = attempts
        self.errorMessage = errorMessage
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct MarketplaceApprovalPolicy: Codable, Sendable {
    public var id: String?
    public var name: String?
    public var priority: Int?
    public var enabled: Bool?
    public var provider: String?
    public var minAmount: String?
    public var maxAmount: String?
    public var currencyId: String?
    public var submerchantIds: [String]?
    public var labelsAny: [String]?
    public var mode: String?

    public init(
        id: String? = nil,
        name: String? = nil,
        priority: Int? = nil,
        enabled: Bool? = nil,
        provider: String? = nil,
        minAmount: String? = nil,
        maxAmount: String? = nil,
        currencyId: String? = nil,
        submerchantIds: [String]? = nil,
        labelsAny: [String]? = nil,
        mode: String? = nil
    ) {
        self.id = id
        self.name = name
        self.priority = priority
        self.enabled = enabled
        self.provider = provider
        self.minAmount = minAmount
        self.maxAmount = maxAmount
        self.currencyId = currencyId
        self.submerchantIds = submerchantIds
        self.labelsAny = labelsAny
        self.mode = mode
    }
}

public struct MarketplaceApprovalPolicies: Codable, Sendable {
    public var rows: [MarketplaceApprovalPolicy]?

    public init(rows: [MarketplaceApprovalPolicy]? = nil) {
        self.rows = rows
    }
}

/// Creates or replaces an approval rule.
public struct MarketplaceApprovalPolicyInput: Codable, Sendable {
    public var name: String
    public var priority: Int
    public var enabled: Bool?
    public var provider: String
    public var minAmount: String?
    public var maxAmount: String?
    /// A currency UUID or unit such as "TRY"; the SDK resolves a unit to its UUID.
    public var currencyId: String
    public var submerchantIds: [String]
    public var labelsAny: [String]
    public var mode: String

    public init(
        name: String,
        priority: Int = 0,
        enabled: Bool? = nil,
        provider: String = "",
        minAmount: String? = nil,
        maxAmount: String? = nil,
        currencyId: String = "",
        submerchantIds: [String] = [],
        labelsAny: [String] = [],
        mode: String
    ) {
        self.name = name
        self.priority = priority
        self.enabled = enabled
        self.provider = provider
        self.minAmount = minAmount
        self.maxAmount = maxAmount
        self.currencyId = currencyId
        self.submerchantIds = submerchantIds
        self.labelsAny = labelsAny
        self.mode = mode
    }
}

public struct MarketplaceReleasePolicy: Codable, Sendable {
    public var id: String?
    public var name: String?
    public var enabled: Bool?
    public var `default`: Bool?
    public var minimumDelaySeconds: Int?
    public var explicitNotBefore: String?
    public var requiredExternalEvent: String?

    public init(
        id: String? = nil,
        name: String? = nil,
        enabled: Bool? = nil,
        default: Bool? = nil,
        minimumDelaySeconds: Int? = nil,
        explicitNotBefore: String? = nil,
        requiredExternalEvent: String? = nil
    ) {
        self.id = id
        self.name = name
        self.enabled = enabled
        self.default = `default`
        self.minimumDelaySeconds = minimumDelaySeconds
        self.explicitNotBefore = explicitNotBefore
        self.requiredExternalEvent = requiredExternalEvent
    }
}

public struct MarketplaceReleasePolicies: Codable, Sendable {
    public var rows: [MarketplaceReleasePolicy]?

    public init(rows: [MarketplaceReleasePolicy]? = nil) {
        self.rows = rows
    }
}

public struct MarketplaceReleasePolicyInput: Codable, Sendable {
    public var name: String
    public var enabled: Bool
    public var `default`: Bool
    public var minimumDelaySeconds: Int
    public var explicitNotBefore: String
    public var requiredExternalEvent: String

    public init(
        name: String,
        enabled: Bool = true,
        default: Bool = false,
        minimumDelaySeconds: Int = 0,
        explicitNotBefore: String = "",
        requiredExternalEvent: String = ""
    ) {
        self.name = name
        self.enabled = enabled
        self.default = `default`
        self.minimumDelaySeconds = minimumDelaySeconds
        self.explicitNotBefore = explicitNotBefore
        self.requiredExternalEvent = requiredExternalEvent
    }
}

public struct MarketplaceApprovalSettings: Codable, Sendable {
    public var defaultMode: String?

    public init(defaultMode: String? = nil) {
        self.defaultMode = defaultMode
    }
}
