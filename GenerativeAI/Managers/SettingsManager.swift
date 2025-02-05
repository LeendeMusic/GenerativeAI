import Foundation

class SettingsManager {
    private static let huggingFaceTokenKey = "huggingFaceToken"
    
    static func saveHuggingFaceToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: huggingFaceTokenKey)
    }
    
    static func getHuggingFaceToken() -> String? {
        return UserDefaults.standard.string(forKey: huggingFaceTokenKey)
    }
    
    static func removeHuggingFaceToken() {
        UserDefaults.standard.removeObject(forKey: huggingFaceTokenKey)
    }
} 