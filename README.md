# DimigoinKit
![DimigoinKit](imgs/DimigoinKit.png)
![License](https://img.shields.io/github/license/dimigoin/DimigoinKit?style=for-the-badge)
![Release](https://img.shields.io/github/v/release/dimigoin/DimigoinKit?style=for-the-badge)
> 디미고인의 iOS/macOS개발을 위한 디미고인 API

MVVM아키텍쳐 중 Model과 ViewModel이 구현되어 있습니다.

## ✅ 요구사항
* iOS 14+
* macOS 11+
* Xcode 12
* Swift 5.1+

## 🛠 설치
### Swift Package Manager
```Swift
.package(url: "https://github.com/dimigoin/DimigoinKit", from: "2.0.1"),
```

## 사용예시
더욱 자세한 내용은 [DimigoinKit 문서(링크)](https://dimigoin.github.io/DimigoinKit/Classes/DimigoinAPI.html)를 확인하세요.
### 선언
```Swift
import DimigoinKit

@ObservedObject var api = DimigoinAPI()
```

### 로그인/로그아웃
```Swift
import DimigoinKit

@ObservedObject var api = DimigoinAPI()

// 로그인 요청
api.login("USERNAME", "PASSWORD") { result in
    if result == true {
        // 로그인 성공
    } else {
        // 로그인 실패
    }
}

// 로그아웃, 기기에 저장된 토큰을 삭제합니다.
api.logout()
```

> 로그인 성공시 모든 데이터가 자동으로 패치 됩니다.

### 사용 가능한 데이터

```Swift
/// 디미고인 API 전반에 걸쳐 활용되는 JWT토큰
@Published public var accessToken = ""

/// 토큰 새로고침에 사용되는 `refreshToken`
@Published public var refreshToken = ""

/// 로그인 이력이 있으면 `true` 없으면 `false`
@Published public var isLoggedIn = true

/// 이름, 학년, 반 등 사용자에 대한 데이터
@Published public var user = User()

/// 주간 급식 - `meals[0]`부터 월요일 급식
@Published public var meals = [Meal](repeating: Meal(), count: 7)

/// 모바일용 사용자 맞춤 `Place`
@Published public var primaryPlaces: [Place] = []

/// 디미고내 모든 장소 `Place`
@Published public var allPlaces: [Place] = []

/// 사용자의 최근 `Place`
@Published public var currentPlace: Place = Place()

/// 시간표 리스트 `getLectureName()` 로 접근 (추천)
@Published public var lectureList: [Lecture] = []

/// 인강 데이터
@Published public var ingangs: [Ingang] = [
    Ingang(date: getToday8DigitDateString(), time: .NSS1, applicants: []),
    Ingang(date: getToday8DigitDateString(), time: .NSS2, applicants: [])
]

/// 주간 최대 인강실 신청
@Published public var weeklyTicketCount: Int = 0

/// 주간 사용한 인강실 신청 티켓
@Published public var weeklyUsedTicket: Int = 0

=======

## 사용예시
더욱 자세한 내용은 [DimigoinKit 문서(링크)](https://dimigoin.github.io/DimigoinKit/Classes/DimigoinAPI.html)를 확인하세요.
### 선언
```Swift
import DimigoinKit

@ObservedObject var api = DimigoinAPI()
```
