# Firebase Error Logging Classification

## Do Not Record

정상적인 사용자 행동이거나 화면에서 안내하는 것으로 충분한 오류입니다.

- `AuthError.cancelled`
- `ProfileError.invalidNickname`

## Firebase Analytics

발생 빈도와 사용자 흐름에 미치는 영향을 확인하기 위한 오류입니다.

- `AuthError.sessionExpired`
- `AuthError.networkUnavailable`
- `ProfileError.nicknameAlreadyExists`
- `ProfileError.networkUnavailable`

## Firebase Crashlytics

개발자가 원인을 조사해야 하는 비정상적인 오류입니다.

- `AuthError.unknown`
- `ProfileError.invalidRole`
- `ProfileError.invalidProfileData`
- `ProfileError.unknown`

## Analytics + Crashlytics

발생 빈도 분석과 기술적인 원인 조사가 모두 필요한 중요 오류입니다.

- `AuthError.invalidAppleCredential`
- `AuthError.serverUnavailable`
- `AuthError.accountDeletionFailed`
- `ProfileError.notFound`
- `ProfileError.permissionDenied`
- `ProfileError.serverUnavailable`

## Context-Dependent Classification

`unauthenticated`는 발생한 작업과 시점에 따라 기록 여부를 결정합니다.

- 앱 시작 시 저장된 세션이 없는 경우
  - 기록하지 않음

- Apple 로그인 직후 세션이 없는 경우
  - Analytics + Crashlytics

- 프로필 조회 중 세션이 없는 경우
  - Analytics

- 회원탈퇴 중 세션이 없는 경우
  - Analytics + Crashlytics
