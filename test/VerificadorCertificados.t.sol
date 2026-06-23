// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VerificadorCertificados.sol";

contract VerificadorCertificadosTest is Test {
    VerificadorCertificados verificador;

    address institucion = address(1);
    address personaNoAutorizada = address(2);

    string estudiante = "Millaray Verdugo";
    string documento = "Certificado Curso Blockchain";
    string hashDocumento = "hash_certificado_123";
    string hashFalso = "hash_falso_999";

    function setUp() public {
        vm.prank(institucion);
        verificador = new VerificadorCertificados();
    }

    function testInstitucionPuedeRegistrarCertificado() public {
        vm.prank(institucion);

        verificador.registrarCertificado(
            estudiante,
            documento,
            hashDocumento
        );

        bool resultado = verificador.verificarCertificado(hashDocumento);

        assertTrue(resultado);
    }

    function testPersonaNoAutorizadaNoPuedeRegistrar() public {
        vm.prank(personaNoAutorizada);

        vm.expectRevert("Solo la institucion autorizada puede realizar esta accion");

        verificador.registrarCertificado(
            estudiante,
            documento,
            hashDocumento
        );
    }

    function testCertificadoFalsoDevuelveFalse() public {
        bool resultado = verificador.verificarCertificado(hashFalso);

        assertFalse(resultado);
    }

    function testObtenerDatosDelCertificado() public {
        vm.prank(institucion);

        verificador.registrarCertificado(
            estudiante,
            documento,
            hashDocumento
        );

        (
            string memory estudianteGuardado,
            string memory documentoGuardado,
            string memory hashGuardado,
            ,
            bool valido
        ) = verificador.obtenerCertificado(hashDocumento);

        assertEq(estudianteGuardado, estudiante);
        assertEq(documentoGuardado, documento);
        assertEq(hashGuardado, hashDocumento);
        assertTrue(valido);
    }

    function testRevocarCertificado() public {
        vm.prank(institucion);

        verificador.registrarCertificado(
            estudiante,
            documento,
            hashDocumento
        );

        vm.prank(institucion);

        verificador.revocarCertificado(hashDocumento);

        bool resultado = verificador.verificarCertificado(hashDocumento);

        assertFalse(resultado);
    }
}
