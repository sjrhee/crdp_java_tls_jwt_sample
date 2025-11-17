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
- **⚠️ CTM 관리자**: CRDP 서버의 JWT 검증 설정 필요 (아래 참고)

---

## ⚠️ CTM 관리자 필독 (전제 조건)

이 클라이언트를 사용하기 전에 **CTM CRDP 서버에서 JWT 검증을 활성화**해야 합니다.

### 설정 위치
**CTM Console → CRDP Application → JWT Verification 설정**

### 상세 설정 방법
📘 [Thales CTM CRDP 관리 가이드](https://thalesdocs.com/ctp/cm/latest/admin/adp_ag/adp-cm-crdp/defn-app-crdp/index.html)를 참고하여 다음을 수행하세요:

1. **CTM Console** 접속
2. **Administration** → **Applications** → **CRDP** 선택
3. **JWT Verification** 섹션에서:
   - ✅ **Enable JWT Verification** 활성화
   - 🔑 **Public Key** 설정 (클라이언트의 공개키 `keys/jwt_key_public.pem` 내용 복사)
   - 🔐 **Signature Algorithm** 설정 (RS256, ES256 등 - 클라이언트와 동일해야 함)
   - 💬 **Required Claims** 설정 (필요한 클레임 정의)

### 클라이언트 측 확인
```bash
# 공개키 확인 (CTM에 입력할 내용)
cat keys/jwt_key_public.pem

# 알고리즘 확인 (config.yaml에서)
cat config.yaml | grep algorithm

# 토큰 클레임 확인 (decode)
python3 -c "
import base64, json
token = open('keys/jwt_token.txt').read().strip()
parts = token.split('.')
payload = json.loads(base64.urlsafe_b64decode(parts[1] + '=='))
print(json.dumps(payload, indent=2))
"
```

**문제 발생 시:**
- `token is missing required claim` → CTM에서 Required Claims 설정 확인
- `token signature is invalid` → 공개키가 정확히 입력되었는지 확인
- `unsupported algorithm` → 알고리즘 설정이 일치하는지 확인

---

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

## 설정 관리 (SimpleDemo.properties)

**모든 설정은 SimpleDemo.properties 파일에서 관리합니다** (명령어 줄 옵션 없음)

### 설정 파일 예시

```properties
# CRDP 서버 주소
host=192.168.0.233

# CRDP 서버 포트
port=32182

# 보호 정책명
policy=P01

# 테스트 데이터
data=1234567890123

# HTTP 타임아웃 (초 단위)
timeout=2

# HTTPS/TLS 활성화
tls=true

# JWT Bearer 토큰 (create_jwt.py에서 생성)
token=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 사용 방법

```bash
# 1. 파일 수정 (원하는 설정값 변경)
vi SimpleDemo.properties

# 2. 재컴파일 불필요 - 바로 실행
java SimpleDemo
```

**⚠️ 주의:**
- 명령어 줄 옵션은 지원하지 않습니다
- 모든 설정은 SimpleDemo.properties에서만 관리합니다
- 파일 수정 후 재컴파일 불필요

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

# 실행 (모든 설정은 SimpleDemo.properties에서 읽음)
java SimpleDemo
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
