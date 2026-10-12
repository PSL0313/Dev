//
//  NicknameFeature.swift
//  flover9
//
//  Created by 박선린 on 10/6/26.
//
import ComposableArchitecture
import Foundation

@Reducer
struct NicknameFeature {
    // MARK: - 앱단에서 차단할 닉네임 목록
    private let reservedNicknames: Set<String> = [
        // MARK: - Official / Group
        "프로미스나인",
        "프나",
        "픎",
        "fromis_9",
        "fromis9",
        "fromisnine",
        "flover",
        "플로버",
        "ASND",
        "스프",
        "스튜디오 프로미스나인",
        "studiofromis_9",

        // MARK: - Official Contents
        "하냥카세",
        "젼메추",
        "챙그랑",
        "프나상사",

        // MARK: - Members
        "송하영",
        "하영",
        "박지원",
        "지원",
        "이채영",
        "채영",
        "이나경",
        "나경",
        "백지헌",
        "지헌",

        // MARK: - Former Members
        "이새롬",
        "새롬",
        "노지선",
        "지선",
        "이서연",
        "서연",
        "장규리",
        "규리",

        // MARK: - YouTube / Fantube
        "나 잘한다해짜나",
        "이프나",
        "하냥",
        "져니를막아야해",
        "복근속에 치킨",
        "story속은paradise",
        "기프나슬프나",
        "LiveLaughfLover",
        "단발머리하냥",
        "메거네틱",
        "Meganetic",
        "플로버드루와",
        "왜케막애기가찌",
        "헌이콤보",
        "주둥핑마즈나요",
        "플롭어",
        "우리 걸그룹인데",
        "규리vs귤",
        "Cherry Tomato",
        "잼민이나경",
        "frominusone",
        "옳게된플로버",
        "프나에게서 헤어 나올 수 없어",
        "즈을거운관람되세요오",
        "쟈동차를 몰꼬에요",
        "요란할뿐이야",
        "아보카도",
        "나야, 플로버",
        "말바하보영",
        "드루와잘해줄께",
        "일하는 플튜브",
        "정픎",
        "굴렁",
        "시간을 돌려",
        "스윗 플로버",
        "지헌마이웨이",
        "플로버나인",

        // MARK: - YouTube Legacy / Secondary Accounts
        "HeartSignalIdol",
        "pinpong무한repeat",
        "네미소에내맘이떨려",
        "방안을헤엄치는중",
        "지금이대로withme",
        "meganetic_flover",

        // MARK: - Korean X / Fansites / Photographers
        "우슴벨",
        "뀨잉",
        "CHAENGMORNING",
        "나꼬멘트",
        "김빱은딸기",
        "백지헌 갤러리",
        "프로미스나인 옷장",
        "세젤귀하냥",
        "나진지해허니",
        "챙잉",
        "만월",
        "SowuS",
        "5마넌 달고나",
        "멈구름",
        "Divine",
        "서로의시선",
        "Blooming_F9",
        "뽀스비",
        "Henize",
        "젼콩",
        "돌",
        "이나경 갤러리",
        "박지원 갤러리",
        "Déjà vu",
        "헌지백",
        "감자챙칼",
        "꿀",
        "내최애는2채0",
        "Lure",

        // MARK: - Additional Fansites / Photo Accounts
        "눈꽃하냥",
        "StarChase",
        "dear",
        "치즈버거",
        "꿀눅",
        "꿀로만든지허니",
        "덕질하는챙로버",
        "Bene",
        "져니만니",
        "위시리스트",
        "차차",
        "케이",
        "톨냥",
        "포대자루챙",
        "꽃보다채영",
        "fromiscent",

        // MARK: - International / Archive / Information Accounts
        "all things fromis_9",
        "allthingsfromis",
        "jiheon pics!",
        "jiheonpix",
        "hayoung pics",
        "hayoungarchives",
        "Honey pow",
        "Honeypow_jh",
        "gyuri pics",
        "gyuriarchives",
        "켄짱",
        "forever_9_514",
        "fromis_9 Charts",
        "chartsfromis",
        "fromis_9 Brasil",
        "fromis_9br",
        "picsofjiheon",
        "jiwon loops",
        "jiwonloops",
        "REVOLF",
        "revolf124",
        "Out Of Context fromis_9",
        "OOCfromis_9",
        "Fromis_9 Thailand",
        "Fromis__th",
        "frequent fromis",
        "fromisfairys",
        "FROMIS_9 BASE",
        "fromisbase",
        "fromis loops",
        "fromisloopz",
        "Jang Gyuri Facts",
        "JGRfacts",
        "fromis_9 THAILAND",
        "fromis_9_TH",
        "fromis_9 fanclub",
        "flover_only_",
        "jiheonfeed",
        "fromispic",
        "fromis_9 Global",
        "fromis_9Global",
        "fromis_9 schedule",
        "fromis_schedule",
        "seoyeon pics",
        "LEESEOYE0NS",
        "daily hayoung",
        "hayoungdaily",
        "nagyung media",
        "nagyungmedia",
        "diazoraflover",
        "diazora10",
        "fromis_9 PHILIPPINES",
        "fromis_9PH",
        "fromis_9 NEWS",
        "fromisnews_",
        "fromis_9 details",
        "fromis9details",
        "fromis_9 archive",
        "fromis_9archive",
        "fromis_9 fancams",
        "fromisfncams",
        "frmisclub",
        "hourly fromis_9",
        "hourlyfromis_9",
        "thinking abt fromis",
        "WeThinkFromis",
        "fromis_9 4k wallpaper",
        "fromiswallpaper",
        "fromis_9 doing things",
        "fromisactivity",
        "floverStationhead",
        "fromiStation9",
        "fromisdays",

        // MARK: - TikTok
        "Syeonlight",
        "syeonleee23",
        "뛰뛰빵빵송하빵",
        "fromis_9.co.kr",
        "션부",
        "imf.v.rlsy122",

        // MARK: - Community / Known Nicknames
        "눈센세",
        "메들리",

        // MARK: - Community / Impersonation Prevention
        "프로미스나인 갤러리",
        "프로미스나인 마이너 갤러리",
        "픎갤",
        "프나갤",
        "송하영 갤러리",
        "박지원 갤러리",
        "이채영 갤러리",
        "이나경 갤러리",
        "백지헌 갤러리",
        "총공팀",
        "음총팀",
        "갤매",
        "갤매니저",
        "총대",
        
        // MARK: - Official / Impersonation Prevention
        "프로미스나인",
        "fromis_9",
        "fromis9",
        "fromisnine",
        "realfromis_9",
        "officialfromis_9",
        "officialfromis9",

        "플로버",
        "flover",
        "flover9",

        "ASND",
        "에이에스엔디",
        "ASND Entertainment",
        "ASND엔터테인먼트",

        "스프",
        "스튜디오 프로미스나인",
        "스튜디오프로미스나인",
        "Studio fromis_9",
        "studiofromis_9",

        // Members
        "송하영",
        "Song Hayoung",
        "songhayoung",

        "박지원",
        "Park Jiwon",
        "parkjiwon",

        "이채영",
        "Lee Chaeyoung",
        "leechaeyoung",

        "이나경",
        "Lee Nagyung",
        "leenagyung",

        "백지헌",
        "Baek Jiheon",
        "baekjiheon",

        // Former members
        "이새롬",
        "Lee Saerom",
        "leesaerom",

        "노지선",
        "Roh Jisun",
        "rohjisun",

        "이서연",
        "Lee Seoyeon",
        "leeseoyeon",

        "장규리",
        "Jang Gyuri",
        "janggyuri",

        // Official-content names
        "하냥카세",
        "젼메추",
        "챙그랑",
        "프나상사"
    ]

    // MARK: - UseCase

    private let updateProfileUsecase: UpdateProfileUsecaseProtocol
    
    init(updateProfileUsecase: UpdateProfileUsecaseProtocol) {
        self.updateProfileUsecase = updateProfileUsecase
    }

    // MARK: - Route
    var onRoute: (@MainActor @Sendable (Route) -> Void)?

    enum Route {
        case completed
        case failed(String)
    }

    // MARK: - State

    @ObservableState
    struct State: Equatable {
        var name = ""
        var availableCheckResult: UnavailableType = .none
        var isLoading = false
        var isSaving = false
        /// nickname : 사용 가능 여부
        var nicknameAvailabilityCache: [String: Bool] = [:]
    }

    // MARK: - Action

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case availableCheckButtonTapped
        case nextButtonTapped
        case availabilityChecked(name: String, isAvailable: UnavailableType)
        case availabilityCheckFailed
        case completed
    }

    // MARK: - Reducer

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .availableCheckButtonTapped:
                guard !state.isLoading else {
                    return .none
                }
                state.isLoading = true
                let name = state.name.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !name.isEmpty else {
                    return .none
                }

                guard !isReservedNickname(state.name) else {
                    return .send(.availabilityChecked(name: state.name, isAvailable: .limit))
                }

                // 이미 검사한 닉네임이라면 캐시 사용
                if let cachedResult = state.nicknameAvailabilityCache[name] {
                    return .send(.availabilityChecked(name: state.name, isAvailable: cachedResult ? .available : .used))
                }

                return .run { send in
                    do {
                        let result = try await updateProfileUsecase
                            .isAvailableNickname(name)

                        await send(
                            .availabilityChecked(
                                name: result.0,
                                isAvailable: result.1 ? .available : .used
                            )
                        )
                    } catch {
                        await send(.availabilityCheckFailed)
                    }
                }


            case let .availabilityChecked(name, isAvailable):
                state.isLoading = false
                state.nicknameAvailabilityCache[name] = isAvailable == .available ? true : false

                // 검사하는 동안 입력값이 바뀌었을 수도 있으므로
                // 현재 입력값과 검사한 닉네임이 같을 때만 UI 결과 반영
                if state.name == name {
                    state.availableCheckResult = isAvailable
                }

                return .none


            case .availabilityCheckFailed:
                state.isLoading = false
                onRoute?(.failed("중복 검사에 실패하였습니다."))

                return .none


            case .nextButtonTapped:
                guard state.availableCheckResult == .available else {
                    return .none
                }
                state.isSaving = true

                return .run { [state]send in
                    do {
                        try await updateProfileUsecase.update(nickname: state.name)
                        await send(.completed)
                        
                    } catch let error as ProfileError {
                        await onRoute?(.failed(error.userMessage))
                    }
                }
            case .completed:
                return .run { _ in
                    await onRoute?(.completed)
                }
            }
        }
    }
    
    private func isReservedNickname(_ nickname: String) -> Bool {
        let normalizedNickname = normalize(nickname)

        return reservedNicknames.contains {
            normalize($0) == normalizedNickname
        }
    }

    private func normalize(_ nickname: String) -> String {
        nickname
            .precomposedStringWithCanonicalMapping
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }
    }
}


extension NicknameFeature {
    enum UnavailableType {
        case used
        case limit
        case available
        case none
        
        var msg: String {
            switch self {
            case .used:
                return "이미 사용 중인 닉네임이에요."
            case .limit:
                return "타 SNS에서 활동중인 일부 닉네임은 일부 제한된 상태입니다. 필요한 경우 관리자에게 문의해주세요."
            case .available:
                return "사용할 수 있는 닉네임이에요."
            case .none:
                return "입력 후 중복 확인을 눌러주세요."
                
            }
        }
    }
}
