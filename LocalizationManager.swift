import Foundation

struct LocalizationManager {
    enum ScreenTimeout {
        static func title() -> String {
            NSLocalizedString("ScreenTimeout.Title", comment: "Alert title for screen timeout")
        }
        
        static func message() -> String {
            NSLocalizedString("ScreenTimeout.Message", comment: "Alert message for screen timeout")
        }
        
        static func okButton() -> String {
            NSLocalizedString("ScreenTimeout.OKButton", comment: "OK button for screen timeout alert")
        }
    }
}
