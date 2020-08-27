pragma experimental ABIEncoderV2;

contract PubKeyTest {
    mapping(address => mapping(string => string)) PatientToDoctor;
    mapping(address => string[]) PatientToDoctorPending;

    function Set(string memory doctorPublicKey, string memory token)
        public
        returns (bool)
    {
        PatientToDoctor[msg.sender][doctorPublicKey] = token;
        DeletePending(msg.sender, doctorPublicKey);
        return true;
    }

    function Get(address patientAddress, string memory doctorPublicKey)
        public
        view
        returns (string memory)
    {
        return PatientToDoctor[patientAddress][doctorPublicKey];
    }

    function SetPending(address patientAddress, string memory doctorPublicKey) public returns (bool) {
        for (
            uint256 i = 0;
            i < PatientToDoctorPending[patientAddress].length;
            i++
        ) {
            if (keccak256(abi.encodePacked(PatientToDoctorPending[patientAddress][i])) == keccak256(abi.encodePacked(doctorPublicKey))) {
                return false;
            }
        }
        PatientToDoctorPending[patientAddress].push(doctorPublicKey);
        return true;
    }

    function GetAllPending(address patientAddress)
        public
        view
        returns (string[] memory)
    {
        return PatientToDoctorPending[patientAddress];
    }

    function DeleteAllPending(address patientAddress) public returns (bool) {
        delete PatientToDoctorPending[patientAddress];
        return true;
    }

    function DeletePending(address patientAddress, string memory doctorPublicKey)
        public
        returns (bool)
    {
        for (
            uint256 i = 0;
            i < PatientToDoctorPending[patientAddress].length;
            i++
        ) {
            if (keccak256(abi.encodePacked(PatientToDoctorPending[patientAddress][i])) == keccak256(abi.encodePacked(doctorPublicKey))) {
                //TODO faut supprimer le stockage aussi, delete attribue 0, stockage persiste
                delete PatientToDoctorPending[patientAddress][i];
            }
        }
        return true;
    }
}

//local test wallet: 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
