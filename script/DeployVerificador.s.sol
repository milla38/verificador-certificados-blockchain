// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/VerificadorCertificados.sol";

contract DeployVerificador is Script {
    function run() external returns (VerificadorCertificados) {
        vm.startBroadcast();

        VerificadorCertificados verificador = new VerificadorCertificados();

        vm.stopBroadcast();

        return verificador;
    }
}
