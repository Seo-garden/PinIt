# PinIt

## 1) PinIt 소개

PinIt은 **사진 + 캡션 + 장소**를 하나의 기록으로 저장하고, 이를 지도에서 확인하는 iOS 앱입니다.

## 2) 기능 요구사항 (요약)

- 이메일/비밀번호 기반 인증
- 사진/캡션/장소를 포함한 기록 추가
- 지도에서 기록 확인
- 기록 삭제
- 캡션 수정(자동 저장)

## 3) 기술 스택 / 구조

### 아키텍처

**Clean Architecture + MVVM**. 계층 간 의존성은 `Presentation → Domain ← Data` 의 단방향을 유지합니다.

### 모듈 구성 (Tuist)

```
Projects/
├── App/          — 앱 진입점, DI 컨테이너(AppDIContainer), Flow 라우팅
├── Presentation/ — ViewController / ViewModel (UIKit + RxCocoa, Input/Output 패턴)
├── Domain/       — Entity, UseCase, Repository 인터페이스 (외부 의존 없는 순수 Swift)
├── Data/         — Repository 구현체 (Mock 인증, CoreLocation, MapKit, In-Memory Record 등)
└── Core/         — 공통 Extension, Base 클래스, 유틸리티
```

**의존 방향**
- `App` → `Presentation` / `Domain` / `Data` / `Core`
- `Presentation` → `Domain` / `Core`
- `Data` → `Domain`
- `Domain`은 어떤 외부 계층에도 의존하지 않음

### 주요 기술

| 분류 | 사용 기술 |
|---|---|
| 언어 / 플랫폼 | Swift 6, iOS 17.0+ |
| UI | UIKit (코드 기반, Storyboard 미사용), AutoLayout |
| 반응형 | RxSwift 6 / RxCocoa |
| 프로젝트 관리 | Tuist 4 (SPM 연동) |
| 위치/지도 | MapKit, CoreLocation |
| 사진 | PhotosUI, PHPickerViewController |
| 영속성 | UserDefaults (세션), In-Memory (기록) |

### 주요 패턴

- **ViewModel Input/Output transform 패턴** — ViewController는 이벤트를 `Input`으로 방출하고 `Output`을 `drive`/`emit`으로 소비
- **생성자 주입(Constructor Injection)** — 모든 의존성은 Protocol 기반으로 주입, 테스트 용이성 확보
- **Coordinator** — 화면 전환과 의존성 전달을 ViewController 외부로 분리

## 4) 실행 방법

1. Tuist 설치 및 버전 확인

```bash
curl -Ls https://install.tuist.io | bash
tuist version
```

2. 의존성 설치 및 프로젝트 생성

```bash
tuist install
tuist generate
```

3. Xcode에서 실행

- 생성된 `PinIt.xcworkspace`를 열어 `App` 스킴을 실행합니다.

## 5) 테스트 계정 (Mock 로그인)

현재 인증은 백엔드 서버 준비 전까지 **Mock으로 동작**합니다. 로그인 화면에서 아래 계정으로 진입할 수 있습니다.

| 이메일 | 비밀번호 |
|---|---|
| `test@pinit.com` | `password1234` |

- 다른 값으로 로그인 시 "이메일 또는 비밀번호가 일치하지 않습니다" 에러가 표시됩니다.
- 로그인 상태는 `UserDefaults`에 저장되어 앱 재실행 시 유지됩니다.
- 네트워크 지연을 흉내내기 위해 각 인증 요청은 약 0.3초의 지연을 포함합니다.
- 백엔드 서버 준비 완료 시 `Data` 계층의 `DefaultAuthRepository` / `DefaultAuthSessionRepository` 구현만 실제 API 호출로 교체하면 됩니다.

## 6) 시연영상
- 갤러리 동작
https://github.com/user-attachments/assets/f90268ad-f104-465a-a242-472cb3c039e5

- 갤러리를 제외한 동작
https://github.com/user-attachments/assets/31299c51-fe3b-48b9-99de-f2af215f444e
