# iOS 클라이언트 구현 기록

UIKit과 SwiftUI를 함께 사용하는 iOS 프로젝트입니다. 화면 전환, 데이터 조회와 캐시, 인증, 미디어 업로드, 권한 기반 관리 기능의 구현 구조를 정리합니다.

현재 작업 기준은 `develop` 브랜치이며, 개발 중인 기능과 실험용 화면이 포함되어 있습니다.

## 주요 기능

| 기능 | 구현 내용 |
| --- | --- |
| 피드 조회 | 그리드 목록, offset 기반 페이지네이션, 식별자별 캐시, 상세 미디어 조회 |
| 미디어 상세 | 이미지 표시, 상세 화면 전환, 드래그 닫기 및 미리보기 |
| 일정 | 월별 일정 날짜 조회, 날짜별 목록, 일정 상세 및 캘린더 연동 |
| 로그인·프로필 | Apple 로그인, 세션 복원, 약관 동의, 닉네임 설정 |
| 배경화면 | 목록·검색·시리즈·상세·즐겨찾기·다운로드 관련 화면과 계층 |
| 콘텐츠 관리 | 피드·일정·배경화면 편집, 업로드 배치 확정 및 실패 시 정리 요청 |
| 권한 관리 | 현재 권한 조회, 허용된 관리 메뉴 표시, 역할 변경·관리 권한 이전 요청 |

관리 기능은 로그인한 사용자의 서버 권한에 따라 제한됩니다. 공개 클라이언트 키만으로 관리자 권한이 부여되지는 않습니다.

## 기술 스택

| 영역 | 기술 |
| --- | --- |
| 언어 | Swift (프로젝트 언어 모드: Swift 6) |
| UI | UIKit, SwiftUI, SnapKit, Kingfisher |
| 구조 | MVVM-C, Repository, UseCase, DIContainer |
| 상태 관리 | TCA (`ComposableArchitecture`) — 캘린더·약관·닉네임 Feature |
| 비동기 처리 | async/await, actor, TaskGroup |
| 데이터·인증 | Supabase, Sign in with Apple |
| 미디어 저장 연동 | Edge Functions, Cloudflare R2 |
| 앱 운영 | Firebase Remote Config, Crashlytics |
| 테스트 | Swift Testing 및 테스트 대역 |
| 의존성 관리 | Swift Package Manager |

## 코드에서 살펴볼 부분

### 요청 범위를 기준으로 피드 캐시 재사용

`limit`만으로는 요청 개수만 알 수 있어 다음 페이지와 이미 읽은 구간을 구분하기 어렵습니다. 저는 `offset`과 `limit`으로 요청 범위를 명시하고, 캐시에서 해당 구간을 먼저 읽도록 구현했습니다. 부족한 데이터만 원격에서 가져와 합칩니다.

- [FeedReadUseCase](flover9/Domain/Usecases/FeedReadUseCase.swift): 식별자별 조회 위치 관리
- [SupabaseFeedRepository](flover9/Data/Repositories/SupabaseFeedRepository.swift): 캐시와 원격 조회 조합
- [FeedCache](flover9/Data/Cache/FeedCache.swift): actor 기반 식별자별 피드·미디어 캐시

### 미디어 전송과 게시물 확정 분리

여러 파일을 업로드할 때 전송 완료와 피드 확정을 구분했습니다. 배치를 발급받아 파일을 병렬 전송한 뒤 결과를 연결하고, 마지막에 확정을 요청합니다. 실패하면 정리 요청을 시도하지만, 정리 요청 자체의 성공을 보장하는 트랜잭션은 아닙니다.

- [MediaStorageRepository](flover9/Data/Repositories/MediaStorageRepository.swift)

### 화면 상태와 비동기 결과를 Action으로 연결

캘린더의 월·일정 날짜·목록·로딩 상태를 Feature에서 관리합니다. 날짜 선택과 월 변경을 Action으로 받고, UseCase의 조회 결과를 다시 Action으로 전달해 State에 반영합니다. UIKit의 기존 Coordinator 흐름과 SwiftUI Feature를 함께 사용하는 구조입니다.

- [CalendarFeature](flover9/Presentation/SwiftUI/Feature/CalendarFeature.swift)
- [CalendarView](flover9/Presentation/SwiftUI/View/Calendar/CalendarView.swift)

### 변경 직전 권한 확인

역할 변경 요청 직전에 현재 권한을 다시 조회하고 변경 대상·역할·사유를 검사합니다. 앱의 검사는 사용자 흐름을 위한 것이며, 실제 접근 허용 여부는 서버에서도 검증해야 합니다.

- [AuthorizationUseCase](flover9/Domain/Usecases/AuthorizationUseCase.swift)
- [권한 관리 연동 기록](Documentation/Authorization.md)

## 프로젝트 구조

```text
Configuration/           공개 클라이언트 설정 및 로컬 설정 예시
flover9/
├── App/                 앱 진입점, DIContainer, 환경 설정
├── Domain/              Entity, UseCase, Repository 프로토콜
├── Data/                DTO, DataSource, Repository, Cache
├── Presentation/
│   ├── Coordinator/     화면 이동과 기능 연결
│   ├── UIKit/           ViewController, ViewModel, View, Layout
│   └── SwiftUI/         Feature, View
└── Service/             미디어 다운로드 등
flover9Tests/            도메인·데이터·레이아웃 테스트 및 테스트 대역
```

## 실행 방법

### 1. 개발 환경

- **Xcode 27 이상**, iOS 27 SDK 및 실행 가능한 iOS 27 시뮬레이터 또는 기기
- 현재 앱 타깃의 최소 배포 버전은 **iOS 27.0**입니다.
- Swift Package Manager 의존성을 받을 수 있는 네트워크 환경
- 실기기 실행 및 Apple 로그인에는 적절한 개발 팀·서명·Sign in with Apple 설정이 필요합니다.

### 2. 저장소 열기

```bash
git clone --branch develop https://github.com/PSL0313/Dev.git
cd Dev
open flover9.xcodeproj
```

Xcode에서 패키지 의존성 해결을 기다린 뒤 `flover9` 스킴과 실행 기기를 선택합니다.

### 3. Supabase 설정

[Configuration/Config.xcconfig](Configuration/Config.xcconfig)에 프로젝트 URL과 **publishable 키**가 포함되어 있어 이 두 값을 따로 입력할 필요는 없습니다. Debug와 Release가 이 파일을 사용하고, 값은 Info.plist를 거쳐 `AppConfiguration`으로 전달됩니다.

- URL과 publishable 키는 클라이언트에 포함하도록 설계된 공개 설정입니다. [Supabase API 키 문서](https://supabase.com/docs/guides/getting-started/api-keys)
- `https:/$()/...`는 `.xcconfig`에서 `//`가 주석으로 처리되지 않도록 쓰는 표기입니다.
- 서버용 `secret`·`service_role` 키나 DB 비밀번호는 포함하지 않습니다.
- 다른 프로젝트를 사용하려면 `Secrets.xcconfig.example`을 `Secrets.xcconfig`로 복사하고 공개 클라이언트 설정을 입력합니다. 로컬 설정이 기본값을 덮어쓰며 이 파일은 Git에서 제외됩니다.
- 연결 대상은 앱 개발에 사용하는 백엔드입니다. 별도의 샘플 데이터 전용 환경은 아닙니다.

### 4. Firebase 설정 — 별도 준비 필요

현재 앱은 시작할 때 `FirebaseApp.configure()`를 호출합니다. **Supabase 설정만으로 모든 실행 준비가 끝나는 것은 아닙니다.**

1. 사용할 Firebase 프로젝트에 앱의 Bundle Identifier와 일치하는 iOS 앱을 등록합니다.
2. 해당 앱의 `GoogleService-Info.plist`를 내려받습니다.
3. `flover9/App/GoogleService-Info.plist`에 놓고 앱 타깃의 번들 리소스에 포함되는지 확인합니다.
4. 앱 실행 후 Remote Config·Crashlytics 연결 설정을 확인합니다.

이 Firebase 설정 파일은 현재 저장소에서 제외되어 있습니다. 다른 Firebase 프로젝트를 사용하면 앱 점검·업데이트 설정도 해당 프로젝트의 값으로 동작합니다.

### 5. 실행 범위

앱을 빌드하고 실행하더라도 로그인·데이터 조회·관리 기능은 연결된 서버 상태와 계정 권한에 영향을 받습니다. 이 저장소는 iOS 클라이언트이며, 다른 Supabase 프로젝트의 URL과 키만 입력한다고 같은 서비스가 만들어지는 것은 아닙니다. 동일한 기능에는 DB 구조, 접근 정책, Edge Functions 및 미디어 저장소 설정이 필요합니다.

## 테스트

`flover9Tests`에는 세션 복원, 권한 관리, 일정 조회·캐시, 미디어 편집, 배경화면 및 레이아웃 관련 테스트가 있습니다.

환경 설정을 마친 뒤 Xcode에서 **Product > Test** (`⌘U`)로 실행할 수 있습니다. 테스트 코드가 존재한다는 사실과 특정 환경에서의 전체 테스트 통과는 구분하며, 서버를 포함한 종단 간 동작은 별도 확인이 필요합니다.

## 개발 상태

이 저장소는 계속 변경 중입니다. 현재 `MainCoordinator`에는 실험용 탭 연결이 포함되어 있고, UIKit 기반 화면에 SwiftUI·TCA Feature를 추가하는 작업을 진행하고 있습니다.

### 빌드 확인

2026-10-12, Xcode 27.0에서 아래 명령으로 iOS 시뮬레이터용 Debug 빌드 성공을 확인했습니다.

```bash
xcodebuild -project flover9.xcodeproj \
  -scheme flover9 \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -disableAutomaticPackageResolution \
  CODE_SIGNING_ALLOWED=NO build
```

실행 대상은 `-destination`으로 지정합니다. 이 환경에서는 `-sdk iphonesimulator`까지 강제 지정하면 macOS에서 실행되어야 하는 `PerceptionMacros`가 iOS 시뮬레이터용으로 빌드되면서 SwiftSyntax 모듈을 찾지 못했습니다. SDK 강제 지정 없이 같은 패키지 버전과 앱 코드로 빌드에 성공했습니다.

이 결과는 로컬 설정과 패키지가 준비된 환경의 컴파일 확인입니다. Firebase 설정 파일 준비, 로그인 및 실제 서버 기능의 실행 검증은 별도입니다.

### Swift 6 전환 확인

앱과 단위·UI 테스트 타깃의 Debug/Release 언어 모드를 Swift 6로 맞췄습니다. UseCase의 메인 액터 경계와 전달 가능한 데이터 타입을 명시하고, 백그라운드 다운로드의 진행률 갱신을 메인 액터에서 처리하도록 정리했습니다. 테스트의 최소 iOS 버전도 앱과 같은 27.0으로 맞췄습니다.

2026-10-12, Xcode 27.0의 iPhone 18 Pro (iOS 27) 시뮬레이터에서 `flover9Tests` 전체 실행이 성공했습니다. UI 테스트 실행과 실기기의 백그라운드 다운로드·사진 저장 동작은 이 검증에 포함하지 않았습니다.
