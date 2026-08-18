import Foundation

// MARK: - 앱 실행에 필요한 환경 설정 제공
enum AppConfiguration {
    // MARK: - Supabase 프로젝트 URL
    static var supabaseURL: URL {
        let value = requiredValue(forKey: "SUPABASE_URL")              // Info.plist에 주입된 URL 조회

        guard let url = URL(string: value) else {
            preconditionFailure("SUPABASE_URL 형식이 올바르지 않습니다.")
        }

        return url
    }

    // MARK: - Supabase 공개 클라이언트 키
    static var supabasePublishableKey: String {
        requiredValue(forKey: "SUPABASE_PUBLISHABLE_KEY")              // Info.plist에 주입된 키 조회
    }

    // MARK: - Info.plist 필수 설정값 조회
    private static func requiredValue(forKey key: String) -> String {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
            !value.isEmpty,
            !value.hasPrefix("$(")
        else {
            preconditionFailure("필수 환경 설정값 \(key)이(가) 없습니다.")
        }

        return value
    }
}

