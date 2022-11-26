def Compilacion() {
  sh './gradlew build'
}
def Test(){
  sh './gradlew test'
}

return this