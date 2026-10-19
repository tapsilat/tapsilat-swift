import Foundation

/// The order-create request. Required: `locale`, a non-zero `amount` and `currency`.
public struct Order: Codable, Sendable {
    public var locale: String?
    public var amount: Double?
    public var taxAmount: Double?
    public var currency: String?
    public var conversationId: String?
    public var buyer: OrderBuyer
    public var shippingAddress: OrderShippingAddress
    public var billingAddress: OrderBillingAddress
    public var basketItems: [OrderBasketItem]
    public var paymentFailureUrl: String?
    public var paymentSuccessUrl: String?
    public var enabledInstallments: [Int]
    public var paymentOptions: [String]
    public var submerchants: [OrderSubmerchant]?
    public var checkoutDesign: OrderCheckoutDesign?
    public var paymentMethods: Bool?
    public var redirectSuccessUrl: String?
    public var redirectFailureUrl: String?
    public var pfSubMerchant: OrderPfSubMerchant?
    public var threeDForce: Bool?
    public var metadata: [OrderMetadata]?
    /// Each term needs a `dueDate`; term dates are RFC3339 timestamps such as "2026-01-15T00:00:00Z".
    public var paymentTerms: [OrderPaymentTerm]?
    public var paidAmount: Double?
    public var externalReferenceId: String?
    public var partialPayment: Bool?
    /// "auth" (default) or "preauth".
    public var paymentMode: String?
    public var consents: [OrderConsent]?
    public var orderCards: [OrderCard]?
    public var subOrganization: OrderSubOrganization?
    public var orderVposId: String?

    public init(
        locale: String? = nil,
        amount: Double? = nil,
        taxAmount: Double? = nil,
        currency: String? = nil,
        conversationId: String? = nil,
        buyer: OrderBuyer = .init(),
        shippingAddress: OrderShippingAddress = .init(),
        billingAddress: OrderBillingAddress = .init(),
        basketItems: [OrderBasketItem] = [],
        paymentFailureUrl: String? = nil,
        paymentSuccessUrl: String? = nil,
        enabledInstallments: [Int] = [],
        paymentOptions: [String] = [],
        submerchants: [OrderSubmerchant]? = nil,
        checkoutDesign: OrderCheckoutDesign? = nil,
        paymentMethods: Bool? = nil,
        redirectSuccessUrl: String? = nil,
        redirectFailureUrl: String? = nil,
        pfSubMerchant: OrderPfSubMerchant? = nil,
        threeDForce: Bool? = nil,
        metadata: [OrderMetadata]? = nil,
        paymentTerms: [OrderPaymentTerm]? = nil,
        paidAmount: Double? = nil,
        externalReferenceId: String? = nil,
        partialPayment: Bool? = nil,
        paymentMode: String? = nil,
        consents: [OrderConsent]? = nil,
        orderCards: [OrderCard]? = nil,
        subOrganization: OrderSubOrganization? = nil,
        orderVposId: String? = nil
    ) {
        self.locale = locale
        self.amount = amount
        self.taxAmount = taxAmount
        self.currency = currency
        self.conversationId = conversationId
        self.buyer = buyer
        self.shippingAddress = shippingAddress
        self.billingAddress = billingAddress
        self.basketItems = basketItems
        self.paymentFailureUrl = paymentFailureUrl
        self.paymentSuccessUrl = paymentSuccessUrl
        self.enabledInstallments = enabledInstallments
        self.paymentOptions = paymentOptions
        self.submerchants = submerchants
        self.checkoutDesign = checkoutDesign
        self.paymentMethods = paymentMethods
        self.redirectSuccessUrl = redirectSuccessUrl
        self.redirectFailureUrl = redirectFailureUrl
        self.pfSubMerchant = pfSubMerchant
        self.threeDForce = threeDForce
        self.metadata = metadata
        self.paymentTerms = paymentTerms
        self.paidAmount = paidAmount
        self.externalReferenceId = externalReferenceId
        self.partialPayment = partialPayment
        self.paymentMode = paymentMode
        self.consents = consents
        self.orderCards = orderCards
        self.subOrganization = subOrganization
        self.orderVposId = orderVposId
    }
}

public struct OrderBuyer: Codable, Sendable {
    public var id: String?
    public var name: String?
    public var surname: String?
    public var email: String?
    public var gsmNumber: String?
    public var identityNumber: String?
    public var registrationDate: String?
    public var registrationAddress: String?
    public var lastLoginDate: String?
    public var city: String?
    public var country: String?
    public var zipCode: String?
    public var ip: String?
    /// Birth date in YYYY-MM-DD format.
    public var birthDate: String?
    public var title: String?
    public var incomeType: String?
    public var education: String?
    public var occupation: String?

    public init(
        id: String? = nil,
        name: String? = nil,
        surname: String? = nil,
        email: String? = nil,
        gsmNumber: String? = nil,
        identityNumber: String? = nil,
        registrationDate: String? = nil,
        registrationAddress: String? = nil,
        lastLoginDate: String? = nil,
        city: String? = nil,
        country: String? = nil,
        zipCode: String? = nil,
        ip: String? = nil,
        birthDate: String? = nil,
        title: String? = nil,
        incomeType: String? = nil,
        education: String? = nil,
        occupation: String? = nil
    ) {
        self.id = id
        self.name = name
        self.surname = surname
        self.email = email
        self.gsmNumber = gsmNumber
        self.identityNumber = identityNumber
        self.registrationDate = registrationDate
        self.registrationAddress = registrationAddress
        self.lastLoginDate = lastLoginDate
        self.city = city
        self.country = country
        self.zipCode = zipCode
        self.ip = ip
        self.birthDate = birthDate
        self.title = title
        self.incomeType = incomeType
        self.education = education
        self.occupation = occupation
    }
}

public struct OrderShippingAddress: Codable, Sendable {
    public var address: String?
    public var zipCode: String?
    public var city: String?
    public var country: String?
    public var contactName: String?
    public var trackingCode: String?
    public var shippingDate: String?

    public init(
        address: String? = nil,
        zipCode: String? = nil,
        city: String? = nil,
        country: String? = nil,
        contactName: String? = nil,
        trackingCode: String? = nil,
        shippingDate: String? = nil
    ) {
        self.address = address
        self.zipCode = zipCode
        self.city = city
        self.country = country
        self.contactName = contactName
        self.trackingCode = trackingCode
        self.shippingDate = shippingDate
    }
}

public struct OrderBillingAddress: Codable, Sendable {
    public var address: String?
    public var zipCode: String?
    public var city: String?
    public var country: String?
    public var contactName: String?
    public var billingType: String?
    public var citizenship: String?
    public var title: String?
    public var taxOffice: String?
    public var district: String?
    public var contactPhone: String?
    public var vatNumber: String?
    public var neighbourhood: String?
    public var street1: String?
    public var street2: String?
    public var street3: String?

    public init(
        address: String? = nil,
        zipCode: String? = nil,
        city: String? = nil,
        country: String? = nil,
        contactName: String? = nil,
        billingType: String? = nil,
        citizenship: String? = nil,
        title: String? = nil,
        taxOffice: String? = nil,
        district: String? = nil,
        contactPhone: String? = nil,
        vatNumber: String? = nil,
        neighbourhood: String? = nil,
        street1: String? = nil,
        street2: String? = nil,
        street3: String? = nil
    ) {
        self.address = address
        self.zipCode = zipCode
        self.city = city
        self.country = country
        self.contactName = contactName
        self.billingType = billingType
        self.citizenship = citizenship
        self.title = title
        self.taxOffice = taxOffice
        self.district = district
        self.contactPhone = contactPhone
        self.vatNumber = vatNumber
        self.neighbourhood = neighbourhood
        self.street1 = street1
        self.street2 = street2
        self.street3 = street3
    }
}

public struct OrderBasketItem: Codable, Sendable {
    public var id: String?
    public var price: Double?
    public var name: String?
    public var category1: String?
    public var category2: String?
    public var itemType: String?
    public var quantity: Int?
    public var quantityFloat: Double?
    public var quantityUnit: String?
    public var data: String?
    public var commissionAmount: Double?
    public var subMerchantKey: String?
    public var subMerchantPrice: String?
    /// The earliest time the item's payout may be released (RFC3339).
    public var payoutReleaseAt: String?
    public var payer: OrderBasketItemPayer?
    /// The item's merchant category code.
    public var mcc: String?
    public var coupon: String?
    public var couponDiscount: Double?
    public var paidAmount: Double?
    /// Response only.
    public var status: Int?
    /// Response only.
    public var refundedAmount: Double?
    /// Response only.
    public var refundableAmount: Double?
    /// Response only.
    public var paidableAmount: Double?
    /// Response only.
    public var itemPayments: [OrderItemPayment]?

    public init(
        id: String? = nil,
        price: Double? = nil,
        name: String? = nil,
        category1: String? = nil,
        category2: String? = nil,
        itemType: String? = nil,
        quantity: Int? = nil,
        quantityFloat: Double? = nil,
        quantityUnit: String? = nil,
        data: String? = nil,
        commissionAmount: Double? = nil,
        subMerchantKey: String? = nil,
        subMerchantPrice: String? = nil,
        payoutReleaseAt: String? = nil,
        payer: OrderBasketItemPayer? = nil,
        mcc: String? = nil,
        coupon: String? = nil,
        couponDiscount: Double? = nil,
        paidAmount: Double? = nil,
        status: Int? = nil,
        refundedAmount: Double? = nil,
        refundableAmount: Double? = nil,
        paidableAmount: Double? = nil,
        itemPayments: [OrderItemPayment]? = nil
    ) {
        self.id = id
        self.price = price
        self.name = name
        self.category1 = category1
        self.category2 = category2
        self.itemType = itemType
        self.quantity = quantity
        self.quantityFloat = quantityFloat
        self.quantityUnit = quantityUnit
        self.data = data
        self.commissionAmount = commissionAmount
        self.subMerchantKey = subMerchantKey
        self.subMerchantPrice = subMerchantPrice
        self.payoutReleaseAt = payoutReleaseAt
        self.payer = payer
        self.mcc = mcc
        self.coupon = coupon
        self.couponDiscount = couponDiscount
        self.paidAmount = paidAmount
        self.status = status
        self.refundedAmount = refundedAmount
        self.refundableAmount = refundableAmount
        self.paidableAmount = paidableAmount
        self.itemPayments = itemPayments
    }
}

public struct OrderBasketItemPayer: Codable, Sendable {
    public var address: String?
    public var referenceId: String?
    public var taxOffice: String?
    public var title: String?
    public var type: String?
    public var vat: String?
    public var name: String?
    public var surname: String?
    public var identityNumber: String?
    public var email: String?
    public var phone: String?

    public init(
        address: String? = nil,
        referenceId: String? = nil,
        taxOffice: String? = nil,
        title: String? = nil,
        type: String? = nil,
        vat: String? = nil,
        name: String? = nil,
        surname: String? = nil,
        identityNumber: String? = nil,
        email: String? = nil,
        phone: String? = nil
    ) {
        self.address = address
        self.referenceId = referenceId
        self.taxOffice = taxOffice
        self.title = title
        self.type = type
        self.vat = vat
        self.name = name
        self.surname = surname
        self.identityNumber = identityNumber
        self.email = email
        self.phone = phone
    }
}

public struct OrderSubmerchant: Codable, Sendable {
    public var amount: Double?
    public var orderBasketItemId: String?
    public var merchantReferenceId: String?

    public init(
        amount: Double? = nil,
        orderBasketItemId: String? = nil,
        merchantReferenceId: String? = nil
    ) {
        self.amount = amount
        self.orderBasketItemId = orderBasketItemId
        self.merchantReferenceId = merchantReferenceId
    }
}

/// Customizes the checkout page branding for one order.
public struct OrderCheckoutDesign: Codable, Sendable {
    public var logo: String?
    public var inputBackgroundColor: String?
    public var payButtonColor: String?
    public var inputTextColor: String?
    public var labelTextColor: String?
    public var leftBackgroundColor: String?
    public var rightBackgroundColor: String?
    public var textColor: String?
    public var placeholderColor: String?
    public var payButtonTextColor: String?
    public var pageBackgroundColor: String?
    public var borderColor: String?
    public var inputBorderColor: String?
    public var accentColor: String?
    public var textMutedColor: String?
    public var surfaceMutedColor: String?
    public var darkModeEnabled: Bool?
    /// Colors used in dark mode, keyed by the light-mode field's JSON name.
    public var darkColors: [String: String]?
    /// Deprecated: checkout no longer renders custom order detail HTML; the value is ignored.
    public var orderDetailHtml: String?
    /// Deprecated: checkout design no longer carries a redirect URL; the value is ignored.
    /// Use the order's `redirectSuccessUrl` and `redirectFailureUrl`.
    public var redirectUrl: String?

    public init(
        logo: String? = nil,
        inputBackgroundColor: String? = nil,
        payButtonColor: String? = nil,
        inputTextColor: String? = nil,
        labelTextColor: String? = nil,
        leftBackgroundColor: String? = nil,
        rightBackgroundColor: String? = nil,
        textColor: String? = nil,
        placeholderColor: String? = nil,
        payButtonTextColor: String? = nil,
        pageBackgroundColor: String? = nil,
        borderColor: String? = nil,
        inputBorderColor: String? = nil,
        accentColor: String? = nil,
        textMutedColor: String? = nil,
        surfaceMutedColor: String? = nil,
        darkModeEnabled: Bool? = nil,
        darkColors: [String: String]? = nil,
        orderDetailHtml: String? = nil,
        redirectUrl: String? = nil
    ) {
        self.logo = logo
        self.inputBackgroundColor = inputBackgroundColor
        self.payButtonColor = payButtonColor
        self.inputTextColor = inputTextColor
        self.labelTextColor = labelTextColor
        self.leftBackgroundColor = leftBackgroundColor
        self.rightBackgroundColor = rightBackgroundColor
        self.textColor = textColor
        self.placeholderColor = placeholderColor
        self.payButtonTextColor = payButtonTextColor
        self.pageBackgroundColor = pageBackgroundColor
        self.borderColor = borderColor
        self.inputBorderColor = inputBorderColor
        self.accentColor = accentColor
        self.textMutedColor = textMutedColor
        self.surfaceMutedColor = surfaceMutedColor
        self.darkModeEnabled = darkModeEnabled
        self.darkColors = darkColors
        self.orderDetailHtml = orderDetailHtml
        self.redirectUrl = redirectUrl
    }
}

public struct OrderPfSubMerchant: Codable, Sendable {
    public var address: String?
    public var city: String?
    public var country: String?
    public var countryIsoCode: String?
    public var id: String?
    public var mcc: String?
    public var name: String?
    public var orgId: String?
    public var postalCode: String?
    public var terminalNo: String?
    public var submerchantNin: String?
    public var submerchantUrl: String?
    public var switchId: String?
    public var nationalId: String?

    public init(
        address: String? = nil,
        city: String? = nil,
        country: String? = nil,
        countryIsoCode: String? = nil,
        id: String? = nil,
        mcc: String? = nil,
        name: String? = nil,
        orgId: String? = nil,
        postalCode: String? = nil,
        terminalNo: String? = nil,
        submerchantNin: String? = nil,
        submerchantUrl: String? = nil,
        switchId: String? = nil,
        nationalId: String? = nil
    ) {
        self.address = address
        self.city = city
        self.country = country
        self.countryIsoCode = countryIsoCode
        self.id = id
        self.mcc = mcc
        self.name = name
        self.orgId = orgId
        self.postalCode = postalCode
        self.terminalNo = terminalNo
        self.submerchantNin = submerchantNin
        self.submerchantUrl = submerchantUrl
        self.switchId = switchId
        self.nationalId = nationalId
    }
}

public struct OrderMetadata: Codable, Sendable {
    public var key: String?
    public var value: String?

    public init(key: String? = nil, value: String? = nil) {
        self.key = key
        self.value = value
    }
}

/// A payment term sent with the order. `dueDate` is required and, like `paidDate`, must be an
/// RFC3339 timestamp such as "2026-01-15T00:00:00Z".
public struct OrderPaymentTerm: Codable, Sendable {
    public var amount: Double?
    public var data: String?
    public var dueDate: String?
    public var paidDate: String?
    public var required: Bool?
    public var status: String?
    public var termReferenceId: String?
    public var termSequence: Int?

    public init(
        amount: Double? = nil,
        data: String? = nil,
        dueDate: String? = nil,
        paidDate: String? = nil,
        required: Bool? = nil,
        status: String? = nil,
        termReferenceId: String? = nil,
        termSequence: Int? = nil
    ) {
        self.amount = amount
        self.data = data
        self.dueDate = dueDate
        self.paidDate = paidDate
        self.required = required
        self.status = status
        self.termReferenceId = termReferenceId
        self.termSequence = termSequence
    }
}

/// A consent text the buyer must accept on the checkout page.
public struct OrderConsent: Codable, Sendable {
    public var title: String?
    public var url: String?

    public init(title: String? = nil, url: String? = nil) {
        self.title = title
        self.url = url
    }
}

/// Selects a saved card for the order.
public struct OrderCard: Codable, Sendable {
    public var cardId: String
    public var cardSequence: Int?

    public init(cardId: String, cardSequence: Int? = nil) {
        self.cardId = cardId
        self.cardSequence = cardSequence
    }
}

public struct OrderSubOrganization: Codable, Sendable {
    public var organizationName: String?
    public var email: String?
    public var iban: String?
    public var address: String?
    public var currency: String?
    public var acquirer: String?
    public var taxOffice: String?
    public var taxNumber: String?
    public var gsmNumber: String?
    public var contactFirstName: String?
    public var contactLastName: String?
    public var identityNumber: String?
    public var legalCompanyTitle: String?
    public var subMerchantKey: String?
    public var subMerchantType: String?
    public var subMerchantExternalId: String?

    public init(
        organizationName: String? = nil,
        email: String? = nil,
        iban: String? = nil,
        address: String? = nil,
        currency: String? = nil,
        acquirer: String? = nil,
        taxOffice: String? = nil,
        taxNumber: String? = nil,
        gsmNumber: String? = nil,
        contactFirstName: String? = nil,
        contactLastName: String? = nil,
        identityNumber: String? = nil,
        legalCompanyTitle: String? = nil,
        subMerchantKey: String? = nil,
        subMerchantType: String? = nil,
        subMerchantExternalId: String? = nil
    ) {
        self.organizationName = organizationName
        self.email = email
        self.iban = iban
        self.address = address
        self.currency = currency
        self.acquirer = acquirer
        self.taxOffice = taxOffice
        self.taxNumber = taxNumber
        self.gsmNumber = gsmNumber
        self.contactFirstName = contactFirstName
        self.contactLastName = contactLastName
        self.identityNumber = identityNumber
        self.legalCompanyTitle = legalCompanyTitle
        self.subMerchantKey = subMerchantKey
        self.subMerchantType = subMerchantType
        self.subMerchantExternalId = subMerchantExternalId
    }
}

public struct OrderResponse: Codable, Sendable {
    public var orderId: String?
    public var referenceId: String?
    public var checkoutUrl: String?
    public var error: String?

    public init(
        orderId: String? = nil,
        referenceId: String? = nil,
        checkoutUrl: String? = nil,
        error: String? = nil
    ) {
        self.orderId = orderId
        self.referenceId = referenceId
        self.checkoutUrl = checkoutUrl
        self.error = error
    }
}

/// An order as returned by the order detail endpoints. Every field is optional because the
/// server omits empty values.
public struct OrderDetail: Codable, Sendable {
    public var locale: String?
    public var error: String?
    public var code: Int?
    public var referenceId: String?
    public var amount: String?
    public var total: String?
    public var paidAmount: String?
    public var refundedAmount: String?
    public var customerPaidAmount: Double?
    public var createdAt: String?
    public var currency: String?
    public var status: Int?
    public var statusEnum: String?
    public var buyer: OrderBuyer?
    public var shippingAddress: OrderShippingAddress?
    public var billingAddress: OrderBillingAddress?
    public var checkoutDesign: OrderCheckoutDesign?
    public var basketItems: [OrderBasketItem]?
    public var paymentTerms: [OrderPaymentTermDetail]?
    public var paymentRequests: [OrderPaymentRequest]?
    public var refundCancelRequests: [OrderRefundCancelRequest]?
    public var metadata: [OrderMetadata]?
    public var paymentFailureUrl: String?
    public var paymentSuccessUrl: String?
    public var redirectSuccessUrl: String?
    public var redirectFailureUrl: String?
    public var checkoutUrl: String?
    public var conversationId: String?
    public var externalReferenceId: String?
    public var paymentOptions: [String]?

    public init(
        locale: String? = nil,
        error: String? = nil,
        code: Int? = nil,
        referenceId: String? = nil,
        amount: String? = nil,
        total: String? = nil,
        paidAmount: String? = nil,
        refundedAmount: String? = nil,
        customerPaidAmount: Double? = nil,
        createdAt: String? = nil,
        currency: String? = nil,
        status: Int? = nil,
        statusEnum: String? = nil,
        buyer: OrderBuyer? = nil,
        shippingAddress: OrderShippingAddress? = nil,
        billingAddress: OrderBillingAddress? = nil,
        checkoutDesign: OrderCheckoutDesign? = nil,
        basketItems: [OrderBasketItem]? = nil,
        paymentTerms: [OrderPaymentTermDetail]? = nil,
        paymentRequests: [OrderPaymentRequest]? = nil,
        refundCancelRequests: [OrderRefundCancelRequest]? = nil,
        metadata: [OrderMetadata]? = nil,
        paymentFailureUrl: String? = nil,
        paymentSuccessUrl: String? = nil,
        redirectSuccessUrl: String? = nil,
        redirectFailureUrl: String? = nil,
        checkoutUrl: String? = nil,
        conversationId: String? = nil,
        externalReferenceId: String? = nil,
        paymentOptions: [String]? = nil
    ) {
        self.locale = locale
        self.error = error
        self.code = code
        self.referenceId = referenceId
        self.amount = amount
        self.total = total
        self.paidAmount = paidAmount
        self.refundedAmount = refundedAmount
        self.customerPaidAmount = customerPaidAmount
        self.createdAt = createdAt
        self.currency = currency
        self.status = status
        self.statusEnum = statusEnum
        self.buyer = buyer
        self.shippingAddress = shippingAddress
        self.billingAddress = billingAddress
        self.checkoutDesign = checkoutDesign
        self.basketItems = basketItems
        self.paymentTerms = paymentTerms
        self.paymentRequests = paymentRequests
        self.refundCancelRequests = refundCancelRequests
        self.metadata = metadata
        self.paymentFailureUrl = paymentFailureUrl
        self.paymentSuccessUrl = paymentSuccessUrl
        self.redirectSuccessUrl = redirectSuccessUrl
        self.redirectFailureUrl = redirectFailureUrl
        self.checkoutUrl = checkoutUrl
        self.conversationId = conversationId
        self.externalReferenceId = externalReferenceId
        self.paymentOptions = paymentOptions
    }
}

/// A payment term as returned in the order detail.
public struct OrderPaymentTermDetail: Codable, Sendable {
    public var id: String?
    public var hashId: String?
    public var termSequence: Int?
    public var required: Bool?
    public var dueDate: String?
    public var paidDate: String?
    public var amount: Double?
    public var termReferenceId: String?
    public var status: String?
    public var payments: [OrderItemPayment]?
    public var data: String?

    public init(
        id: String? = nil,
        hashId: String? = nil,
        termSequence: Int? = nil,
        required: Bool? = nil,
        dueDate: String? = nil,
        paidDate: String? = nil,
        amount: Double? = nil,
        termReferenceId: String? = nil,
        status: String? = nil,
        payments: [OrderItemPayment]? = nil,
        data: String? = nil
    ) {
        self.id = id
        self.hashId = hashId
        self.termSequence = termSequence
        self.required = required
        self.dueDate = dueDate
        self.paidDate = paidDate
        self.amount = amount
        self.termReferenceId = termReferenceId
        self.status = status
        self.payments = payments
        self.data = data
    }
}

public struct OrderItemPayment: Codable, Sendable {
    public var id: String?
    public var amount: Double?
    public var paidDate: String?
    public var maskedBin: String?
    public var cardBrand: String?
    public var refundedAmount: Double?
    public var refundableAmount: Double?
    public var refundedDate: String?
    public var refunded: Bool?
    public var status: Int?
    public var type: String?

    public init(
        id: String? = nil,
        amount: Double? = nil,
        paidDate: String? = nil,
        maskedBin: String? = nil,
        cardBrand: String? = nil,
        refundedAmount: Double? = nil,
        refundableAmount: Double? = nil,
        refundedDate: String? = nil,
        refunded: Bool? = nil,
        status: Int? = nil,
        type: String? = nil
    ) {
        self.id = id
        self.amount = amount
        self.paidDate = paidDate
        self.maskedBin = maskedBin
        self.cardBrand = cardBrand
        self.refundedAmount = refundedAmount
        self.refundableAmount = refundableAmount
        self.refundedDate = refundedDate
        self.refunded = refunded
        self.status = status
        self.type = type
    }
}

/// A payment attempt recorded on an order.
public struct OrderPaymentRequest: Codable, Sendable {
    public var id: String?
    public var date: String?
    public var paymentMode: String?
    public var amount: String?
    public var cardHash: String?
    public var maskedCard: String?
    public var paid: Bool?
    public var type: String?

    public init(
        id: String? = nil,
        date: String? = nil,
        paymentMode: String? = nil,
        amount: String? = nil,
        cardHash: String? = nil,
        maskedCard: String? = nil,
        paid: Bool? = nil,
        type: String? = nil
    ) {
        self.id = id
        self.date = date
        self.paymentMode = paymentMode
        self.amount = amount
        self.cardHash = cardHash
        self.maskedCard = maskedCard
        self.paid = paid
        self.type = type
    }
}

/// A refund or cancellation request recorded on an order.
public struct OrderRefundCancelRequest: Codable, Sendable {
    public var id: String?
    public var amount: String?
    public var status: Int?
    public var reason: String?
    public var type: Int?
    public var termId: String?
    public var itemId: String?
    public var createdAt: String?

    public init(
        id: String? = nil,
        amount: String? = nil,
        status: Int? = nil,
        reason: String? = nil,
        type: Int? = nil,
        termId: String? = nil,
        itemId: String? = nil,
        createdAt: String? = nil
    ) {
        self.id = id
        self.amount = amount
        self.status = status
        self.reason = reason
        self.type = type
        self.termId = termId
        self.itemId = itemId
        self.createdAt = createdAt
    }
}

public struct OrderStatus: Codable, Sendable {
    public var status: String?
    public var error: String?

    public init(status: String? = nil, error: String? = nil) {
        self.status = status
        self.error = error
    }
}

public struct RefundOrder: Codable, Sendable {
    public var referenceId: String
    public var amount: Double?
    /// Limits the refund to one basket item.
    public var orderItemId: String?
    /// Limits the refund to one item payment.
    public var orderItemPaymentId: String?

    public init(
        referenceId: String,
        amount: Double? = nil,
        orderItemId: String? = nil,
        orderItemPaymentId: String? = nil
    ) {
        self.referenceId = referenceId
        self.amount = amount
        self.orderItemId = orderItemId
        self.orderItemPaymentId = orderItemPaymentId
    }
}

public struct CancelOrder: Codable, Sendable {
    public var referenceId: String

    public init(referenceId: String) {
        self.referenceId = referenceId
    }
}

public struct RefundCancelOrderResponse: Codable, Sendable {
    public var status: String?
    public var message: String?
    public var isSuccess: Bool?
    public var error: String?

    public init(
        status: String? = nil,
        message: String? = nil,
        isSuccess: Bool? = nil,
        error: String? = nil
    ) {
        self.status = status
        self.message = message
        self.isSuccess = isSuccess
        self.error = error
    }
}

public struct PaginatedData: Codable, Sendable {
    public var page: Int?
    public var perPage: Int?
    public var total: Int?
    public var totalPages: Int?
    public var rows: JSONValue?
    public var error: String?

    public init(
        page: Int? = nil,
        perPage: Int? = nil,
        total: Int? = nil,
        totalPages: Int? = nil,
        rows: JSONValue? = nil,
        error: String? = nil
    ) {
        self.page = page
        self.perPage = perPage
        self.total = total
        self.totalPages = totalPages
        self.rows = rows
        self.error = error
    }
}

/// Selects orders for `OrderService.getOrderList(filter:)`. The server allows at most 100 orders per page.
public struct OrderListFilter: Sendable {
    public var page: Int
    public var perPage: Int
    public var startDate: String?
    public var endDate: String?
    public var organizationId: String?
    public var conversationId: String?
    public var relatedReferenceId: String?
    public var buyerId: String?
    /// Numeric order status.
    public var status: Int?

    public init(
        page: Int = 1,
        perPage: Int = 10,
        startDate: String? = nil,
        endDate: String? = nil,
        organizationId: String? = nil,
        conversationId: String? = nil,
        relatedReferenceId: String? = nil,
        buyerId: String? = nil,
        status: Int? = nil
    ) {
        self.page = page
        self.perPage = perPage
        self.startDate = startDate
        self.endDate = endDate
        self.organizationId = organizationId
        self.conversationId = conversationId
        self.relatedReferenceId = relatedReferenceId
        self.buyerId = buyerId
        self.status = status
    }
}

public struct OrderSubmerchantListItem: Codable, Sendable {
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

/// A page of order submerchants; the rows come in the `row` key.
public struct OrderSubmerchantListResponse: Codable, Sendable {
    public var page: Int?
    public var perPage: Int?
    public var total: Int?
    public var totalPages: Int?
    public var rows: [OrderSubmerchantListItem]?

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
        rows: [OrderSubmerchantListItem]? = nil
    ) {
        self.page = page
        self.perPage = perPage
        self.total = total
        self.totalPages = totalPages
        self.rows = rows
    }
}

/// Selects the order whose payments to list; set at least one identifier.
public struct GetOrderPaymentsRequest: Codable, Sendable {
    public var orderId: String?
    public var orderReferenceId: String?
    public var conversationId: String?

    public init(
        orderId: String? = nil,
        orderReferenceId: String? = nil,
        conversationId: String? = nil
    ) {
        self.orderId = orderId
        self.orderReferenceId = orderReferenceId
        self.conversationId = conversationId
    }
}

public struct OrderPayment: Codable, Sendable {
    public var id: String?
    public var date: String?
    public var paymentMode: String?
    public var amount: Double?
    public var cardId: String?
    public var maskedCard: String?
    public var cardHolderName: String?
    public var cardType: String?
    public var cardBrand: String?
    public var cardBank: String?
    public var cardNetwork: String?
    public var paid: Bool?
    public var type: String?
    public var acquirerResponse: String?
    public var vposCommissionAmount: Double?
    public var vposCommissionRate: Double?
    public var vposCommissionFeeType: String?
    public var organizationCommissionAmount: Double?
    public var organizationCommissionRate: Double?
    public var organizationCommissionFeeType: String?
    public var totalAmount: Double?
    public var acquirerCommissionAmount: Double?
    public var acquirerCommissionRate: Double?
    public var acquirerCommissionFeeType: String?
    public var acquirerName: String?
    public var customerPaidCommissionAmount: Double?
    public var merchantPaidCommissionAmount: Double?
    public var merchantNetAmount: Double?

    public init(
        id: String? = nil,
        date: String? = nil,
        paymentMode: String? = nil,
        amount: Double? = nil,
        cardId: String? = nil,
        maskedCard: String? = nil,
        cardHolderName: String? = nil,
        cardType: String? = nil,
        cardBrand: String? = nil,
        cardBank: String? = nil,
        cardNetwork: String? = nil,
        paid: Bool? = nil,
        type: String? = nil,
        acquirerResponse: String? = nil,
        vposCommissionAmount: Double? = nil,
        vposCommissionRate: Double? = nil,
        vposCommissionFeeType: String? = nil,
        organizationCommissionAmount: Double? = nil,
        organizationCommissionRate: Double? = nil,
        organizationCommissionFeeType: String? = nil,
        totalAmount: Double? = nil,
        acquirerCommissionAmount: Double? = nil,
        acquirerCommissionRate: Double? = nil,
        acquirerCommissionFeeType: String? = nil,
        acquirerName: String? = nil,
        customerPaidCommissionAmount: Double? = nil,
        merchantPaidCommissionAmount: Double? = nil,
        merchantNetAmount: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.paymentMode = paymentMode
        self.amount = amount
        self.cardId = cardId
        self.maskedCard = maskedCard
        self.cardHolderName = cardHolderName
        self.cardType = cardType
        self.cardBrand = cardBrand
        self.cardBank = cardBank
        self.cardNetwork = cardNetwork
        self.paid = paid
        self.type = type
        self.acquirerResponse = acquirerResponse
        self.vposCommissionAmount = vposCommissionAmount
        self.vposCommissionRate = vposCommissionRate
        self.vposCommissionFeeType = vposCommissionFeeType
        self.organizationCommissionAmount = organizationCommissionAmount
        self.organizationCommissionRate = organizationCommissionRate
        self.organizationCommissionFeeType = organizationCommissionFeeType
        self.totalAmount = totalAmount
        self.acquirerCommissionAmount = acquirerCommissionAmount
        self.acquirerCommissionRate = acquirerCommissionRate
        self.acquirerCommissionFeeType = acquirerCommissionFeeType
        self.acquirerName = acquirerName
        self.customerPaidCommissionAmount = customerPaidCommissionAmount
        self.merchantPaidCommissionAmount = merchantPaidCommissionAmount
        self.merchantNetAmount = merchantNetAmount
    }
}

public struct GetOrderPaymentsResponse: Codable, Sendable {
    public var payments: [OrderPayment]?
    public var totalAmount: Double?
    public var totalCustomerPaidCommissionAmount: Double?
    public var totalMerchantPaidCommissionAmount: Double?
    public var totalMerchantNetAmount: Double?
    public var orderAmount: Double?

    public init(
        payments: [OrderPayment]? = nil,
        totalAmount: Double? = nil,
        totalCustomerPaidCommissionAmount: Double? = nil,
        totalMerchantPaidCommissionAmount: Double? = nil,
        totalMerchantNetAmount: Double? = nil,
        orderAmount: Double? = nil
    ) {
        self.payments = payments
        self.totalAmount = totalAmount
        self.totalCustomerPaidCommissionAmount = totalCustomerPaidCommissionAmount
        self.totalMerchantPaidCommissionAmount = totalMerchantPaidCommissionAmount
        self.totalMerchantNetAmount = totalMerchantNetAmount
        self.orderAmount = orderAmount
    }
}

/// Charges an order, for example with its saved card.
public struct OrderChargeRequest: Codable, Sendable {
    public var orderReferenceId: String
    public var retry: Bool?

    public init(orderReferenceId: String, retry: Bool? = nil) {
        self.orderReferenceId = orderReferenceId
        self.retry = retry
    }
}

/// The charge result. The server sends these keys in camelCase, unlike most responses.
public struct OrderChargeResponse: Codable, Sendable {
    public var isSuccess: Bool?
    public var message: String?
    public var statusCode: String?
    public var errorCode: String?

    public init(
        isSuccess: Bool? = nil,
        message: String? = nil,
        statusCode: String? = nil,
        errorCode: String? = nil
    ) {
        self.isSuccess = isSuccess
        self.message = message
        self.statusCode = statusCode
        self.errorCode = errorCode
    }
}

/// Adds a payment term to an existing order. Dates use the YYYY-MM-DD format.
public struct OrderTermCreateRequest: Codable, Sendable {
    /// The order's ID (`OrderResponse.orderId`), not its reference ID.
    public var orderId: String
    public var termSequence: Int?
    public var required: Bool
    public var amount: Double
    public var dueDate: String
    public var paidDate: String?
    public var termReferenceId: String?
    public var status: String?
    public var data: String?

    public init(
        orderId: String,
        termSequence: Int? = nil,
        required: Bool = false,
        amount: Double,
        dueDate: String,
        paidDate: String? = nil,
        termReferenceId: String? = nil,
        status: String? = nil,
        data: String? = nil
    ) {
        self.orderId = orderId
        self.termSequence = termSequence
        self.required = required
        self.amount = amount
        self.dueDate = dueDate
        self.paidDate = paidDate
        self.termReferenceId = termReferenceId
        self.status = status
        self.data = data
    }
}

/// Replaces a payment term. The server stores every field as sent, so populate all of them.
/// Dates use the YYYY-MM-DD format.
public struct OrderTermUpdateRequest: Codable, Sendable {
    public var termReferenceId: String
    public var termSequence: Int?
    public var required: Bool?
    public var amount: Double?
    public var dueDate: String?
    public var paidDate: String?
    public var status: String?

    public init(
        termReferenceId: String,
        termSequence: Int? = nil,
        required: Bool? = nil,
        amount: Double? = nil,
        dueDate: String? = nil,
        paidDate: String? = nil,
        status: String? = nil
    ) {
        self.termReferenceId = termReferenceId
        self.termSequence = termSequence
        self.required = required
        self.amount = amount
        self.dueDate = dueDate
        self.paidDate = paidDate
        self.status = status
    }
}

/// Refunds a payment made against a payment term.
public struct OrderTermRefundRequest: Codable, Sendable {
    /// The order's reference ID.
    public var referenceId: String
    /// The payment term's ID (`OrderPaymentTermDetail.id`).
    public var termId: String
    public var termPaymentId: String?
    public var amount: Double

    public init(
        referenceId: String,
        termId: String,
        termPaymentId: String? = nil,
        amount: Double
    ) {
        self.referenceId = referenceId
        self.termId = termId
        self.termPaymentId = termPaymentId
        self.amount = amount
    }
}

public struct OrganizationSettings: Codable, Sendable {
    public var ttl: Int?
    public var retryCount: Int?
    public var allowPayment: Bool?
    public var sessionTtl: Int?
    public var customCheckout: Bool?
    public var domainAddress: String?
    public var checkoutDomain: String?
    public var subscriptionDomain: String?
    public var hasKycKyxTemplate: Bool?
    public var hasKybKyxTemplate: Bool?
    public var isMoneyTransferPartner: Bool?

    public init(
        ttl: Int? = nil,
        retryCount: Int? = nil,
        allowPayment: Bool? = nil,
        sessionTtl: Int? = nil,
        customCheckout: Bool? = nil,
        domainAddress: String? = nil,
        checkoutDomain: String? = nil,
        subscriptionDomain: String? = nil,
        hasKycKyxTemplate: Bool? = nil,
        hasKybKyxTemplate: Bool? = nil,
        isMoneyTransferPartner: Bool? = nil
    ) {
        self.ttl = ttl
        self.retryCount = retryCount
        self.allowPayment = allowPayment
        self.sessionTtl = sessionTtl
        self.customCheckout = customCheckout
        self.domainAddress = domainAddress
        self.checkoutDomain = checkoutDomain
        self.subscriptionDomain = subscriptionDomain
        self.hasKycKyxTemplate = hasKycKyxTemplate
        self.hasKybKyxTemplate = hasKybKyxTemplate
        self.isMoneyTransferPartner = isMoneyTransferPartner
    }
}

public struct OrganizationCurrency: Codable, Sendable {
    public var id: String?
    public var currencyUnit: String?
    public var code: String?
    public var name: String?
    public var symbol: String?

    public init(
        id: String? = nil,
        currencyUnit: String? = nil,
        code: String? = nil,
        name: String? = nil,
        symbol: String? = nil
    ) {
        self.id = id
        self.currencyUnit = currencyUnit
        self.code = code
        self.name = name
        self.symbol = symbol
    }
}

public struct OrganizationCurrenciesResponse: Codable, Sendable {
    public var currencies: [OrganizationCurrency]

    public init(currencies: [OrganizationCurrency] = []) {
        self.currencies = currencies
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currencies = try container.decodeIfPresent([OrganizationCurrency].self, forKey: .currencies) ?? []
    }

    enum CodingKeys: String, CodingKey {
        case currencies
    }
}

public struct OrganizationCurrencyPreset: Codable, Sendable {
    public var currencyCode: String?
    public var currencyUnit: String?
    public var name: String?
    public var minorUnit: Int?

    public init(
        currencyCode: String? = nil,
        currencyUnit: String? = nil,
        name: String? = nil,
        minorUnit: Int? = nil
    ) {
        self.currencyCode = currencyCode
        self.currencyUnit = currencyUnit
        self.name = name
        self.minorUnit = minorUnit
    }
}

/// The currencies the organization can add.
public struct OrganizationCurrencyPresetsResponse: Codable, Sendable {
    public var items: [OrganizationCurrencyPreset]?

    public init(items: [OrganizationCurrencyPreset]? = nil) {
        self.items = items
    }
}

public struct CreateOrganizationCurrencyResponse: Codable, Sendable {
    public var code: Int?
    public var message: String?
    public var created: Bool?
    public var currency: OrganizationCurrency?

    public init(
        code: Int? = nil,
        message: String? = nil,
        created: Bool? = nil,
        currency: OrganizationCurrency? = nil
    ) {
        self.code = code
        self.message = message
        self.created = created
        self.currency = currency
    }
}

public struct OrgCreateUserRequest: Codable, Sendable {
    public var email: String?
    public var identityNumber: String?
    public var phone: String?
    public var firstName: String?
    public var lastName: String?
    public var referenceId: String?
    public var conversationId: String?
    public var isMailVerified: Bool?

    public init(
        email: String? = nil,
        identityNumber: String? = nil,
        phone: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        referenceId: String? = nil,
        conversationId: String? = nil,
        isMailVerified: Bool? = nil
    ) {
        self.email = email
        self.identityNumber = identityNumber
        self.phone = phone
        self.firstName = firstName
        self.lastName = lastName
        self.referenceId = referenceId
        self.conversationId = conversationId
        self.isMailVerified = isMailVerified
    }
}

public struct OrgCreateUserResponse: Codable, Sendable {
    public var code: Int?
    public var message: String?
    public var userId: String?

    public init(
        code: Int? = nil,
        message: String? = nil,
        userId: String? = nil
    ) {
        self.code = code
        self.message = message
        self.userId = userId
    }
}

public struct OrgUserTokenCreateRequest: Codable, Sendable {
    public var email: String?
    /// Token lifetime in minutes.
    public var expire: Int?
    public var invalidateOldTokens: Bool?
    public var userId: String?

    public init(
        email: String? = nil,
        expire: Int? = nil,
        invalidateOldTokens: Bool? = nil,
        userId: String? = nil
    ) {
        self.email = email
        self.expire = expire
        self.invalidateOldTokens = invalidateOldTokens
        self.userId = userId
    }
}

public struct OrgUserTokenCreateResponse: Codable, Sendable {
    public var code: Int?
    public var message: String?
    public var token: String?
    public var userId: String?

    public init(
        code: Int? = nil,
        message: String? = nil,
        token: String? = nil,
        userId: String? = nil
    ) {
        self.code = code
        self.message = message
        self.token = token
        self.userId = userId
    }
}

public struct SuborganizationListItem: Codable, Sendable {
    public var id: String?
    public var name: String?
    public var address: String?
    public var city: String?
    public var country: String?
    public var phone: String?
    public var currency: String?
    public var logo: String?

    public init(
        id: String? = nil,
        name: String? = nil,
        address: String? = nil,
        city: String? = nil,
        country: String? = nil,
        phone: String? = nil,
        currency: String? = nil,
        logo: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.city = city
        self.country = country
        self.phone = phone
        self.currency = currency
        self.logo = logo
    }
}

public struct SuborganizationListResponse: Codable, Sendable {
    public var page: Int?
    public var perPage: Int?
    public var total: Int?
    public var totalPages: Int?
    public var rows: [SuborganizationListItem]?

    public init(
        page: Int? = nil,
        perPage: Int? = nil,
        total: Int? = nil,
        totalPages: Int? = nil,
        rows: [SuborganizationListItem]? = nil
    ) {
        self.page = page
        self.perPage = perPage
        self.total = total
        self.totalPages = totalPages
        self.rows = rows
    }
}

public struct SuborganizationDetail: Codable, Sendable {
    public var id: String?
    public var name: String?
    public var parentId: String?
    public var publicStatus: Int?
    public var availabilityStatus: Int?
    public var createdAt: String?
    public var updatedAt: String?

    public init(
        id: String? = nil,
        name: String? = nil,
        parentId: String? = nil,
        publicStatus: Int? = nil,
        availabilityStatus: Int? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.name = name
        self.parentId = parentId
        self.publicStatus = publicStatus
        self.availabilityStatus = availabilityStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct SubmerchantSuborganizationMapping: Codable, Sendable {
    public var submerchantId: String?
    public var suborganizationId: String?

    public init(submerchantId: String? = nil, suborganizationId: String? = nil) {
        self.submerchantId = submerchantId
        self.suborganizationId = suborganizationId
    }
}

public struct SuborganizationSubmerchantMapping: Codable, Sendable {
    public var suborganizationId: String?
    public var submerchantId: String?

    public init(suborganizationId: String? = nil, submerchantId: String? = nil) {
        self.suborganizationId = suborganizationId
        self.submerchantId = submerchantId
    }
}

public struct SubscriptionGetRequest: Codable, Sendable {
    public var referenceId: String?
    public var externalReferenceId: String?

    public init(referenceId: String? = nil, externalReferenceId: String? = nil) {
        self.referenceId = referenceId
        self.externalReferenceId = externalReferenceId
    }
}

public struct SubscriptionCancelRequest: Codable, Sendable {
    public var referenceId: String?
    public var externalReferenceId: String?

    public init(referenceId: String? = nil, externalReferenceId: String? = nil) {
        self.referenceId = referenceId
        self.externalReferenceId = externalReferenceId
    }
}

public struct SubscriptionBilling: Codable, Sendable {
    public var address: String?
    public var city: String?
    public var contactName: String?
    public var country: String?
    public var vatNumber: String?
    public var zipCode: String?

    public init(
        address: String? = nil,
        city: String? = nil,
        contactName: String? = nil,
        country: String? = nil,
        vatNumber: String? = nil,
        zipCode: String? = nil
    ) {
        self.address = address
        self.city = city
        self.contactName = contactName
        self.country = country
        self.vatNumber = vatNumber
        self.zipCode = zipCode
    }
}

public struct SubscriptionUser: Codable, Sendable {
    public var address: String?
    public var city: String?
    public var country: String?
    public var email: String?
    public var firstName: String?
    public var id: String?
    public var identityNumber: String?
    public var lastName: String?
    public var phone: String?
    public var zipCode: String?

    public init(
        address: String? = nil,
        city: String? = nil,
        country: String? = nil,
        email: String? = nil,
        firstName: String? = nil,
        id: String? = nil,
        identityNumber: String? = nil,
        lastName: String? = nil,
        phone: String? = nil,
        zipCode: String? = nil
    ) {
        self.address = address
        self.city = city
        self.country = country
        self.email = email
        self.firstName = firstName
        self.id = id
        self.identityNumber = identityNumber
        self.lastName = lastName
        self.phone = phone
        self.zipCode = zipCode
    }
}

public struct SubscriptionCreateRequest: Codable, Sendable {
    public var amount: Double?
    public var billing: SubscriptionBilling?
    public var cardId: String?
    public var currency: String?
    public var cycle: Int?
    public var externalReferenceId: String?
    public var failureUrl: String?
    /// The billing interval, for example "month".
    public var interval: String?
    /// The number of intervals between payments.
    public var intervalCount: Int?
    /// Deprecated: ignored by the server; the subscription start date sets the billing anchor.
    public var paymentDate: Int?
    /// Deprecated: the legacy day-count cadence. Use `interval` and `intervalCount`.
    public var period: Int?
    public var successUrl: String?
    public var title: String?
    public var user: SubscriptionUser?
    /// Deprecated: not part of the API; the server ignores it.
    public var planId: String?

    public init(
        amount: Double? = nil,
        billing: SubscriptionBilling? = nil,
        cardId: String? = nil,
        currency: String? = nil,
        cycle: Int? = nil,
        externalReferenceId: String? = nil,
        failureUrl: String? = nil,
        interval: String? = nil,
        intervalCount: Int? = nil,
        paymentDate: Int? = nil,
        period: Int? = nil,
        successUrl: String? = nil,
        title: String? = nil,
        user: SubscriptionUser? = nil,
        planId: String? = nil
    ) {
        self.amount = amount
        self.billing = billing
        self.cardId = cardId
        self.currency = currency
        self.cycle = cycle
        self.externalReferenceId = externalReferenceId
        self.failureUrl = failureUrl
        self.interval = interval
        self.intervalCount = intervalCount
        self.paymentDate = paymentDate
        self.period = period
        self.successUrl = successUrl
        self.title = title
        self.user = user
        self.planId = planId
    }
}

public struct SubscriptionRedirectRequest: Codable, Sendable {
    public var subscriptionId: String?

    public init(subscriptionId: String? = nil) {
        self.subscriptionId = subscriptionId
    }

    @available(*, deprecated, renamed: "init(subscriptionId:)")
    public init(referenceId: String) {
        self.subscriptionId = referenceId
    }
}

public struct SubscriptionOrder: Codable, Sendable {
    public var amount: String?
    public var currency: String?
    public var paymentDate: String?
    public var paymentUrl: String?
    public var referenceId: String?
    public var status: String?

    public init(
        amount: String? = nil,
        currency: String? = nil,
        paymentDate: String? = nil,
        paymentUrl: String? = nil,
        referenceId: String? = nil,
        status: String? = nil
    ) {
        self.amount = amount
        self.currency = currency
        self.paymentDate = paymentDate
        self.paymentUrl = paymentUrl
        self.referenceId = referenceId
        self.status = status
    }
}

public struct SubscriptionDetail: Codable, Sendable {
    public var amount: String?
    public var cycle: Int?
    public var cyclesCompleted: Int?
    public var currency: String?
    public var dueDate: String?
    public var externalReferenceId: String?
    public var interval: String?
    public var intervalCount: Int?
    public var isActive: Bool?
    public var orders: [SubscriptionOrder]?
    public var paymentDate: Int?
    public var paymentStatus: String?
    public var period: Int?
    public var title: String?
    /// Deprecated: not returned by the server.
    public var id: String?
    /// Deprecated: not returned by the server; see `paymentStatus`.
    public var status: String?

    public init(
        amount: String? = nil,
        cycle: Int? = nil,
        cyclesCompleted: Int? = nil,
        currency: String? = nil,
        dueDate: String? = nil,
        externalReferenceId: String? = nil,
        interval: String? = nil,
        intervalCount: Int? = nil,
        isActive: Bool? = nil,
        orders: [SubscriptionOrder]? = nil,
        paymentDate: Int? = nil,
        paymentStatus: String? = nil,
        period: Int? = nil,
        title: String? = nil,
        id: String? = nil,
        status: String? = nil
    ) {
        self.amount = amount
        self.cycle = cycle
        self.cyclesCompleted = cyclesCompleted
        self.currency = currency
        self.dueDate = dueDate
        self.externalReferenceId = externalReferenceId
        self.interval = interval
        self.intervalCount = intervalCount
        self.isActive = isActive
        self.orders = orders
        self.paymentDate = paymentDate
        self.paymentStatus = paymentStatus
        self.period = period
        self.title = title
        self.id = id
        self.status = status
    }
}

public struct SubscriptionListItem: Codable, Sendable {
    public var amount: String?
    public var cycle: Int?
    public var cyclesCompleted: Int?
    public var currency: String?
    public var externalReferenceId: String?
    public var interval: String?
    public var intervalCount: Int?
    public var isActive: Bool?
    public var nextPaymentDate: String?
    public var paymentDate: Int?
    public var paymentStatus: String?
    public var period: Int?
    public var referenceId: String?
    public var title: String?

    public init(
        amount: String? = nil,
        cycle: Int? = nil,
        cyclesCompleted: Int? = nil,
        currency: String? = nil,
        externalReferenceId: String? = nil,
        interval: String? = nil,
        intervalCount: Int? = nil,
        isActive: Bool? = nil,
        nextPaymentDate: String? = nil,
        paymentDate: Int? = nil,
        paymentStatus: String? = nil,
        period: Int? = nil,
        referenceId: String? = nil,
        title: String? = nil
    ) {
        self.amount = amount
        self.cycle = cycle
        self.cyclesCompleted = cyclesCompleted
        self.currency = currency
        self.externalReferenceId = externalReferenceId
        self.interval = interval
        self.intervalCount = intervalCount
        self.isActive = isActive
        self.nextPaymentDate = nextPaymentDate
        self.paymentDate = paymentDate
        self.paymentStatus = paymentStatus
        self.period = period
        self.referenceId = referenceId
        self.title = title
    }
}

public struct SubscriptionCreateResponse: Codable, Sendable {
    public var code: Int?
    public var message: String?
    public var orderReferenceId: String?
    public var referenceId: String?
    /// Deprecated: not returned by the server.
    public var checkoutUrl: String?

    public init(
        code: Int? = nil,
        message: String? = nil,
        orderReferenceId: String? = nil,
        referenceId: String? = nil,
        checkoutUrl: String? = nil
    ) {
        self.code = code
        self.message = message
        self.orderReferenceId = orderReferenceId
        self.referenceId = referenceId
        self.checkoutUrl = checkoutUrl
    }
}

public struct SubscriptionRedirectResponse: Codable, Sendable {
    public var url: String?
    /// Deprecated: not returned by the server; see `url`.
    public var checkoutUrl: String?

    public init(url: String? = nil, checkoutUrl: String? = nil) {
        self.url = url
        self.checkoutUrl = checkoutUrl
    }
}
