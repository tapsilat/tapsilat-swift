import Foundation

public enum Validators {
    public static func validateInstallments(_ installments: String?) throws -> [Int] {
        guard let installments, !installments.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return [1]
        }

        let values = try installments
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map {
                guard let number = Int($0) else {
                    throw ValidationError("Enabled installments must be comma-separated integers (e.g., 1,2,3 or 2,4,6)")
                }
                guard (1...12).contains(number) else {
                    throw ValidationError("Installment value '\(number)' is invalid. All installment values must be between 1 and 12 (inclusive).")
                }
                return number
            }

        return values.isEmpty ? [1] : values
    }

    public static func validateGsmNumber(_ phone: String?) throws -> String? {
        guard let phone else { return nil }

        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        let cleaned = trimmed
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")

        let plusCount = cleaned.filter { $0 == "+" }.count
        if plusCount > 1 || (plusCount == 1 && cleaned.first != "+") {
            throw ValidationError("Invalid phone number format: \(phone)")
        }

        let allowedChars = CharacterSet(charactersIn: "+0123456789")
        guard cleaned.unicodeScalars.allSatisfy({ allowedChars.contains($0) }) else {
            throw ValidationError("Invalid phone number format: \(phone)")
        }

        let digitsOnly = cleaned.replacingOccurrences(of: "+", with: "")
        guard !digitsOnly.isEmpty, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: digitsOnly)) else {
            throw ValidationError("Invalid phone number format: \(phone)")
        }

        if cleaned.hasPrefix("+") && cleaned.count < 8 {
            throw ValidationError("International phone number too short: \(phone)")
        }

        if cleaned.hasPrefix("00") && cleaned.count < 9 {
            throw ValidationError("International phone number (00 format) too short: \(phone)")
        }

        if cleaned.hasPrefix("0") && cleaned.count < 7 {
            throw ValidationError("National phone number too short: \(phone)")
        }

        if !cleaned.hasPrefix("0") && !cleaned.hasPrefix("+") && cleaned.count < 6 {
            throw ValidationError("Local phone number too short: \(phone)")
        }

        return cleaned
    }
}
