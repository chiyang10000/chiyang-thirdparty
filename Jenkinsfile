pipeline {
  agent {
    dockerfile {
      filename 'docker/centos6.Dockerfile'
      args '-v /data0/opt/:/opt/'
    }

  }
  stages {
    stage('Download') {
      steps {
        sh '''cat /etc/*-release
export PREFIX=/opt/dependency/package
make download-src
'''
      }
    }

    stage('clang build') {
      steps {
        sh '''
source ./toolchain-clang-x86_64-Linux.sh
export PREFIX=/opt/dependency-clang-x86_64-Linux/package
make download-src
make build-hawq-dep'''
      }
    }

    stage('gcc build') {
      steps {
        sh '''
source ./toolchain-gcc-x86_64-Linux.sh
export PREFIX=/opt/dependency-gcc-x86_64-Linux/package
make download-src
make build-hawq-dep'''
      }
    }

  }
}
