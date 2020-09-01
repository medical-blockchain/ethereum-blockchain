pragma experimental ABIEncoderV2;

contract MedicalV101 {
    mapping(address => string) PatientAddressToStorj;
    mapping(address => mapping(string => string)) PatientToDoctorToToken;
    mapping(address => string[]) PatientToDoctorsPending;
    mapping(string => address[]) DoctorToPatientsPending;
    mapping(address => string[]) PatientToDoctors;
    mapping(string => address[]) DoctorToPatients;

    function SetPatientAddressToStorj(
        address PatientAddress,
        string memory encryptedStorjToken
    ) public returns (string memory) {
        PatientAddressToStorj[PatientAddress] = encryptedStorjToken;
        return PatientAddressToStorj[PatientAddress];
    }

    function GetPatientsForDoctor(string memory doctorPublicKey)
        public
        view
        returns (address[] memory)
    {
        return DoctorToPatients[doctorPublicKey];
    }

    function GetDoctorsForPatient(address patientAddress)
        public
        view
        returns (string[] memory)
    {
        return PatientToDoctors[patientAddress];
    }

    function GetPatientAddressToStorj(address PatientAddress)
        public
        view
        returns (string memory)
    {
        return PatientAddressToStorj[PatientAddress];
    }

    function Set(string memory doctorPublicKey, string memory token)
        public
        returns (bool)
    {
        bool doctorExists = false;
        for (uint256 i = 0; i < PatientToDoctors[msg.sender].length; i++) {
            if (
                keccak256(abi.encodePacked(PatientToDoctors[msg.sender][i])) ==
                keccak256(abi.encodePacked(doctorPublicKey))
            ) {
                doctorExists = true;
                break;
            }
        }
        if (doctorExists == false) {
            PatientToDoctors[msg.sender].push(doctorPublicKey);
            DoctorToPatients[doctorPublicKey].push(msg.sender);
        }
        PatientToDoctorToToken[msg.sender][doctorPublicKey] = token;
        DeletePending(msg.sender, doctorPublicKey);
        return true;
    }

    function Get(address patientAddress, string memory doctorPublicKey)
        public
        view
        returns (string memory)
    {
        return PatientToDoctorToToken[patientAddress][doctorPublicKey];
    }

    function SetPending(address patientAddress, string memory doctorPublicKey)
        public
        returns (bool)
    {   
        //faudra vérifier le sender, comparaison ci-dessous marche pas...
        //if(bytes20(msg.sender) != bytes20(uint160 (uint256 (keccak256 (abi.encodePacked(doctorPublicKey)))))){
          //  return false;
        //}
        for (
            uint256 i = 0;
            i < PatientToDoctorsPending[patientAddress].length;
            i++
        ) {
            if (
                keccak256(
                    abi.encodePacked(PatientToDoctorsPending[patientAddress][i])
                ) == keccak256(abi.encodePacked(doctorPublicKey))
            ) {
                return false;
            }
        }
        PatientToDoctorsPending[patientAddress].push(doctorPublicKey);
        DoctorToPatientsPending[doctorPublicKey].push(patientAddress);
        return true;
    }

    function GetPendingDoctorsForPatient(address patientAddress)
        public
        view
        returns (string[] memory)
    {
        return PatientToDoctorsPending[patientAddress];
    }

    function GetPendingPatientsForDoctor(string memory doctorPublicKey)
        public
        view
        returns (address[] memory)
    {
        return DoctorToPatientsPending[doctorPublicKey];
    }

    function DeletePending(
        address patientAddress,
        string memory doctorPublicKey
    ) private returns (bool) {
        for (
            uint256 i = 0;
            i < PatientToDoctorsPending[patientAddress].length;
            i++
        ) {
            if (
                keccak256(
                    abi.encodePacked(PatientToDoctorsPending[patientAddress][i])
                ) == keccak256(abi.encodePacked(doctorPublicKey))
            ) {
                //TODO faut supprimer le stockage aussi, delete attribue 0, stockage persiste
                delete PatientToDoctorsPending[patientAddress][i];
            }
        }
        for (
            uint256 i = 0;
            i < DoctorToPatientsPending[doctorPublicKey].length;
            i++
        ) {
            if (
                keccak256(
                    abi.encodePacked(
                        DoctorToPatientsPending[doctorPublicKey][i]
                    )
                ) == keccak256(abi.encodePacked(patientAddress))
            ) {
                //TODO faut supprimer le stockage aussi, delete attribue 0, stockage persiste
                delete DoctorToPatientsPending[doctorPublicKey][i];
            }
        }
        return true;
    }
}

//local test wallet: 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
