def Compilacion() {
  sh './mvnw clean compile -e'
}

def Test() {
  sh './mvnw clean test -e'
}

return this