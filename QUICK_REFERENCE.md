# 📖 빠른 참조 (Quick Reference)

## 🚀 가장 먼저 읽어야 할 것

1. **처음 사용하시나요?** → [README.md](./README.md) - 30초 시작 가이드
2. **JWT 생성이 필요해요?** → [JWT_GUIDE.md](./JWT_GUIDE.md) - 상세 JWT 설정
3. **명령어 요약만 필요해요?** → 이 문서 (계속 읽기)

---

## ⚡ 5분 시작 가이드

### 1단계: JWT 토큰 생성

```bash
# Python 스크립트로 키 + 토큰 생성 (권장)
python3 create_jwt.py

# 또는 수동으로 (OpenSSL)
openssl genrsa -out keys/jwt_signing_key.pem 2048
openssl rsa -in keys/jwt_signing_key.pem -pubout -out keys/jwt_signing_pub.pem
```

### 2단계: 토큰을 properties 파일에 추가

```bash
# 생성된 토큰 확인
cat keys/jwt_token.txt

# SimpleDemo.properties의 token= 값 업데이트
vi SimpleDemo.properties
```

### 3단계: Java 클라이언트 테스트 (공개키 배포 후)

```bash
# 컴파일
javac SimpleDemo.java

# 실행
java SimpleDemo
```

---

## 📚 상황별 명령어

### JWT 토큰 생성

| 목적 | 명령어 |
|-----|--------|
| Python으로 생성 (권장) | `python3 create_jwt.py` |
| config 설정 수정 | `vi config.yaml` |
| 생성된 토큰 확인 | `cat keys/jwt_token.txt` |
| 공개키 확인 | `cat keys/jwt_signing_pub.pem` |
| 공개키 SHA256 해시 | `openssl dgst -sha256 keys/jwt_signing_pub.pem` |

### Java 클라이언트

| 목적 | 명령어 |
|-----|--------|
| 컴파일 | `javac SimpleDemo.java` |
| 실행 | `java SimpleDemo` |
| 컴파일 + 실행 | `javac SimpleDemo.java && java SimpleDemo` |
| 클래스 파일 정리 | `rm -f *.class` |

### 설정 관리

| 목적 | 명령어 |
|-----|--------|
| Java 설정 파일 수정 | `vi SimpleDemo.properties` |
| Python 설정 파일 수정 | `vi config.yaml` |
| 현재 설정 확인 | `cat SimpleDemo.properties` |

---

## 🔧 Python 스크립트 옵션

### config.yaml 알고리즘 선택

```yaml
# RSA
algorithm: RS256   # 또는 RS384, RS512

# ECDSA
algorithm: ES256   # 또는 ES384, ES512

# RSA-PSS
algorithm: PS256   # 또는 PS384, PS512
```

### 토큰 유효기간 수정

```yaml
expiry_days: 30    # 원하는 일수로 변경
```

---

## 📝 SimpleDemo.properties 설정값

| 설정값 | 예시 | 설명 |
|--------|------|------|
| `host` | `192.168.0.233` | CRDP 서버 주소 |
| `port` | `32182` | CRDP 서버 포트 |
| `policy` | `P01` | 데이터 보호 정책명 |
| `data` | `1234567890123` | 테스트 데이터 |
| `timeout` | `2` | HTTP 타임아웃 (초) |
| `tls` | `true` | HTTPS 사용 여부 |
| `token` | `eyJ...` | JWT Bearer 토큰 |

---

## 🐛 자주 만나는 문제

### "token is missing required claim"
```
원인: JWT 토큰에 필요한 클레임이 없음
해결: JWT_GUIDE.md의 "JWT 토큰 검증" 섹션 참고
```

### "Connection refused"
```
원인: CRDP 서버 주소/포트 잘못됨
해결: SimpleDemo.properties의 host, port 확인
```

### "SSL Certificate Verify Failed"
```
원인: 자체 서명 인증서 (정상)
해결: SimpleDemo.java가 자동으로 처리 (별도 설정 불필요)
```

### "NoClassDefFoundError"
```
원인: 이전 컴파일 파일 충돌
해결: rm -f *.class 후 재컴파일
```

---

## 📂 파일 구조

```
.
├── README.md                    # 📖 시작 가이드
├── JWT_GUIDE.md                 # 🔑 JWT 생성 상세 가이드
├── QUICK_REFERENCE.md           # ⚡ 이 문서
├── SimpleDemo.java              # 🎯 Java CRDP 클라이언트
├── SimpleDemo.properties        # ⚙️ Java 설정 파일
├── create_jwt.py                # 🐍 Python JWT 생성 스크립트
├── config.yaml                  # ⚙️ Python 설정 파일
└── keys/                        # 🔐 생성된 키 저장소
    ├── jwt_signing_key.pem      # 개인키 (비밀)
    ├── jwt_signing_pub.pem      # 공개키 (배포용)
    └── jwt_token.txt            # 생성된 JWT
```

---

## 🎯 처음부터 끝까지

```bash
# 1. JWT 생성
python3 create_jwt.py

# 2. 토큰 확인
cat keys/jwt_token.txt

# 3. SimpleDemo.properties 업데이트
vi SimpleDemo.properties
# token=... 값을 위 토큰으로 교체

# 4. 컴파일
javac SimpleDemo.java

# 5. 실행
java SimpleDemo
```

---

## 📞 도움말

- **JWT 생성 문제?** → [JWT_GUIDE.md](./JWT_GUIDE.md)
- **Java 실행 문제?** → [README.md](./README.md)의 "코드 설명" 섹션
- **설정 값?** → SimpleDemo.properties 주석 참고
