const CONTRACT_ADDRESS = "0x62eafc3505f543f19daafa838b3b0b142cd8d84b";

const ABI = [
    "function verificarCertificado(string) view returns (bool)"
];

const connectWalletButton = document.getElementById("connectWallet");
const walletAddress = document.getElementById("walletAddress");
const fileInput = document.getElementById("fileInput");
const verifyButton = document.getElementById("verifyButton");
const hashOutput = document.getElementById("hashOutput");
const resultOutput = document.getElementById("resultOutput");

async function connectWallet() {
    if (!window.ethereum) {
        walletAddress.textContent = "MetaMask no está instalado.";
        return;
    }

    try {
        await window.ethereum.request({ method: "eth_requestAccounts" });

        const chainId = await window.ethereum.request({ method: "eth_chainId" });

        if (chainId !== "0xaa36a7") {
            walletAddress.textContent = "Cambia MetaMask manualmente a Sepolia.";
            return;
        }

        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        const address = await signer.getAddress();

        walletAddress.textContent = `Wallet conectada en Sepolia: ${address}`;
    } catch (error) {
        console.error(error);
        walletAddress.textContent = "No se pudo conectar MetaMask.";
    }
}

async function calculateSHA256(file) {
    const arrayBuffer = await file.arrayBuffer();
    const hashBuffer = await crypto.subtle.digest("SHA-256", arrayBuffer);
    const hashArray = Array.from(new Uint8Array(hashBuffer));

    return hashArray
        .map(byte => byte.toString(16).padStart(2, "0"))
        .join("");
}

async function verifyCertificate() {
    const file = fileInput.files[0];

    if (!file) {
        alert("Primero selecciona un archivo.");
        return;
    }

    if (!window.ethereum) {
        resultOutput.textContent = "MetaMask no está instalado.";
        resultOutput.className = "result invalid";
        return;
    }

    try {
        resultOutput.textContent = "Calculando hash...";
        resultOutput.className = "result";

        const hash = await calculateSHA256(file);
        hashOutput.textContent = hash;

        const chainId = await window.ethereum.request({ method: "eth_chainId" });

        if (chainId !== "0xaa36a7") {
            resultOutput.textContent = "MetaMask debe estar en Sepolia.";
            resultOutput.className = "result invalid";
            return;
        }

        resultOutput.textContent = "Consultando contrato en Sepolia...";

        const provider = new ethers.BrowserProvider(window.ethereum);
        const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, provider);

        const isValid = await contract.verificarCertificado(hash);

        if (isValid) {
            resultOutput.textContent = "Certificado válido";
            resultOutput.className = "result valid";
        } else {
            resultOutput.textContent = "Certificado no registrado o modificado";
            resultOutput.className = "result invalid";
        }

    } catch (error) {
        console.error(error);
        resultOutput.textContent = "Error técnico: " + (error.shortMessage || erro.message);
        resultOutput.className = "result invalid";
    }
}

connectWalletButton.addEventListener("click", connectWallet);
verifyButton.addEventListener("click", verifyCertificate);
