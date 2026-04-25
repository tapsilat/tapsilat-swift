import XCTest
@testable import Tapsilat

final class ValidatorsTests: XCTestCase {
    func testValidateInstallmentsReturnsDefaultForNil() throws {
        XCTAssertEqual(try Validators.validateInstallments(nil), [1])
    }

    func testValidateInstallmentsParsesCSV() throws {
        XCTAssertEqual(try Validators.validateInstallments("1,2,3,12"), [1, 2, 3, 12])
    }

    func testValidateInstallmentsRejectsOutOfRange() {
        XCTAssertThrowsError(try Validators.validateInstallments("0,1"))
        XCTAssertThrowsError(try Validators.validateInstallments("1,13"))
    }

    func testValidateGsmNormalizesCommonCharacters() throws {
        let result = try Validators.validateGsmNumber("+90 (555) 123-45-67")
        XCTAssertEqual(result, "+905551234567")
    }

    func testValidateGsmRejectsMisplacedPlus() {
        XCTAssertThrowsError(try Validators.validateGsmNumber("90+5551234567"))
    }
}
