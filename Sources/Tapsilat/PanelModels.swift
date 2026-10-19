import Foundation

/// Selects installment options for a card BIN.
public struct CardInstallmentsRequest: Sendable {
    /// The card's first digits (at least 8).
    public var bin: String
    public var amount: Double
    /// A currency unit or name, for example "TRY".
    public var currency: String
    public var isThreeD: Bool

    public init(
        bin: String,
        amount: Double,
        currency: String = "TRY",
        isThreeD: Bool = false
    ) {
        self.bin = bin
        self.amount = amount
        self.currency = currency
        self.isThreeD = isThreeD
    }
}

public struct CardInstallment: Codable, Sendable {
    public var installment: Int?
    public var amount: String?
    public var totalAmount: String?
    public var commissionRate: Double?
    public var monthlyPayment: String?

    public init(
        installment: Int? = nil,
        amount: String? = nil,
        totalAmount: String? = nil,
        commissionRate: Double? = nil,
        monthlyPayment: String? = nil
    ) {
        self.installment = installment
        self.amount = amount
        self.totalAmount = totalAmount
        self.commissionRate = commissionRate
        self.monthlyPayment = monthlyPayment
    }
}

public struct CardInstallmentsResponse: Codable, Sendable {
    public var isInstallmentAvailable: Bool?
    public var installments: [CardInstallment]?

    public init(
        isInstallmentAvailable: Bool? = nil,
        installments: [CardInstallment]? = nil
    ) {
        self.isInstallmentAvailable = isInstallmentAvailable
        self.installments = installments
    }
}

/// Selects the installment table for an amount.
public struct InstallmentTableRequest: Sendable {
    public var amount: Double
    /// A currency unit or name, for example "TRY".
    public var currency: String
    public var isThreeD: Bool

    public init(
        amount: Double,
        currency: String = "TRY",
        isThreeD: Bool = false
    ) {
        self.amount = amount
        self.currency = currency
        self.isThreeD = isThreeD
    }
}

public struct InstallmentTableRow: Codable, Sendable {
    public var installment: Int?
    public var installmentAmount: String?
    public var totalAmount: String?
    public var commissionRate: Double?
    public var isInterestFree: Bool?

    public init(
        installment: Int? = nil,
        installmentAmount: String? = nil,
        totalAmount: String? = nil,
        commissionRate: Double? = nil,
        isInterestFree: Bool? = nil
    ) {
        self.installment = installment
        self.installmentAmount = installmentAmount
        self.totalAmount = totalAmount
        self.commissionRate = commissionRate
        self.isInterestFree = isInterestFree
    }
}

public struct InstallmentTableGroup: Codable, Sendable {
    public var bank: String?
    public var program: String?
    public var programCode: String?
    public var rows: [InstallmentTableRow]?

    public init(
        bank: String? = nil,
        program: String? = nil,
        programCode: String? = nil,
        rows: [InstallmentTableRow]? = nil
    ) {
        self.bank = bank
        self.program = program
        self.programCode = programCode
        self.rows = rows
    }
}

public struct InstallmentTableResponse: Codable, Sendable {
    public var groups: [InstallmentTableGroup]?

    public init(groups: [InstallmentTableGroup]? = nil) {
        self.groups = groups
    }
}

/// Creates a submerchant. Required: `email`, `name`, `locale`, `conversationId` and `gsmNumber`.
public struct SubmerchantCreateRequest: Codable, Sendable {
    public var locale: String?
    public var conversationId: String?
    public var name: String
    public var email: String?
    public var gsmNumber: String?
    public var address: String?
    public var iban: String?
    public var taxOffice: String?
    public var legalCompanyTitle: String?
    /// A currency UUID or unit such as "TRY".
    public var currencyId: String
    public var subMerchantExternalId: String?
    public var identityNumber: String?
    /// PERSONAL (requires `identityNumber`), PRIVATE_COMPANY or LIMITED_OR_JOINT_STOCK_COMPANY
    /// (both require `taxNumber`).
    public var subMerchantType: String?
    public var taxNumber: String?
    public var subMerchantKey: String?
    public var organizationId: String?
    public var status: String?
    public var systemTime: Int?
    public var contactName: String?
    public var contactSurname: String?

    public init(
        locale: String? = nil,
        conversationId: String? = nil,
        name: String = "",
        email: String? = nil,
        gsmNumber: String? = nil,
        address: String? = nil,
        iban: String? = nil,
        taxOffice: String? = nil,
        legalCompanyTitle: String? = nil,
        currencyId: String = "",
        subMerchantExternalId: String? = nil,
        identityNumber: String? = nil,
        subMerchantType: String? = nil,
        taxNumber: String? = nil,
        subMerchantKey: String? = nil,
        organizationId: String? = nil,
        status: String? = nil,
        systemTime: Int? = nil,
        contactName: String? = nil,
        contactSurname: String? = nil
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
        self.subMerchantKey = subMerchantKey
        self.organizationId = organizationId
        self.status = status
        self.systemTime = systemTime
        self.contactName = contactName
        self.contactSurname = contactSurname
    }
}

/// Replaces a submerchant; every field is stored as sent.
public struct SubmerchantUpdateRequest: Codable, Sendable {
    public var locale: String?
    public var conversationId: String?
    public var name: String?
    public var email: String?
    public var gsmNumber: String?
    public var address: String?
    public var iban: String?
    public var taxOffice: String?
    public var legalCompanyTitle: String?
    public var currencyId: String?
    public var subMerchantExternalId: String?
    public var identityNumber: String?
    public var subMerchantType: String?
    public var taxNumber: String?
    public var subMerchantKey: String?
    public var organizationId: String?
    public var status: String?
    public var systemTime: Int?
    public var contactName: String?
    public var contactSurname: String?

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
        subMerchantKey: String? = nil,
        organizationId: String? = nil,
        status: String? = nil,
        systemTime: Int? = nil,
        contactName: String? = nil,
        contactSurname: String? = nil
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
        self.subMerchantKey = subMerchantKey
        self.organizationId = organizationId
        self.status = status
        self.systemTime = systemTime
        self.contactName = contactName
        self.contactSurname = contactSurname
    }
}

public struct Submerchant: Codable, Sendable {
    public var id: String?
    public var locale: String?
    public var conversationId: String?
    public var name: String?
    public var email: String?
    public var gsmNumber: String?
    public var address: String?
    public var iban: String?
    public var taxOffice: String?
    public var legalCompanyTitle: String?
    public var currencyId: String?
    public var subMerchantExternalId: String?
    public var identityNumber: String?
    public var subMerchantType: String?
    public var taxNumber: String?
    public var subMerchantKey: String?
    public var organizationId: String?
    public var labels: String?
    public var status: String?
    public var systemTime: Int?
    public var acquirer: String?
    public var contactName: String?
    public var contactSurname: String?

    public init(
        id: String? = nil,
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
        subMerchantKey: String? = nil,
        organizationId: String? = nil,
        labels: String? = nil,
        status: String? = nil,
        systemTime: Int? = nil,
        acquirer: String? = nil,
        contactName: String? = nil,
        contactSurname: String? = nil
    ) {
        self.id = id
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
        self.subMerchantKey = subMerchantKey
        self.organizationId = organizationId
        self.labels = labels
        self.status = status
        self.systemTime = systemTime
        self.acquirer = acquirer
        self.contactName = contactName
        self.contactSurname = contactSurname
    }
}

public struct SubmerchantListItem: Codable, Sendable {
    public var id: String?
    public var name: String?
    public var email: String?
    public var submerchantType: String?
    public var submerchantKey: String?
    public var labels: String?
    public var status: String?
    public var acquirer: String?

    public init(
        id: String? = nil,
        name: String? = nil,
        email: String? = nil,
        submerchantType: String? = nil,
        submerchantKey: String? = nil,
        labels: String? = nil,
        status: String? = nil,
        acquirer: String? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.submerchantType = submerchantType
        self.submerchantKey = submerchantKey
        self.labels = labels
        self.status = status
        self.acquirer = acquirer
    }
}

/// A page of submerchants; the rows come in the `row` key.
public struct SubmerchantListResponse: Codable, Sendable {
    public var page: Int?
    public var perPage: Int?
    public var total: Int?
    public var totalPages: Int?
    public var rows: [SubmerchantListItem]?

    enum CodingKeys: String, CodingKey {
        case page
        case perPage
        case total
        case totalPages
        case rows = "row"
    }

    public init(
        page: Int? = nil,
        perPage: Int? = nil,
        total: Int? = nil,
        totalPages: Int? = nil,
        rows: [SubmerchantListItem]? = nil
    ) {
        self.page = page
        self.perPage = perPage
        self.total = total
        self.totalPages = totalPages
        self.rows = rows
    }
}

/// Returned by submerchant create, update and delete. Read the submerchant for its key and status.
public struct SubmerchantMutationResponse: Codable, Sendable {
    public var code: Int?
    public var message: String?

    public init(code: Int? = nil, message: String? = nil) {
        self.code = code
        self.message = message
    }
}

/// Records an item business event for marketplace payouts.
public struct SubmerchantPayoutEventRequest: Codable, Sendable {
    public var idempotencyKey: String
    public var orderReference: String
    public var itemId: String
    public var eventType: String
    /// RFC3339 timestamp; the server uses the current time when it is omitted.
    public var occurredAt: String?
    public var payload: [String: JSONValue]?

    public init(
        idempotencyKey: String,
        orderReference: String,
        itemId: String,
        eventType: String,
        occurredAt: String? = nil,
        payload: [String: JSONValue]? = nil
    ) {
        self.idempotencyKey = idempotencyKey
        self.orderReference = orderReference
        self.itemId = itemId
        self.eventType = eventType
        self.occurredAt = occurredAt
        self.payload = payload
    }
}

public struct SubmerchantPayoutEventResponse: Codable, Sendable {
    public var id: String?
    public var idempotencyKey: String?
    public var orderReference: String?
    public var itemId: String?
    public var eventType: String?
    public var occurredAt: String?
    public var payload: [String: JSONValue]?

    public init(
        id: String? = nil,
        idempotencyKey: String? = nil,
        orderReference: String? = nil,
        itemId: String? = nil,
        eventType: String? = nil,
        occurredAt: String? = nil,
        payload: [String: JSONValue]? = nil
    ) {
        self.id = id
        self.idempotencyKey = idempotencyKey
        self.orderReference = orderReference
        self.itemId = itemId
        self.eventType = eventType
        self.occurredAt = occurredAt
        self.payload = payload
    }
}

/// Requests settlement approval or disapproval for an item payment.
public struct SubmerchantPaymentAction: Codable, Sendable {
    public var locale: String
    public var conversationId: String
    public var paymentTransactionId: String
    public var acquirer: String

    public init(
        locale: String,
        conversationId: String,
        paymentTransactionId: String,
        acquirer: String
    ) {
        self.locale = locale
        self.conversationId = conversationId
        self.paymentTransactionId = paymentTransactionId
        self.acquirer = acquirer
    }
}

public struct SubmerchantPaymentActionResponse: Codable, Sendable {
    public var operationId: String?
    public var status: String?
    public var locale: String?
    public var systemTime: Int?
    public var conversationId: String?
    public var paymentTransactionId: String?
    public var acquirer: String?

    public init(
        operationId: String? = nil,
        status: String? = nil,
        locale: String? = nil,
        systemTime: Int? = nil,
        conversationId: String? = nil,
        paymentTransactionId: String? = nil,
        acquirer: String? = nil
    ) {
        self.operationId = operationId
        self.status = status
        self.locale = locale
        self.systemTime = systemTime
        self.conversationId = conversationId
        self.paymentTransactionId = paymentTransactionId
        self.acquirer = acquirer
    }
}

/// Changes the seller or payout of a completed marketplace item.
public struct SubmerchantPaymentItemUpdate: Codable, Sendable {
    public var locale: String
    public var conversationId: String
    public var paymentTransactionId: String
    public var subMerchantKey: String
    /// A decimal string greater than zero.
    public var subMerchantPrice: String
    public var acquirer: String

    public init(
        locale: String,
        conversationId: String,
        paymentTransactionId: String,
        subMerchantKey: String,
        subMerchantPrice: String,
        acquirer: String
    ) {
        self.locale = locale
        self.conversationId = conversationId
        self.paymentTransactionId = paymentTransactionId
        self.subMerchantKey = subMerchantKey
        self.subMerchantPrice = subMerchantPrice
        self.acquirer = acquirer
    }
}

public struct SubmerchantPaymentItemUpdateResponse: Codable, Sendable {
    public var operationId: String?
    public var status: String?
    public var locale: String?
    public var systemTime: Int?
    public var conversationId: String?
    public var paymentTransactionId: String?

    public init(
        operationId: String? = nil,
        status: String? = nil,
        locale: String? = nil,
        systemTime: Int? = nil,
        conversationId: String? = nil,
        paymentTransactionId: String? = nil
    ) {
        self.operationId = operationId
        self.status = status
        self.locale = locale
        self.systemTime = systemTime
        self.conversationId = conversationId
        self.paymentTransactionId = paymentTransactionId
    }
}

/// Creates a VPOS, or replaces one on update. An update stores fields left unset as empty or false
/// (for example `failover` and `tls`), so read the VPOS first and send every field back.
public struct VposCreateRequest: Codable, Sendable {
    public var name: String?
    public var bankName: String?
    public var envMode: String?
    public var merchant: String?
    public var merchantCode: String?
    public var merchantKey: String?
    public var authKey: String?
    public var terminal: String?
    public var company: String?
    public var username: String?
    public var password: String?
    public var storeKey: String?
    public var apiKey: String?
    public var apiSecret: String?
    public var guid: String?
    public var pid: String?
    public var clientId: String?
    public var clientCode: String?
    public var type: String?
    public var blockDate: Int?
    public var priority: Int?
    public var main: Bool?
    public var forceThreeD: Bool?
    public var marketplace: Bool?
    public var pf: Bool?
    public var paymentMode: String?
    public var prefix: String?
    public var acquirerId: String?
    public var cardSchemes: [String]?
    /// Currency UUIDs or units such as "TRY".
    public var currencies: [String]
    public var failover: Bool?
    public var pfId: String?
    public var redirectUri: String?
    public var tls: Bool?
    public var tlsKey: String?
    public var tlsCert: String?
    public var rootCa: String?
    public var mainInstallment: Bool?
    public var mainWithoutInstallment: Bool?

    public init(
        name: String? = nil,
        bankName: String? = nil,
        envMode: String? = nil,
        merchant: String? = nil,
        merchantCode: String? = nil,
        merchantKey: String? = nil,
        authKey: String? = nil,
        terminal: String? = nil,
        company: String? = nil,
        username: String? = nil,
        password: String? = nil,
        storeKey: String? = nil,
        apiKey: String? = nil,
        apiSecret: String? = nil,
        guid: String? = nil,
        pid: String? = nil,
        clientId: String? = nil,
        clientCode: String? = nil,
        type: String? = nil,
        blockDate: Int? = nil,
        priority: Int? = nil,
        main: Bool? = nil,
        forceThreeD: Bool? = nil,
        marketplace: Bool? = nil,
        pf: Bool? = nil,
        paymentMode: String? = nil,
        prefix: String? = nil,
        acquirerId: String? = nil,
        cardSchemes: [String]? = nil,
        currencies: [String] = [],
        failover: Bool? = nil,
        pfId: String? = nil,
        redirectUri: String? = nil,
        tls: Bool? = nil,
        tlsKey: String? = nil,
        tlsCert: String? = nil,
        rootCa: String? = nil,
        mainInstallment: Bool? = nil,
        mainWithoutInstallment: Bool? = nil
    ) {
        self.name = name
        self.bankName = bankName
        self.envMode = envMode
        self.merchant = merchant
        self.merchantCode = merchantCode
        self.merchantKey = merchantKey
        self.authKey = authKey
        self.terminal = terminal
        self.company = company
        self.username = username
        self.password = password
        self.storeKey = storeKey
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.guid = guid
        self.pid = pid
        self.clientId = clientId
        self.clientCode = clientCode
        self.type = type
        self.blockDate = blockDate
        self.priority = priority
        self.main = main
        self.forceThreeD = forceThreeD
        self.marketplace = marketplace
        self.pf = pf
        self.paymentMode = paymentMode
        self.prefix = prefix
        self.acquirerId = acquirerId
        self.cardSchemes = cardSchemes
        self.currencies = currencies
        self.failover = failover
        self.pfId = pfId
        self.redirectUri = redirectUri
        self.tls = tls
        self.tlsKey = tlsKey
        self.tlsCert = tlsCert
        self.rootCa = rootCa
        self.mainInstallment = mainInstallment
        self.mainWithoutInstallment = mainWithoutInstallment
    }

    @available(*, deprecated, message: "Use init(name:...); the API names the VPOS with `name`.")
    public init(title: String?, currencies: [String]) {
        self.init(name: title, currencies: currencies)
    }

    @available(*, deprecated, renamed: "name")
    public var title: String? {
        get { name }
        set { name = newValue }
    }
}

/// Replaces a VPOS configuration; see `VposCreateRequest`.
public typealias VposUpdateRequest = VposCreateRequest

public struct Vpos: Codable, Sendable {
    public var id: String?
    public var provider: String?
    public var name: String?
    public var bankName: String?
    public var envMode: String?
    public var merchant: String?
    public var merchantCode: String?
    public var merchantKey: String?
    public var authKey: String?
    public var terminal: String?
    public var company: String?
    public var username: String?
    public var password: String?
    public var storeKey: String?
    public var apiKey: String?
    public var apiSecret: String?
    public var guid: String?
    public var pid: String?
    public var clientId: String?
    public var clientCode: String?
    public var type: String?
    public var blockDate: Int?
    public var priority: Int?
    public var main: Bool?
    public var forceThreeD: Bool?
    public var marketplace: Bool?
    public var pf: Bool?
    public var paymentMode: String?
    public var prefix: String?
    public var acquirerId: String?
    public var cardSchemes: [String]?
    public var currencies: [String]?
    public var failover: Bool?
    public var pfId: String?
    public var redirectUri: String?
    public var tls: Bool?
    public var tlsKey: String?
    public var tlsCert: String?
    public var rootCa: String?
    public var mainInstallment: Bool?
    public var mainWithoutInstallment: Bool?

    public init(
        id: String? = nil,
        provider: String? = nil,
        name: String? = nil,
        bankName: String? = nil,
        envMode: String? = nil,
        merchant: String? = nil,
        merchantCode: String? = nil,
        merchantKey: String? = nil,
        authKey: String? = nil,
        terminal: String? = nil,
        company: String? = nil,
        username: String? = nil,
        password: String? = nil,
        storeKey: String? = nil,
        apiKey: String? = nil,
        apiSecret: String? = nil,
        guid: String? = nil,
        pid: String? = nil,
        clientId: String? = nil,
        clientCode: String? = nil,
        type: String? = nil,
        blockDate: Int? = nil,
        priority: Int? = nil,
        main: Bool? = nil,
        forceThreeD: Bool? = nil,
        marketplace: Bool? = nil,
        pf: Bool? = nil,
        paymentMode: String? = nil,
        prefix: String? = nil,
        acquirerId: String? = nil,
        cardSchemes: [String]? = nil,
        currencies: [String]? = nil,
        failover: Bool? = nil,
        pfId: String? = nil,
        redirectUri: String? = nil,
        tls: Bool? = nil,
        tlsKey: String? = nil,
        tlsCert: String? = nil,
        rootCa: String? = nil,
        mainInstallment: Bool? = nil,
        mainWithoutInstallment: Bool? = nil
    ) {
        self.id = id
        self.provider = provider
        self.name = name
        self.bankName = bankName
        self.envMode = envMode
        self.merchant = merchant
        self.merchantCode = merchantCode
        self.merchantKey = merchantKey
        self.authKey = authKey
        self.terminal = terminal
        self.company = company
        self.username = username
        self.password = password
        self.storeKey = storeKey
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.guid = guid
        self.pid = pid
        self.clientId = clientId
        self.clientCode = clientCode
        self.type = type
        self.blockDate = blockDate
        self.priority = priority
        self.main = main
        self.forceThreeD = forceThreeD
        self.marketplace = marketplace
        self.pf = pf
        self.paymentMode = paymentMode
        self.prefix = prefix
        self.acquirerId = acquirerId
        self.cardSchemes = cardSchemes
        self.currencies = currencies
        self.failover = failover
        self.pfId = pfId
        self.redirectUri = redirectUri
        self.tls = tls
        self.tlsKey = tlsKey
        self.tlsCert = tlsCert
        self.rootCa = rootCa
        self.mainInstallment = mainInstallment
        self.mainWithoutInstallment = mainWithoutInstallment
    }

    @available(*, deprecated, renamed: "name")
    public var title: String? { name }
}

public struct VposListFilter: Codable, Sendable {
    public var suborganizationId: String?

    public init(suborganizationId: String? = nil) {
        self.suborganizationId = suborganizationId
    }
}

public struct VposListResponse: Codable, Sendable {
    public var page: Int?
    public var perPage: Int?
    public var total: Int?
    public var totalPages: Int?
    public var rows: [Vpos]?

    public init(
        page: Int? = nil,
        perPage: Int? = nil,
        total: Int? = nil,
        totalPages: Int? = nil,
        rows: [Vpos]? = nil
    ) {
        self.page = page
        self.perPage = perPage
        self.total = total
        self.totalPages = totalPages
        self.rows = rows
    }
}

public struct VposMutationResponse: Codable, Sendable {
    public var code: Int?
    public var message: String?

    public init(code: Int? = nil, message: String? = nil) {
        self.code = code
        self.message = message
    }
}

public struct VposAcquirer: Codable, Sendable {
    public var id: String?
    public var name: String?
    public var prefix: String?

    public init(
        id: String? = nil,
        name: String? = nil,
        prefix: String? = nil
    ) {
        self.id = id
        self.name = name
        self.prefix = prefix
    }
}

public struct VposAcquirerListResponse: Codable, Sendable {
    public var items: [VposAcquirer]?

    public init(items: [VposAcquirer]? = nil) {
        self.items = items
    }
}

public struct CardScheme: Codable, Sendable {
    public var id: String?
    public var name: String?

    public init(id: String? = nil, name: String? = nil) {
        self.id = id
        self.name = name
    }
}

public struct CardSchemeListResponse: Codable, Sendable {
    public var items: [CardScheme]?

    public init(items: [CardScheme]? = nil) {
        self.items = items
    }
}

public struct VposAcquirerTemplateDefaults: Codable, Sendable {
    public var paymentMode: String?
    public var main: Bool?
    public var marketplace: Bool?
    public var forceThreeD: Bool?
    public var credentials: [String: String]?

    public init(
        paymentMode: String? = nil,
        main: Bool? = nil,
        marketplace: Bool? = nil,
        forceThreeD: Bool? = nil,
        credentials: [String: String]? = nil
    ) {
        self.paymentMode = paymentMode
        self.main = main
        self.marketplace = marketplace
        self.forceThreeD = forceThreeD
        self.credentials = credentials
    }
}

public struct VposAcquirerTemplate: Codable, Sendable {
    public var acquirerId: String?
    public var name: String?
    public var prefix: String?
    public var requiredFields: [String]?
    public var optionalFields: [String]?
    public var defaults: VposAcquirerTemplateDefaults?

    public init(
        acquirerId: String? = nil,
        name: String? = nil,
        prefix: String? = nil,
        requiredFields: [String]? = nil,
        optionalFields: [String]? = nil,
        defaults: VposAcquirerTemplateDefaults? = nil
    ) {
        self.acquirerId = acquirerId
        self.name = name
        self.prefix = prefix
        self.requiredFields = requiredFields
        self.optionalFields = optionalFields
        self.defaults = defaults
    }
}

public struct VposAcquirerTemplateListResponse: Codable, Sendable {
    public var items: [VposAcquirerTemplate]?

    public init(items: [VposAcquirerTemplate]? = nil) {
        self.items = items
    }
}

public struct VposSubmerchantCreateRequest: Codable, Sendable {
    public var externalReferenceId: String?
    public var submerchantId: String?
    public var terminalNo: String?
    public var vposId: String?
    public var mcc: String?
    public var taxId: String?
    public var nationalId: String?
    public var title: String?
    public var switchId: String?
    public var city: String?
    public var country: String?
    public var countryIsocode: String?
    public var postalCode: String?
    public var address: String?
    public var submerchantUrl: String?
    public var submerchantNin: String?

    public init(
        externalReferenceId: String? = nil,
        submerchantId: String? = nil,
        terminalNo: String? = nil,
        vposId: String? = nil,
        mcc: String? = nil,
        taxId: String? = nil,
        nationalId: String? = nil,
        title: String? = nil,
        switchId: String? = nil,
        city: String? = nil,
        country: String? = nil,
        countryIsocode: String? = nil,
        postalCode: String? = nil,
        address: String? = nil,
        submerchantUrl: String? = nil,
        submerchantNin: String? = nil
    ) {
        self.externalReferenceId = externalReferenceId
        self.submerchantId = submerchantId
        self.terminalNo = terminalNo
        self.vposId = vposId
        self.mcc = mcc
        self.taxId = taxId
        self.nationalId = nationalId
        self.title = title
        self.switchId = switchId
        self.city = city
        self.country = country
        self.countryIsocode = countryIsocode
        self.postalCode = postalCode
        self.address = address
        self.submerchantUrl = submerchantUrl
        self.submerchantNin = submerchantNin
    }
}

public struct VposSubmerchantUpdateRequest: Codable, Sendable {
    public var externalReferenceId: String?
    public var submerchantId: String?
    public var terminalNo: String?
    public var mcc: String?
    public var taxId: String?
    public var nationalId: String?
    public var title: String?
    public var switchId: String?

    public init(
        externalReferenceId: String? = nil,
        submerchantId: String? = nil,
        terminalNo: String? = nil,
        mcc: String? = nil,
        taxId: String? = nil,
        nationalId: String? = nil,
        title: String? = nil,
        switchId: String? = nil
    ) {
        self.externalReferenceId = externalReferenceId
        self.submerchantId = submerchantId
        self.terminalNo = terminalNo
        self.mcc = mcc
        self.taxId = taxId
        self.nationalId = nationalId
        self.title = title
        self.switchId = switchId
    }
}

public struct VposSubmerchant: Codable, Sendable {
    public var id: String?
    public var externalReferenceId: String?
    public var submerchantId: String?
    public var terminalNo: String?
    public var vposId: String?
    public var mcc: String?
    public var taxId: String?
    public var nationalId: String?
    public var title: String?
    public var switchId: String?

    public init(
        id: String? = nil,
        externalReferenceId: String? = nil,
        submerchantId: String? = nil,
        terminalNo: String? = nil,
        vposId: String? = nil,
        mcc: String? = nil,
        taxId: String? = nil,
        nationalId: String? = nil,
        title: String? = nil,
        switchId: String? = nil
    ) {
        self.id = id
        self.externalReferenceId = externalReferenceId
        self.submerchantId = submerchantId
        self.terminalNo = terminalNo
        self.vposId = vposId
        self.mcc = mcc
        self.taxId = taxId
        self.nationalId = nationalId
        self.title = title
        self.switchId = switchId
    }
}

public struct VposSubmerchantListItem: Codable, Sendable {
    public var id: String?
    public var externalReferenceId: String?
    public var submerchantId: String?
    public var terminalNo: String?
    public var vposId: String?

    public init(
        id: String? = nil,
        externalReferenceId: String? = nil,
        submerchantId: String? = nil,
        terminalNo: String? = nil,
        vposId: String? = nil
    ) {
        self.id = id
        self.externalReferenceId = externalReferenceId
        self.submerchantId = submerchantId
        self.terminalNo = terminalNo
        self.vposId = vposId
    }
}

public struct VposSubmerchantListResponse: Codable, Sendable {
    public var page: Int?
    public var perPage: Int?
    public var total: Int?
    public var totalPages: Int?
    public var rows: [VposSubmerchantListItem]?

    public init(
        page: Int? = nil,
        perPage: Int? = nil,
        total: Int? = nil,
        totalPages: Int? = nil,
        rows: [VposSubmerchantListItem]? = nil
    ) {
        self.page = page
        self.perPage = perPage
        self.total = total
        self.totalPages = totalPages
        self.rows = rows
    }
}

public struct CardTokenizeRequest: Codable, Sendable {
    public var cardNumber: String
    public var holderName: String
    public var expiryMonth: String
    public var expiryYear: String
    public var cvv: String
    public var name: String?
    public var `default`: Bool?
    public var mode: Int?
    public var userId: String?
    public var userEmail: String?
    public var redirectSuccessUrl: String?
    public var redirectFailureUrl: String?

    public init(
        cardNumber: String,
        holderName: String,
        expiryMonth: String,
        expiryYear: String,
        cvv: String,
        name: String? = nil,
        default: Bool? = nil,
        mode: Int? = nil,
        userId: String? = nil,
        userEmail: String? = nil,
        redirectSuccessUrl: String? = nil,
        redirectFailureUrl: String? = nil
    ) {
        self.cardNumber = cardNumber
        self.holderName = holderName
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.cvv = cvv
        self.name = name
        self.default = `default`
        self.mode = mode
        self.userId = userId
        self.userEmail = userEmail
        self.redirectSuccessUrl = redirectSuccessUrl
        self.redirectFailureUrl = redirectFailureUrl
    }
}

/// The tokenization result, with 3D secure form details when required.
public struct CardTokenizeResponse: Codable, Sendable {
    public var threedformUrl: String?
    public var threedformHtml: String?
    public var isSuccess: Bool?
    public var message: String?
    public var statusCode: String?
    public var errorCode: String?
    public var orderReferenceId: String?
    public var cardId: String?

    public init(
        threedformUrl: String? = nil,
        threedformHtml: String? = nil,
        isSuccess: Bool? = nil,
        message: String? = nil,
        statusCode: String? = nil,
        errorCode: String? = nil,
        orderReferenceId: String? = nil,
        cardId: String? = nil
    ) {
        self.threedformUrl = threedformUrl
        self.threedformHtml = threedformHtml
        self.isSuccess = isSuccess
        self.message = message
        self.statusCode = statusCode
        self.errorCode = errorCode
        self.orderReferenceId = orderReferenceId
        self.cardId = cardId
    }
}

public struct SavedCard: Codable, Sendable {
    public var id: String?
    public var name: String?
    public var holderName: String?
    public var maskedNumber: String?
    public var lastFour: String?
    public var brand: String?
    public var bin: String?
    public var isDefault: Bool?

    public init(
        id: String? = nil,
        name: String? = nil,
        holderName: String? = nil,
        maskedNumber: String? = nil,
        lastFour: String? = nil,
        brand: String? = nil,
        bin: String? = nil,
        isDefault: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.holderName = holderName
        self.maskedNumber = maskedNumber
        self.lastFour = lastFour
        self.brand = brand
        self.bin = bin
        self.isDefault = isDefault
    }
}

public struct ListSavedCardsResponse: Codable, Sendable {
    public var page: Int?
    public var perPage: Int?
    public var total: Int?
    public var totalPages: Int?
    public var rows: [SavedCard]?

    public init(
        page: Int? = nil,
        perPage: Int? = nil,
        total: Int? = nil,
        totalPages: Int? = nil,
        rows: [SavedCard]? = nil
    ) {
        self.page = page
        self.perPage = perPage
        self.total = total
        self.totalPages = totalPages
        self.rows = rows
    }
}

public struct DeleteSavedCardResponse: Codable, Sendable {
    public var success: Bool?
    public var message: String?

    public init(success: Bool? = nil, message: String? = nil) {
        self.success = success
        self.message = message
    }
}
