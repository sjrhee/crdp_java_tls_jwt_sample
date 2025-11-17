# 📁 프로젝트 구조

## 디렉토리 레이아웃

```
crdp_java_sample/
├── 📖 문서 (3개)
│  ├── README.md                 # 🔴 시작하기 (여기서부터!)
│  ├── JWT_GUIDE.md              # JWT 생성 상세 가이드
│  └── QUICK_REFERENCE.md        # 명령어 빠른 참조
│
├── 🎯 Java 클라이언트
│  ├── SimpleDemo.java           # CRDP Protect/Reveal 테스트
│  └── SimpleDemo.properties     # Java 설정 (서버, 포트, 토큰 등)
│
├── 🐍 Python JWT 생성 도구
│  ├── create_jwt.py             # JWT 토큰 생성 (RS/EC/PSS 지원)
│  └── config.yaml               # Python 설정 (알고리즘, 유효기간 등)
│
├── 🔐 생성된 키와 토큰
│  └── keys/
│     ├── jwt_key_private.pem    # 개인키 (🔒 비밀 보관!)
│     ├── jwt_key_public.pem     # 공개키 (✅ 서버에 배포)
│     └── jwt_token.txt          # 생성된 JWT 토큰
│
└── .gitignore                   # Git 제외 파일 목록
```

---

## 각 파일 설명

### 📖 문서 (Documentation)

| 파일 | 용도 | 대상 |
|-----|------|------|
| **README.md** | 프로젝트 소개 및 5분 시작 가이드 | 모든 사용자 |
| **JWT_GUIDE.md** | JWT 생성 방법 (Python + 수동 OpenSSL) | 개발자 |
| **QUICK_REFERENCE.md** | 자주 사용하는 명령어 모음 | 모든 사용자 |
| **PROJECT_STRUCTURE.md** | 이 문서 - 파일 구조 설명 | 관리자 |

### 🎯 Java 클라이언트 (Client)

| 파일 | 역할 | 크기 |
|-----|------|------|
| **SimpleDemo.java** | 단일 파일로 모든 기능 제공 | ~11KB |
| **SimpleDemo.properties** | 런타임 설정 (재컴파일 불필요) | ~535B |

**SimpleDemo.java의 기능:**
- ✅ HTTPS 클라이언트 (자체 서명 인증서 지원)
- ✅ JWT Bearer 토큰 인증
- ✅ CRDP Protect API 호출
- ✅ CRDP Reveal API 호출
- ✅ 간단한 JSON 파싱
- ✅ Properties 파일 기반 설정

**SimpleDemo.properties의 설정:**
```properties
host=192.168.0.233              # CRDP 서버 주소
port=32182                      # 포트
policy=P01                      # 보호 정책
data=1234567890123              # 테스트 데이터
timeout=2                       # HTTP 타임아웃 (초)
tls=true                        # HTTPS 사용 여부
token=eyJhbGci...               # JWT Bearer 토큰
```

### 🐍 Python JWT 생성 도구 (JWT Generation)

| 파일 | 역할 | 크기 |
|-----|------|------|
| **create_jwt.py** | OpenSSL 기반 JWT 생성 (다양한 알고리즘 지원) | ~13KB |
| **config.yaml** | Python 설정 (알고리즘, 키 크기, 유효기간) | ~678B |

**지원하는 알고리즘:**
- RSA: RS256, RS384, RS512
- ECDSA: ES256, ES384, ES512
- RSA-PSS: PS256, PS384, PS512

**config.yaml의 설정:**
```yaml
algorithm: RS256                # 선택할 알고리즘
issuer: "CRDP03"                # JWT iss 클레임
user_id: "user01"               # JWT sub 클레임
expiry_days: 30                 # 토큰 유효기간
key_dir: "./keys"               # 키 저장 디렉토리
use_existing_keys: false        # 기존 키 재사용 여부
```

### 🔐 생성된 키와 토큰 (Generated Keys & Tokens)

**keys/ 디렉토리:**
```
keys/
├── jwt_key_private.pem         # 개인키 (비밀!)
│  └── 🔒 .gitignore에 등재됨
├── jwt_key_public.pem          # 공개키 (배포)
│  └── ✅ 서버에 배포 필요
└── jwt_token.txt               # 생성된 JWT
   └── SimpleDemo.properties에 복사
```

**파일 권한:**
- 개인키: 600 (소유자만 읽기/쓰기) - 비밀 보관!
- 공개키: 644 (모두 읽기 가능) - 배포 가능
- 토큰: 644 (모두 읽기 가능)

---

## 워크플로우

### 1️⃣ JWT 토큰 생성 (처음 1회)

```bash
# Python으로 생성
python3 create_jwt.py

# 생성 결과
# ✅ keys/jwt_key_private.pem 생성
# ✅ keys/jwt_key_public.pem 생성
# ✅ keys/jwt_token.txt 생성 (토큰 내용 저장)
```

### 2️⃣ 토큰을 SimpleDemo.properties에 복사

```bash
# 생성된 토큰 확인
cat keys/jwt_token.txt

# SimpleDemo.properties의 token= 값 업데이트
vi SimpleDemo.properties
```

### 3️⃣ 공개키를 서버에 배포

```bash
# 공개키 내용 확인
cat keys/jwt_key_public.pem

# CRDP 서버 관리자에게 배포 (상세는 JWT_GUIDE.md 참고)
```

### 4️⃣ Java 클라이언트 실행

```bash
# 컴파일 (처음 1회)
javac SimpleDemo.java

# 실행
java SimpleDemo

# 재컴파일 불필요 (properties만 변경하면 됨)
```

---

## 파일 크기 요약

| 항목 | 크기 | 설명 |
|-----|------|------|
| SimpleDemo.java | 11KB | 단일 클라이언트 |
| create_jwt.py | 13KB | JWT 생성 스크립트 |
| 문서 (3개) | ~16KB | README, JWT_GUIDE, QUICK_REFERENCE |
| 설정 파일 (2개) | ~1.2KB | properties, yaml |
| **총합** | **~41KB** | 매우 가볍다! |

---

## Git 관리

### .gitignore 적용

```
# 버전 관리 제외 (매번 생성)
*.class                         # Java 컴파일 파일

# 버전 관리 포함 (필수)
SimpleDemo.java                 # 소스 코드
create_jwt.py                   # JWT 생성 스크립트

# 버전 관리 포함 (선택)
SimpleDemo.properties           # 설정 (token 포함 - 주의!)
config.yaml                     # 설정

# 버전 관리 제외 (민감한 데이터)
keys/jwt_key_private.pem        # 개인키 (🔒 비밀!)
```

### 권장 .gitignore 설정 (본 프로젝트)

```gitignore
# Java 컴파일 파일
*.class

# IDE
.idea/
.vscode/
*.iml

# OS
.DS_Store
Thumbs.db

# 임시 파일
*.tmp
*.swp
*~
```

**⚠️ 주의:**
- 개인키 `keys/jwt_key_private.pem`는 절대 Git에 커밋하지 마세요!
- SimpleDemo.properties (토큰 포함)도 주의해서 관리하세요!

---

## 확장 및 커스터마이징

### Java 클라이언트 수정

**현재 기능:**
- HTTPS/TLS 지원
- JWT 인증
- Protect/Reveal API

**추가 가능한 기능:**
- 다중 정책 지원
- 배치 처리
- 로깅 추가
- 에러 핸들링 강화

### Python 스크립트 수정

**현재 기능:**
- RSA, ECDSA, RSA-PSS 지원
- OpenSSL 기반

**추가 가능한 기능:**
- 토큰 검증
- 토큰 갱신 자동화
- GUI 추가

---

## 자주 묻는 질문

### Q: 파일을 어디서 찾나요?
**A:** 모두 프로젝트 루트 (`./`)에 있습니다. 복잡한 디렉토리 구조 없음!

### Q: 클래스 파일은 어디?
**A:** 컴파일 시 생성되며, `.gitignore`에 의해 제외됩니다. 필요하면 `javac SimpleDemo.java`로 수동 생성.

### Q: 개인키를 잃어버렸어요
**A:** `python3 create_jwt.py` 실행으로 새 키 쌍 생성. 이후 공개키를 서버에 재배포 필요.

### Q: 설정 파일을 깃허브에 푸시해도 되나요?
**A:** SimpleDemo.properties (토큰 포함)는 민감하므로 주의! 보안 정책에 따라 제외 고려.

---

## 체크리스트

### 프로젝트 초기 설정

- [ ] `python3 create_jwt.py` 실행
- [ ] `keys/jwt_token.txt` 내용 확인
- [ ] `SimpleDemo.properties`의 `token=` 값 업데이트
- [ ] `javac SimpleDemo.java` 컴파일
- [ ] `java SimpleDemo` 실행 테스트
- [ ] 공개키 (`keys/jwt_key_public.pem`) 서버에 배포
- [ ] 최종 테스트 (`java SimpleDemo`)

### 배포 전 체크리스트

- [ ] 개인키 (`keys/jwt_key_private.pem`) 안전하게 보관
- [ ] 공개키 (`keys/jwt_key_public.pem`) 서버에 배포됨 확인
- [ ] SimpleDemo.properties의 host, port 정확한지 확인
- [ ] .gitignore 확인 (민감 파일 제외)
- [ ] 최신 코드가 Git에 커밋됨 확인

---

## 참고 자료

- 📘 [CRDP API 공식 문서](https://thalesdocs.com/ctp/con/crdp/latest/crdp-apis/index.html)
- 🔐 [JWT.io](https://jwt.io) - JWT 디버거
- 🔑 [OpenSSL 공식](https://www.openssl.org/)
- 🐍 [Python 공식](https://www.python.org/)
- ☕ [Java 공식](https://www.java.com/)
