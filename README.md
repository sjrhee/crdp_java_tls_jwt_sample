# CRDP Java Simple Demo

**단 하나의 파일**로 CRDP API 테스트하기! HTTPS/TLS + JWT 인증 지원

## ✨ 특징

- 🚀 **하나의 파일** - SimpleDemo.java 만으로 모든 기능
- 📦 **외부 의존성 없음** - 순수 Java만 사용
- ⚡ **빠른 실행** - 컴파일하고 바로 실행
- 🔐 **HTTPS/TLS** - 자체 서명 인증서 지원
- 🎫 **JWT 인증** - RS256 (RSA + SHA256)

## 요구사항

- Java 8+
- OpenSSL (키 생성 시)

## 30초 빠른 시작

```bash
# 1️⃣ 키 생성 및 토큰 생성 (Python 또는 OpenSSL)
python3 create_jwt.py
# 또는 수동: openssl genrsa -out jwt_signing_key.pem 2048

# 2️⃣ SimpleDemo.properties에 토큰 설정
vi SimpleDemo.properties

# 3️⃣ 클라이언트 테스트 (공개키 배포 완료 후)
java SimpleDemo
```

## 출력 예시

```
=== CRDP 간단 데모 ===
서버: https://192.168.0.233:32182
정책: P01
데이터: 1234567890123

1. 데이터 보호 중... 성공: 435b7e99fdf33e10a29e4708710cacc2
2. 데이터 복원 중... 성공: 1234567890123

3. 검증 결과:
   원본: 1234567890123
   복원: 1234567890123
   일치: 예
```

## 빠른 테스트

```bash
# 1️⃣ 키 생성 및 토큰 생성
python3 create_jwt.py

# 2️⃣ Java 클라이언트 테스트 (공개키 배포 후)
java SimpleDemo

# 3️⃣ (선택) Python으로 다른 알고리즘 테스트
# config.yaml에서 algorithm 변경 후 다시 실행
python3 create_jwt.py
```

### SimpleDemo.properties 파일

기본값을 외부 설정 파일에서 관리할 수 있습니다:

```properties
# 서버 주소
host=192.168.0.233

# 서버 포트
port=32182

# TLS/HTTPS 활성화
tls=true

# 보호 정책명
policy=P01

# 테스트 데이터
data=1234567890123

# HTTP 타임아웃 (초 단위)
timeout=10

# JWT Bearer 토큰 (setup_jwt.sh에서 자동 생성)
token=eyJhbGciOiJSUzI1NiIs...
```

### 사용 방법

SimpleDemo.properties 파일을 수정하면 재컴파일 없이 설정이 적용됩니다:

```bash
# 1. 파일 수정
vi SimpleDemo.properties

# 2. 실행 (변경된 설정 자동 적용)
java SimpleDemo
```

## 파일 구조

```
.
├── SimpleDemo.java              # 🎯 Java CRDP 클라이언트
├── SimpleDemo.properties        # ⚙️ Java 설정 파일
├── create_jwt.py                # 🐍 Python JWT 생성 (RS/EC/PSS)
├── config.yaml                  # ⚙️ Python 설정 파일
└── keys/                        # 생성된 키 저장소
    ├── jwt_signing_key.pem      # 개인키 (🔒 비밀)
    ├── jwt_signing_pub.pem      # 공개키 (배포용)
    └── jwt_token.txt            # 생성된 JWT 토큰
```

## 생성 파일

```
jwt_signing_key.pem              # 개인키 (🔒 비밀 보관)
jwt_signing_pub.pem              # 공개키 (서버에 배포)
```

## JWT 생성 - 두 가지 방법

### 1️⃣ Python 스크립트 (create_jwt.py) - 권장 ⭐

**더 많은 알고리즘 지원** - RS256, ES256, PS256 등

```bash
# 필수 설정 (선택사항)
pip install PyYAML  # config.yaml 파싱 시 사용

# 실행
python3 create_jwt.py
```

**특징:**
- config.yaml에서 알고리즘 선택 가능
  - RSA: RS256, RS384, RS512
  - ECDSA: ES256, ES384, ES512  
  - RSA-PSS: PS256, PS384, PS512
- OpenSSL 기반 (외부 라이브러리 불필요)
- JWT 토큰을 keys/jwt_token.txt에 저장

**config.yaml 설정:**
```yaml
algorithm: RS256        # RS256, ES256, PS256 등
issuer: "CRDP03"
user_id: "user01"
expiry_days: 30
key_dir: "./keys"
use_existing_keys: false
```

### 2️⃣ 수동 (OpenSSL)

**완전한 제어** - 세세한 설정 가능

```bash
# 1. RSA 키 생성 (2048 비트)
openssl genrsa -out jwt_signing_key.pem 2048
openssl rsa -in jwt_signing_key.pem -pubout -out jwt_signing_pub.pem

# 2. JWT 페이로드 생성 (JSON)
echo '{"iss":"issuer","sub":"user01","iat":'$(date +%s)',"exp":'$(($(date +%s)+3600))'}' > payload.json

# 3. Base64URL 인코딩 (헤더 + 페이로드)
HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | base64 | tr '+/' '-_' | tr -d '=')
PAYLOAD=$(cat payload.json | base64 | tr '+/' '-_' | tr -d '=')

# 4. 서명 생성
SIGNATURE=$(echo -n "$HEADER.$PAYLOAD" | openssl dgst -sha256 -sign jwt_signing_key.pem | base64 | tr '+/' '-_' | tr -d '=')

# 5. JWT 토큰 조합
JWT="$HEADER.$PAYLOAD.$SIGNATURE"
echo $JWT
```

## 수동 실행

```bash
# 컴파일
javac SimpleDemo.java

# 실행
java SimpleDemo
java SimpleDemo --data "1234567890123"
```

## 코드 설명

`SimpleDemo.java` - 모든 기능이 포함된 단일 파일

**주요 메서드:**

- `main()` - 프로그램 진입점, properties 파일 로드
- `protect()` - /v1/protect API 호출 (데이터 보호)
- `reveal()` - /v1/reveal API 호출 (데이터 복원)
- `post()` - HTTP/HTTPS POST 요청 처리
- `extractValue()` - JSON 응답에서 값 추출

**특징:**

- ✅ 순수 Java (외부 의존성 없음)
- ✅ HTTPS 지원 (자체 서명 인증서 자동 처리)
- ✅ JWT Bearer 토큰 인증
- ✅ JSON 파싱 (간단한 수동 파서)
- ✅ 설정 파일 기반 (properties)

## 문서

- 📖 [JWT_GUIDE.md](./JWT_GUIDE.md) - JWT 생성 및 검증 상세 가이드
- ⚡ [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - 명령어 빠른 참조

## 관련 링크

- 📘 [CRDP API 공식 문서](https://thalesdocs.com/ctp/con/crdp/latest/crdp-apis/index.html)
- 🔐 [JWT.io - JWT 토큰 디버거](https://jwt.io)
- 🔑 [OpenSSL 공식 사이트](https://www.openssl.org/)
