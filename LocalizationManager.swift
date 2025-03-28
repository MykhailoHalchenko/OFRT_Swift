import Foundation

enum Localization {
    enum ScreenTimeout {
        static func title(for language: Language) -> String {
            switch language {
            case .ukrainian: return "Увага"
            case .english: return "Attention"
            case .russian: return "Внимание"
            }
        }
        
        static func message(for language: Language) -> String {
            switch language {
            case .ukrainian: return "Час очікування вичерпано"
            case .english: return "Timeout has expired"
            case .russian: return "Время ожидания истекло"
            }
        }
        
        static func okButton(for language: Language) -> String {
            switch language {
            case .ukrainian: return "ОК"
            case .english: return "OK"
            case .russian: return "ОК"
            }
        }
    }
    
    enum Language {
        case ukrainian
        case english
        case russian
    }
}
