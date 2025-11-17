# JWT 생성 가이드

## 개요

JWT 토큰을 생성하는 두 가지 방법:

1. **Python 스크립트** (권장) - create_jwt.py
2. **수동 OpenSSL** - 완전한 제어 가능

---

## 방법 1️⃣: Python 스크립트 (create_jwt.py)

### 설치 및 실행

```bash
# 선택사항: PyYAML 설치 (config.yaml 자동 파싱용)
pip install PyYAML

# 실행
python3 create_jwt.py
```

### 출력

```
================================================================================
Regular JWT 생성 (Python)
================================================================================

📋 설정:
   알고리즘: RS256
   발급자: CRDP03
   사용자 ID: user01
   유효기간: 30일
   키 디렉토리: ./keys

🔑 키 생성 중...
   RSA 키 생성 중 (크기: 2048 bits)...
✅ 키 생성 완료:
   Private: ./keys/jwt_signing_key.pem
   Public:  ./keys/jwt_signing_pub.pem

🔨 JWT 생성 중...
✅ JWT 생성 완료

💾 토큰 저장: keys/jwt_token.txt

📌 JWT 토큰:
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MzE3NzM0MDAsImlzcyI6IkNSRFAw...

📖 토큰 정보:
   헤더: {"alg":"RS256","typ":"JWT"}
   페이로드: {"exp":1731773400,"iss":"CRDP03","sub":"user01"}
   만료: 2024-12-15 12:23:20 (1731773400)
```

### config.yaml 설정

```yaml
# 알고리즘 선택
algorithm: RS256        # RS256, RS384, RS512
                        # PS256, PS384, PS512 (RSA-PSS)
                        # ES256, ES384, ES512 (ECDSA)

# JWT 페이로드
issuer: "CRDP03"        # JWT iss 클레임
user_id: "user01"       # JWT sub 클레임
expiry_days: 30         # 토큰 유효기간 (일)

# 키 관리
key_dir: "./keys"       # 키 저장 디렉토리
key_name_prefix: "jwt_key"  # 키 파일명 prefix
use_existing_keys: false    # 기존 키 사용 여부
```

### 지원 알고리즘

| 알고리즘 | 타입 | 키 크기 | 용도 |
|---------|------|--------|------|
| RS256 | RSA | 2048 | 표준 (권장) |
| RS384 | RSA | 3072 | 고강도 |
| RS512 | RSA | 4096 | 고강도 |
| PS256 | RSA-PSS | 2048 | PSS 패딩 |
| PS384 | RSA-PSS | 3072 | PSS 패딩 |
| PS512 | RSA-PSS | 4096 | PSS 패딩 |
| ES256 | ECDSA | P-256 | 타원곡선 |
| ES384 | ECDSA | P-384 | 타원곡선 |
| ES512 | ECDSA | P-521 | 타원곡선 |

---

## 방법 2️⃣: 수동 OpenSSL

### 1. RSA 키 쌍 생성

```bash
# 2048 비트 개인키 생성
openssl genrsa -out jwt_signing_key.pem 2048

# 개인키에서 공개키 추출
openssl rsa -in jwt_signing_key.pem -pubout -out jwt_signing_pub.pem
```

### 2. JWT 페이로드 생성 (JSON)

```bash
# 현재 시간과 만료 시간 계산
NOW=$(date +%s)
EXP=$((NOW + 3600))  # 1시간 후 만료

# 페이로드 JSON 생성
PAYLOAD='{"iss":"CRDP03","sub":"user01","iat":'$NOW',"exp":'$EXP'}'

# 파일로 저장
echo "$PAYLOAD" > payload.json
```

### 3. Base64URL 인코딩 (헤더 + 페이로드)

```bash
# 헤더 인코딩
HEADER='{"alg":"RS256","typ":"JWT"}'
HEADER_B64=$(echo -n "$HEADER" | base64 | tr '+/' '-_' | tr -d '=')

# 페이로드 인코딩
PAYLOAD_B64=$(echo -n "$PAYLOAD" | base64 | tr '+/' '-_' | tr -d '=')

# 서명 입력값
SIGNING_INPUT="$HEADER_B64.$PAYLOAD_B64"
```

### 4. 서명 생성

```bash
# RS256 서명
SIGNATURE=$(echo -n "$SIGNING_INPUT" | openssl dgst -sha256 -sign jwt_signing_key.pem | base64 | tr '+/' '-_' | tr -d '=')

# 최종 JWT
JWT="$SIGNING_INPUT.$SIGNATURE"
echo $JWT
```

### 5. JWT 저장 및 사용

```bash
# JWT를 파일로 저장
echo "$JWT" > jwt_token.txt

# SimpleDemo.properties에 추가
echo "token=$JWT" >> SimpleDemo.properties

# Java 클라이언트 실행
java SimpleDemo
```

### 한 줄로 실행 (Bash 스크립트)

```bash
#!/bin/bash

NOW=$(date +%s)
EXP=$((NOW + 3600))
PAYLOAD='{"iss":"CRDP03","sub":"user01","iat":'$NOW',"exp":'$EXP'}'
HEADER='{"alg":"RS256","typ":"JWT"}'

HEADER_B64=$(echo -n "$HEADER" | base64 | tr '+/' '-_' | tr -d '=')
PAYLOAD_B64=$(echo -n "$PAYLOAD" | base64 | tr '+/' '-_' | tr -d '=')
SIGNING_INPUT="$HEADER_B64.$PAYLOAD_B64"

SIGNATURE=$(echo -n "$SIGNING_INPUT" | openssl dgst -sha256 -sign jwt_signing_key.pem | base64 | tr '+/' '-_' | tr -d '=')

JWT="$SIGNING_INPUT.$SIGNATURE"
echo $JWT
```

---

## JWT 토큰 검증

### jwt.io에서 검증

1. [jwt.io](https://jwt.io) 방문
2. "Encoded" 영역에 JWT 토큰 붙여넣기
3. "Decoded" 영역에서 페이로드 확인
4. "Verify Signature" 섹션에서:
   - "Public Key" 탭 선택
   - 공개키 (jwt_signing_pub.pem) 내용 붙여넣기

### 명령어로 검증

```bash
# JWT에서 페이로드 추출 및 디코딩
JWT="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
PAYLOAD=$(echo $JWT | cut -d. -f2)
echo $PAYLOAD | base64 -d
```

---

## SimpleDemo.properties 설정

JWT 토큰을 생성한 후 SimpleDemo.properties에 추가:

```properties
host=192.168.0.231
port=32182
policy=P01
data=1234567890123
timeout=2
tls=true

# 생성된 JWT 토큰 추가
token=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJDUkRQMDMiLCJzdWIiOiJ1c2VyMDEiLCJpYXQiOjE3MzE2ODY3MDAsImV4cCI6MTczMTY5MDMwMH0...
```

---

## 트러블슈팅

### Python 스크립트 오류

**오류:** `ModuleNotFoundError: No module named 'yaml'`
```bash
# 해결: PyYAML 설치
pip install PyYAML

# 또는 yaml 파서 없이 config.yaml 사용
python3 create_jwt.py
```

**오류:** `openssl: command not found`
```bash
# 해결: OpenSSL 설치
# Linux (Ubuntu/Debian)
sudo apt-get install openssl

# macOS
brew install openssl

# Windows (Git Bash)
# Git for Windows에 포함됨
```

### JWT 만료

토큰이 만료되면 새로 생성:
```bash
# 유효기간 수정
vi config.yaml  # expiry_days 값 증가
python3 create_jwt.py

# 또는 수동 생성 후 SimpleDemo.properties 업데이트
```

### 타임존 문제

JWT의 `exp` 클레임이 UTC 시간으로 저장됩니다:
```bash
# 생성된 토큰 확인
python3 -c "from datetime import datetime; print(datetime.fromtimestamp(1731690300))"
```

---

## 관련 링크

- [JWT.io](https://jwt.io) - JWT 디버거 및 검증
- [RFC 7519](https://tools.ietf.org/html/rfc7519) - JWT 표준
- [OpenSSL 문서](https://www.openssl.org/docs/)
- [CRDP API 문서](https://thalesdocs.com/ctp/con/crdp/latest/crdp-apis/index.html)
