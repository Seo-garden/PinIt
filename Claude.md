# CLAUDE.md

## 프로젝트 개요
이 프로젝트는 **UIKit + Tuist + Clean Architecture + RxSwift** 기반의 iOS 앱입니다.
계층 간 의존성은 반드시 **단방향(Inward)** 을 유지해야 합니다.

---

## 아키텍처 원칙

### Clean Architecture 계층 구조 및 의존성 방향

```
Presentation → Domain ← Data
```

- **Presentation**: ViewController, ViewModel (ViewModel은 Domain의 UseCase에만 의존)
- **Domain**: Entity, UseCase, Repository Interface (외부 계층에 의존하지 않음 — 순수 Swift)
- **Data**: Repository 구현체, DataSource, Network, DB (Domain의 Interface를 구현)

> ⚠️ 절대 금지: Presentation → Data 직접 참조, Domain → Presentation/Data 참조

### 의존성 주입
- 모든 의존성은 **생성자 주입(Constructor Injection)** 을 원칙으로 합니다.
- Protocol을 통해 계층 간 결합도를 낮춥니다.

---

## 기술 스택

| 역할 | 기술 |
|------|------|
| UI | UIKit (코드 기반, Storyboard 사용 안 함) |
| 반응형 | RxSwift / RxCocoa |
| 프로젝트 관리 | Tuist |
| 아키텍처 | Clean Architecture + MVVM |
| 의존성 관리 | Swift Package Manager (Tuist 연동) |

---

## 코드 컨벤션

### 네이밍
- ViewController: `[기능]ViewController` (예: `LoginViewController`)
- ViewModel: `[기능]ViewModel` (예: `LoginViewModel`)
- UseCase: `[동사+명사]UseCase` (예: `FetchUserUseCase`)
- Repository Protocol: `[명사]Repository` (예: `UserRepository`)
- Repository 구현체: `[명사]DefaultRepository` (예: `DefaultUserRepository`)
- Entity: 순수 Swift struct, 외부 프레임워크 import 금지

### RxSwift 패턴
- ViewModel은 `Input` / `Output` 구조체를 사용하는 **transform 패턴** 적용
- DisposeBag은 각 ViewController / ViewModel이 소유
- Side Effect는 반드시 명시적으로 분리 (`bind`, `subscribe` 최소화, `drive` / `emit` 선호)

```swift
// ViewModel 예시 구조
protocol [기능]ViewModelInput { ... }
protocol [기능]ViewModelOutput { ... }
protocol [기능]ViewModelType {
    var input: [기능]ViewModelInput { get }
    var output: [기능]ViewModelOutput { get }
}
```

### UIKit
- AutoLayout은 **코드로만** 작성 
- `viewDidLoad`에서 `setupUI()`, `setupLayout()`, `bind()` 순서로 호출
- ViewController는 비즈니스 로직을 포함하지 않음

---

## Tuist 프로젝트 구조

```
Projects/
├── App/          # 앱 진입점, 루트 DI 조립, SceneDelegate
├── Presentation/ # ViewController, ViewModel (UIKit, RxCocoa)
├── Domain/       # UseCase, Entity, Repository Interface (순수 Swift)
├── Data/         # Repository 구현체, DataSource, Network, DB
└── Core/         # 공통 유틸, Extension, Base 클래스
```

- 각 Feature는 독립 모듈로 관리하며 순환 참조를 허용하지 않습니다.
- `Project.swift`에서 타겟 간 의존성을 명시적으로 선언합니다.

---

## 작업 시 주의사항

1. **새 파일 생성 시** 항상 올바른 계층 디렉토리에 위치시킵니다.
2. **import 확인**: Domain 계층 파일에 `RxSwift` 외 외부 프레임워크 import는 재고합니다.
3. **Protocol 우선**: 구체 타입 대신 Protocol 타입을 파라미터로 사용합니다.
4. **Unit Test 가능성**: UseCase, ViewModel은 테스트 가능하도록 의존성을 외부에서 주입받습니다.
5. **Tuist generate** 후 `.xcodeproj`를 직접 수정하지 않습니다.

---

## 자주 쓰는 명령어

```bash
# 프로젝트 생성
tuist generate

# 캐시 초기화
tuist clean

# 의존성 fetch
tuist install
```

---

## 코드 생성 요청 시 기본 규칙

- 계층을 명시하지 않아도 **Clean Architecture 계층에 맞게** 파일을 분리해서 제안합니다.
- RxSwift 코드는 **메모리 누수 방지**를 위해 `[weak self]` 캡처를 기본으로 합니다.
- 테스트 코드가 필요한 경우 `XCTest + RxTest(RxBlocking)` 기반으로 작성합니다.