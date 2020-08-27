pragma experimental ABIEncoderV2;

contract Counter {
    //use public key instead of doctor address because impoosible to
    //get public key externally if transaction hasn't been mined
    //by sending the public key directly the token can be generated
    //right away instead of waiting fo transaction
    mapping(address => mapping(address => string)) PatientToDoctor;
    mapping(address => address[]) PatientToDoctorPending;

    function Set(address doctorAddress, string memory token)
        public
        returns (bool)
    {
        PatientToDoctor[msg.sender][doctorAddress] = token;
        DeletePending(msg.sender, doctorAddress);
        return true;
    }

    function Get(address patientAddress, address doctorAddress)
        external
        view
        returns (string memory)
    {
        return PatientToDoctor[patientAddress][doctorAddress];
    }

    //eventually pending logic should be moved to centralized server
    function SetPending(address patientAddress, address doctorAddress)
        public
        returns (bool)
    {
        for (
            uint256 i = 0;
            i < PatientToDoctorPending[patientAddress].length;
            i++
        ) {
            if (PatientToDoctorPending[patientAddress][i] == doctorAddress) {
                return false;
            }
        }
        PatientToDoctorPending[patientAddress].push(doctorAddress);
        return true;
    }

    function GetAllPending(address patientAddress)
        public
        view
        returns (address[] memory)
    {
        return PatientToDoctorPending[patientAddress];
    }

    function DeleteAllPending(address patientAddress) public returns (bool) {
        delete PatientToDoctorPending[patientAddress];
        return true;
    }

    function DeletePending(address patientAddress, address doctorAddress)
        public
        returns (bool)
    {
        for (
            uint256 i = 0;
            i < PatientToDoctorPending[patientAddress].length;
            i++
        ) {
            if (PatientToDoctorPending[patientAddress][i] == doctorAddress) {
                //TODO faut supprimer le stockage aussi, delete attribue 0, stockage persiste
                delete PatientToDoctorPending[patientAddress][i];
            }
        }
        return true;
    }
}

//local test wallet: 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
