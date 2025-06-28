import sys
import xml.etree.ElementTree as ET

def extract_java_version(pom_path):
    tree = ET.parse(pom_path)
    root = tree.getroot()
    ns = {'maven': 'http://maven.apache.org/POM/4.0.0'}
    java_version = None
    for props in root.findall('maven:properties', ns):
        for elem in props:
            if 'java.version' in elem.tag:
                java_version = elem.text
                break
    if not java_version:
        for props in root.findall('maven:properties', ns):
            for elem in props:
                if 'maven.compiler.source' in elem.tag:
                    java_version = elem.text
                    break
    if not java_version:
        java_version = '17'
    return java_version

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("사용법: python3 pom_to_docker_image.py <pom.xml 경로>")
        sys.exit(1)
    pom_path = sys.argv[1]
    java_version = extract_java_version(pom_path)
    print(f"custom-cdxgen-java{java_version}:latest")

