# 앱 권한 관리 연동 — 2026-09-29

## 사용 흐름

관리자 탭에 진입할 때 `authorization` Edge Function의 `me`를 호출합니다. 이름은 `profiles`, 역할과 작업 권한은 `user_roles`에 기반한 API 응답으로 표시합니다. 앱은 `profiles.role`을 더 이상 읽지 않습니다.

- **어드민 / 매니저**: 부여된 권한에 따라 피드·일정·배경화면·회원 권한 관리 메뉴 표시.
- **크리에이터**: 본인 배경화면 관리 메뉴 표시. 전체 피드·일정 관리 화면은 해당 운영 권한이 있는 사용자에게만 허용.
- **일반 회원**: 관리자 화면에서 권한 없음 안내.

회원 권한 관리 → 닉네임 또는 회원 UUID 검색 → 회원 선택 → 새 역할 선택 → 변경 사유 → 대상 ID와 변경 내용 확인 → 변경.

- 매니저는 일반 회원 ↔ 크리에이터만 변경합니다.
- 어드민는 매니저도 임명·회수할 수 있습니다.
- 어드민 이전은 별도 메뉴이며 이전 후 본인은 매니저가 됩니다.
- 어드민 역할은 일반 역할 선택으로 부여·회수하지 않습니다.
- 첫 어드민 지정은 서버 운영 절차로만 가능하며, 앱에서 기존 관리자를 자동 승격하지 않습니다.
- 조회한 기존 역할은 `expectedRole`로 보냅니다. 일반 회원은 반드시 JSON `null`을 전송합니다. 서버가 409를 반환하면 자동 재시도하지 않고 목록을 새로 조회합니다.

## 의존성 흐름

`AppDIContainer` → `SupabaseAuthorizationRemoteDataSource` → `AuthorizationRepository` → `AuthorizationUseCase` → `RoleManagementViewModel` → `RoleManagementViewController`

화면 이동·사유 입력·최종 확인은 `AdminCoordinator`에서 담당합니다. UI 레이아웃은 UIKit/SnapKit을 사용합니다.

## 확인할 파일

| 파일 | 확인할 내용 |
| --- | --- |
| `Domain/Models/UserRole.swift` | admin/manager/creator만 존재. 일반 회원은 nil |
| `Domain/Models/Authorization/AppPermission.swift` | 서버 작업 권한 코드와 대응 |
| `Domain/Entities/Authorization/UserAuthorization.swift` | 역할 이름 대신 권한 집합으로 허용 기능 판단 |
| `Data/DTOs/Authorization/RoleChangeRequestDTO.swift` | role / expectedRole의 명시적 null 인코딩 |
| `Data/DataSource/SupabaseAuthorizationRemoteDataSource.swift` | 현재 사용자 JWT 전달, RLS 목록 조회, 오류 처리 |
| `Domain/Usecases/AuthorizationUseCase.swift` | 변경 직전 최신 권한, 사유 검증, 자기 자신으로 어드민 이전 차단 |
| `Presentation/ViewModels/Admin/RoleManagementViewModel.swift` | 검색·페이지·중복 변경 차단·변경 후 재조회 |
| `Presentation/Coordinator/AdminCoordinator.swift` | 대상/사유/최종 확인과 어드민 이전 경고 |
| `Domain/Usecases/AdminUseCase.swift` | 피드와 일정의 작업 권한을 각각 재확인 |
| `Data/DataSource/SupabaseWallpaperAdminRemoteDataSource.swift` | 새 역할 테이블로 제작자 목록 조회, 본인/전체 관리 범위, 저장 전 권한 확인 |
| `Domain/Entities/Wallpaper/WallpaperEditorContext.swift` | 추천·생성·제작자 지정·전체 관리 권한을 각각 분리 |

권한 응답은 영구 캐시하지 않습니다. 관리자·배경화면 설정 화면 재진입과 관리 작업 직전에 재조회합니다. 권한 조회 실패를 이전 허용 상태로 대체하지 않습니다. 실제 데이터 접근의 최종 검증은 서버 RLS/Edge Function/RPC가 수행합니다.

배경화면의 기존 URL 유지·새 이미지만 업로드·불확실한 저장 요청 재확인 로직은 유지합니다. 어드민 탈퇴 거절 응답은 한국어로 소유권 이전이 필요하다고 안내합니다.

## 검증

- `AuthorizationTests`: null 인코딩, 프로필 역할 분리, 역할 이름만으로 승격 금지, 관리자 변경 범위, 권한 회수, 어드민 이전, 충돌 처리, 접근 회수 시 목록 비우기.
- `AuthorizationLayoutTests`: 실제 회원 목록의 표시와 레이아웃.
- `AdminValidationTests`, `AdminMediaEditingTests`, `WallpaperTests`: 기존 관리·업로드 흐름 회귀 검증.

운영 계정의 역할을 실제로 바꾸는 테스트는 실행하지 않습니다. 최초 어드민 지정 후 로그인 계정으로 서버 연동 확인이 필요합니다.

### 이번 실행 결과

실제 프로젝트 작업 트리에서 iOS 시뮬레이터 전체 빌드가 성공했고, iOS 26.2 시뮬레이터에서 선택 테스트 32개가 모두 통과했습니다. 권한 관리 목록은 밝은/어두운 테마 캡처로도 확인했습니다.

전체 빌드 과정에서 일정 캐시의 두 조회 메서드에 붙은 `async`를 동기 actor 프로토콜 선언에 맞게 제거했습니다. 메서드 본문은 유지했습니다. 테스트 빌드를 위해 일정 테스트 대역 두 곳도 새 조회 프로토콜에 맞췄으며, 준비되지 않은 호출은 `TestDoubleError.unconfigured`로 실패하도록 했습니다.

- 빌드 로그: `/private/tmp/flover9-rbac-actual-build.log`
- 실제 작업 트리 테스트 결과: `/private/tmp/flover9-rbac-actual-tests-2.xcresult`
- 검증용 사본의 선행 테스트: `/private/tmp/flover9-rbac-tests-3.xcresult`, `/private/tmp/flover9-rbac-final.xcresult`, `/private/tmp/flover9-rbac-theme.xcresult`

실제 로그인 계정으로 역할 변경·소유권 이전·R2 업로드를 수행하는 운영 서버 종단 간 검증은 아직 하지 않았습니다. 최초 어드민 계정도 별도 지정이 필요합니다.

## 역할 명칭 변경 — 2026-09-29

기존 owner는 admin(어드민), 기존 admin은 manager(매니저)로 변경했습니다. 역할별 권한 범위는 유지합니다. 관리자 화면이라는 메뉴 명칭은 운영 도구 전체를 의미합니다.

- `roles.manage_manager`: 매니저 부여·회수 (어드민 전용)
- `roles.transfer_admin`: 최상위 어드민 이전 (어드민 전용)
- 기존 감사 이력은 당시 역할 코드로 보존하고 별도 이름 변경 이력을 추가합니다.
- 역할 이름 변경 후 실제 앱 빌드와 선택 테스트 32개 통과: `/private/tmp/flover9-role-rename-tests.xcresult`.
- 운영 DB: 사용자 요청에 따라 기존 계정 2개 모두 admin입니다.

### 복수 어드민 허용

사용자 요청에 따라 어드민 1명 제한을 해제하고 기존 계정 2개 모두 admin으로 지정했습니다. 각 계정의 권한 15개를 운영 DB에서 확인했습니다. 마지막 어드민 보존 트리거와 역할 변경 감사 기록은 유지합니다.
