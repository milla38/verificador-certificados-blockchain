# Sistema descentralizado para la verificación de certificados académicos

## 1. Descripción

Este proyecto corresponde a un prototipo funcional basado en Blockchain para verificar la autenticidad de certificados académicos.

La solución permite que una institución registre en blockchain el hash SHA-256 de un certificado. Luego, un usuario puede seleccionar un archivo desde una interfaz web, calcular su hash localmente y consultar si ese hash está registrado en el contrato inteligente desplegado en Sepolia.

El certificado completo no se almacena en blockchain. Solo se registra su huella digital, es decir, su hash.

---

## 2. Integrantes

- Andrea Aguad
- Nour Asaed
- Millaray Verdugo

---

## 3. Problema abordado

La validación de certificados académicos suele depender de procesos manuales. Esto puede generar demoras, dificultad para verificar autenticidad y riesgo de aceptar documentos falsificados o alterados.

El problema principal es que no siempre existe una forma rápida, confiable y trazable de comprobar si un certificado corresponde al documento original emitido por una institución.

---

## 4. Objetivo

Desarrollar un prototipo Blockchain que permita verificar certificados académicos mediante el registro y consulta de su hash SHA-256 en un contrato inteligente.

---

## 5. Solución propuesta

La institución emisora calcula el hash SHA-256 del certificado original y registra ese hash en blockchain mediante una transacción.

Posteriormente, cualquier usuario puede verificar un certificado seleccionando el archivo desde una interfaz web. El navegador calcula su hash localmente y consulta el contrato inteligente.

```text
Certificado original
↓
Hash SHA-256
↓
Registro en contrato inteligente
↓
Consulta desde frontend
↓
Resultado de verificación
```

Si el hash existe en el contrato, el certificado es válido.  
Si el hash no existe, el certificado fue modificado o no está registrado.

---

## 6. Tecnologías utilizadas

- Solidity: desarrollo del contrato inteligente.
- Foundry: compilación, pruebas y despliegue.
- Forge: ejecución de pruebas.
- Cast: interacción con el contrato desde terminal.
- MetaMask: firma de transacciones.
- Sepolia: red Blockchain de prueba.
- SHA-256: generación del hash del certificado.
- HTML, CSS y JavaScript: desarrollo del frontend.
- Ethers.js: conexión del frontend con MetaMask y el contrato.
- Ubuntu: entorno de desarrollo.

---

## 7. Arquitectura general

```text
Institución emisora
↓
Certificado académico
↓
Hash SHA-256
↓
Contrato inteligente
↓
Red Sepolia
↓
Frontend de verificación
↓
Usuario verificador
```

La institución registra el hash del certificado.  
El usuario verifica el archivo consultando si su hash existe en blockchain.

---

## 8. Contrato inteligente

El contrato desarrollado se llama:

```text
VerificadorCertificados.sol
```

Su objetivo es registrar, verificar y revocar certificados mediante el uso de hashes.

Funciones principales:

```solidity
registrarCertificado(string estudiante, string documento, string hash)
```

Registra el hash de un certificado. Solo puede ejecutarla la institución autorizada.

```solidity
verificarCertificado(string hash) returns (bool)
```

Consulta si un hash existe y se encuentra válido.

```solidity
revocarCertificado(string hash)
```

Permite invalidar un certificado registrado previamente.

---

## 9. Estructuras de datos y control de acceso

El contrato utiliza una estructura `Certificado` para guardar la información asociada a cada documento:

- Nombre del estudiante.
- Nombre del documento.
- Hash del certificado.
- Fecha de registro.
- Estado de validez.
- Existencia del registro.

También utiliza un `mapping` para asociar cada hash con su certificado.

En este prototipo, la cuenta de MetaMask que despliega el contrato queda como institución autorizada. Esto impide que cualquier usuario registre certificados.

---

## 10. Cálculo local del hash

El hash se calcula localmente porque el archivo es leído por el computador o navegador sin enviarlo a blockchain.

Desde Ubuntu, se puede calcular con:

```bash
sha256sum certificado-demo-valido.txt
```

En el frontend, el navegador calcula el hash con JavaScript:

```javascript
const arrayBuffer = await file.arrayBuffer();
const hashBuffer = await crypto.subtle.digest("SHA-256", arrayBuffer);
```

Esto significa que el archivo se lee localmente y solo se obtiene su huella digital. El PDF o documento completo no se sube a blockchain.

---

## 11. Registro del certificado por la institución

La institución registra únicamente el hash del certificado, no el documento completo.

Proceso:

```text
La institución tiene el certificado original
↓
Calcula localmente el hash SHA-256
↓
Firma una transacción con su wallet autorizada
↓
Ejecuta registrarCertificado()
↓
El hash queda registrado en Sepolia
```

Ejemplo utilizado en la demo:

```bash
cast send $SEPOLIA_CONTRACT_ADDRESS "registrarCertificado(string,string,string)" "Millaray Verdugo" "Certificado Demo Valido" "910beed81b129af7063b85458bb8b5f8fe40e41b4f76d7bbde6c3579f8a7c0e7" --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

La transacción contiene el nombre, el tipo de documento y el hash. No contiene el certificado completo.

---

## 12. Estructura del proyecto

```text
verificador-certificados-blockchain/
├── src/
│   └── VerificadorCertificados.sol
├── test/
│   └── VerificadorCertificados.t.sol
├── script/
│   └── DeployVerificador.s.sol
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── app.js
├── README.md
├── foundry.toml
├── .gitignore
└── .env
```

El archivo `.env` no debe subirse a GitHub.

---

## 13. Configuración del entorno

Crear un archivo `.env` con las variables necesarias:

```text
RPC_URL="https://ethereum-sepolia-rpc.publicnode.com"
PRIVATE_KEY="TU_CLAVE_PRIVADA"
```

Cargar las variables:

```bash
source .env
```

Definir la dirección del contrato desplegado:

```bash
export SEPOLIA_CONTRACT_ADDRESS=0x62eafc3505f543f19daafa838b3b0b142cd8d84b
```

---

## 14. Compilación y pruebas

Compilar el contrato:

```bash
forge build
```

Resultado esperado:

```text
Compiler run successful!
```

Ejecutar pruebas:

```bash
forge test
```

Casos probados:

- Registro de certificado por institución autorizada.
- Bloqueo a usuarios no autorizados.
- Verificación de certificado válido.
- Rechazo de certificado falso o modificado.
- Revocación de certificado.

Resultado obtenido:

```text
5 pruebas aprobadas
0 errores
```

---

## 15. Despliegue en Sepolia

El contrato fue desplegado en la red de prueba Sepolia.

Comando de despliegue:

```bash
forge script script/DeployVerificador.s.sol:DeployVerificador --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

Contrato desplegado:

```text
0x62eafc3505f543f19daafa838b3b0b142cd8d84b
```

Hash de transacción de despliegue:

```text
0xe258e71a2f1fe32147bbbce213f0ef931c8117033bca6c76be9c4efece136640
```

Red utilizada:

```text
Sepolia
Chain ID: 11155111
```

---

## 16. Verificación por terminal

Verificar certificado registrado:

```bash
cast call $SEPOLIA_CONTRACT_ADDRESS "verificarCertificado(string)(bool)" "910beed81b129af7063b85458bb8b5f8fe40e41b4f76d7bbde6c3579f8a7c0e7" --rpc-url $RPC_URL
```

Resultado esperado:

```text
true
```

Para un certificado modificado o no registrado, el resultado esperado es:

```text
false
```

---

## 17. Frontend de demostración

El proyecto incluye una interfaz web simple en la carpeta:

```text
frontend/
```

Para ejecutarla:

```bash
cd frontend
python3 -m http.server 8000
```

Abrir en el navegador:

```text
http://localhost:8000
```

La interfaz permite:

- Conectar MetaMask.
- Seleccionar un archivo.
- Calcular localmente el hash SHA-256.
- Consultar el contrato en Sepolia.
- Mostrar el resultado de verificación.

El frontend solo verifica certificados. El registro lo realiza la institución autorizada.

---

## 18. Resultados de la demo

Se probaron dos archivos:

```text
certificado-demo-valido.txt
certificado-demo-modificado.txt
```

Diferencia principal entre ambos:

```text
Original:
Fecha: 2026
Estado: Documento original registrado en blockchain

Modificado:
Fecha: 2027
Estado: Documento modificado
```

Resultados obtenidos:

```text
Archivo original registrado → Certificado válido
Archivo modificado → Certificado no registrado o modificado
```

Esto demuestra que un cambio mínimo en el archivo genera un hash diferente y permite detectar alteraciones.

---

## 19. Seguridad, limitaciones y mejoras

### Seguridad

El archivo `.env` contiene información sensible, como la clave privada de la wallet. Por eso debe estar incluido en `.gitignore`.

Archivos y carpetas que no deben subirse:

```text
.env
cache/
out/
broadcast/
```

En una implementación real, la institución debería proteger su wallet institucional y utilizar mecanismos seguros de administración de claves.

### Limitaciones

- El prototipo funciona en Sepolia, no en una red principal.
- El registro de certificados se realiza desde terminal.
- El frontend permite verificar, pero no registrar certificados.
- Solo existe una institución autorizada.
- No está integrado con sistemas académicos reales.

### Mejoras futuras

- Crear un panel web para que la institución registre certificados.
- Permitir múltiples instituciones autorizadas.
- Agregar roles de administración.
- Integrar el sistema con plataformas académicas.
- Mejorar la experiencia de usuario.
- Evaluar costos de uso en una red principal.

---

## 20. Uso de inteligencia artificial generativa

Se utilizó inteligencia artificial generativa como apoyo en:

- Organización de ideas.
- Redacción y revisión de textos.
- Estructuración del README.
- Preparación de contenido para la presentación.
- Explicación de conceptos técnicos.

El código fue ejecutado, probado y validado por el grupo mediante Ubuntu, Foundry, Sepolia, MetaMask y el frontend funcional.

---

## 21. Referencias

- Material de clases del curso Blockchain.
- Documentación oficial de Solidity: https://docs.soliditylang.org/
- Documentación oficial de Foundry: https://book.getfoundry.sh/
- Documentación de Ethereum: https://ethereum.org/
- Documentación de MetaMask: https://docs.metamask.io/
- Documentación de Ethers.js: https://docs.ethers.org/
- National Institute of Standards and Technology, información sobre funciones hash SHA: https://csrc.nist.gov/projects/hash-functions

---

## 22. Conclusión

El proyecto demuestra una prueba de concepto funcional para la verificación descentralizada de certificados académicos.

La solución permite registrar el hash de un certificado en blockchain y verificar posteriormente si un documento corresponde al original emitido por la institución.

El uso de SHA-256 protege la privacidad del documento, evita almacenar archivos completos en blockchain y permite detectar modificaciones en el certificado.
