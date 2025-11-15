#!/bin/bash

echo "=== 간단 빌드 ==="

# 기존 빌드 정리
rm -f *.class SimpleDemo

# 컴파일
echo "컴파일 중..."
javac SimpleDemo.java

if [ $? -eq 0 ]; then
    echo "컴파일 성공!"
    
    # 실행 스크립트 생성
    cat > run.sh << 'EOF'
#!/bin/bash
# 현재 디렉토리에서 properties 파일을 찾을 수 있도록 설정
java -cp . SimpleDemo "$@"
EOF
    chmod +x run.sh
    
    echo "사용법: ./run.sh 또는 java -cp . SimpleDemo"
    echo ""
    echo "예제:"
    echo "  ./run.sh"
    echo "  ./run.sh --help"
    echo "  ./run.sh --data 9876543210987"
else
    echo "컴파일 실패!"
    exit 1
fi