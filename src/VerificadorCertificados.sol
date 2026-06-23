// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VerificadorCertificados {
    address public institucion;

    struct Certificado {
        string estudiante;
        string nombreDocumento;
        string hashDocumento;
        uint256 fechaRegistro;
        bool valido;
        bool existe;
    }

    mapping(string => Certificado) private certificados;

    event CertificadoRegistrado(
        string estudiante,
        string nombreDocumento,
        string hashDocumento,
        uint256 fechaRegistro
    );

    event CertificadoRevocado(
        string hashDocumento,
        uint256 fechaRevocacion
    );

    modifier soloInstitucion() {
        require(
            msg.sender == institucion,
            "Solo la institucion autorizada puede realizar esta accion"
        );
        _;
    }

    constructor() {
        institucion = msg.sender;
    }

    function registrarCertificado(
        string memory _estudiante,
        string memory _nombreDocumento,
        string memory _hashDocumento
    ) public soloInstitucion {
        require(bytes(_estudiante).length > 0, "El estudiante no puede estar vacio");
        require(bytes(_nombreDocumento).length > 0, "El nombre del documento no puede estar vacio");
        require(bytes(_hashDocumento).length > 0, "El hash no puede estar vacio");
        require(!certificados[_hashDocumento].existe, "El certificado ya fue registrado");

        certificados[_hashDocumento] = Certificado({
            estudiante: _estudiante,
            nombreDocumento: _nombreDocumento,
            hashDocumento: _hashDocumento,
            fechaRegistro: block.timestamp,
            valido: true,
            existe: true
        });

        emit CertificadoRegistrado(
            _estudiante,
            _nombreDocumento,
            _hashDocumento,
            block.timestamp
        );
    }

    function verificarCertificado(
        string memory _hashDocumento
    ) public view returns (bool) {
        return certificados[_hashDocumento].existe && certificados[_hashDocumento].valido;
    }

    function obtenerCertificado(
        string memory _hashDocumento
    )
        public
        view
        returns (
            string memory estudiante,
            string memory nombreDocumento,
            string memory hashDocumento,
            uint256 fechaRegistro,
            bool valido
        )
    {
        require(certificados[_hashDocumento].existe, "Certificado no encontrado");

        Certificado memory cert = certificados[_hashDocumento];

        return (
            cert.estudiante,
            cert.nombreDocumento,
            cert.hashDocumento,
            cert.fechaRegistro,
            cert.valido
        );
    }

    function revocarCertificado(
        string memory _hashDocumento
    ) public soloInstitucion {
        require(certificados[_hashDocumento].existe, "Certificado no encontrado");
        require(certificados[_hashDocumento].valido, "El certificado ya esta revocado");

        certificados[_hashDocumento].valido = false;

        emit CertificadoRevocado(
            _hashDocumento,
            block.timestamp
        );
    }

    function cambiarInstitucion(
        address _nuevaInstitucion
    ) public soloInstitucion {
        require(_nuevaInstitucion != address(0), "Direccion invalida");
        institucion = _nuevaInstitucion;
    }
}
