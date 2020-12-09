// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;

contract MedicalMVP101 {
    string patientType = "patient";
    string institutionType = "institution";
    string functionaryType = "functionary";
    string doctorType = "doctor";

    struct EntityAddressToToken {
        address entityAddress;
        string token;
    }

    struct EntityAddressToType {
        address entityAddress;
        string entityType;
    }

    struct LoopableAddressStringKeyPair {
        mapping(address => string) AddressTokenMapping;
        mapping(address => uint256) ArrayIndexMapping;
        EntityAddressToToken[] addressStringArray;
    }
    struct LoopableAddress {
        mapping(address => uint256) ArrayIndexMapping;
        EntityAddressToType[] addressArray;
    }

    struct InstitutionInfo {
        LoopableAddressStringKeyPair EncryptedTokensCreatedByPatientsForThisEntity;
        LoopableAddressStringKeyPair EncryptedTokensCreatedByThisEntityForFunctionaries;
        LoopableAddress PendingOutgoing;
        LoopableAddress PendingIncoming;
        LoopableAddress entitiesRevokedByThisEntity;
        LoopableAddress entitiesRejectedByThisEntity;
        LoopableAddress entiesThatRevokedThisEntity;
        LoopableAddress entiesThatRejectedThisEntity;
        string encryptedStorjToken;
        string ethPublicKey;
    }
    struct DoctorInfo {
        LoopableAddressStringKeyPair EncryptedTokensCreatedByPatientsForThisEntity;
        LoopableAddressStringKeyPair EncryptedTokensCreatedByThisEntityForDoctors;
        LoopableAddressStringKeyPair EncryptedTokensCreatedByDoctorsForThisEntity;
        LoopableAddressStringKeyPair EncryptedTokensCreatedByFunctionariesForThisEntity;
        LoopableAddress PendingOutgoing;
        LoopableAddress PendingIncoming;
        LoopableAddress entitiesRevokedByThisEntity;
        LoopableAddress entitiesRejectedByThisEntity;
        LoopableAddress entiesThatRevokedThisEntity;
        LoopableAddress entiesThatRejectedThisEntity;
        string encryptedStorjToken;
        string ethPublicKey;
    }
    struct PatientInfo {
        string demographicDataToken;
        string medicalDataToken;
        LoopableAddressStringKeyPair EncryptedTokensCreatedByThisEntityForInstitutions;
        LoopableAddressStringKeyPair EncryptedTokensCreatedByThisEntityForDoctors;
        LoopableAddress PendingOutgoing;
        LoopableAddress PendingIncoming;
        LoopableAddress entitiesRevokedByThisEntity;
        LoopableAddress entitiesRejectedByThisEntity;
        LoopableAddress entiesThatRevokedThisEntity;
        LoopableAddress entiesThatRejectedThisEntity;
        string encryptedStorjToken;
        string ethPublicKey;
    }
    struct FunctionaryInfo {
        LoopableAddressStringKeyPair EncryptedTokensCreatedByInstitutionsForThisEntity;    
        LoopableAddressStringKeyPair EncryptedTokensCreatedByThisEntityForDoctors;
        LoopableAddressStringKeyPair EncryptedTokensCreatedByFunctionariesForThisEntity;
        LoopableAddress PendingOutgoing;
        LoopableAddress PendingIncoming;
        LoopableAddress entitiesRevokedByThisEntity;
        LoopableAddress entitiesRejectedByThisEntity;
        LoopableAddress entiesThatRevokedThisEntity;
        LoopableAddress entiesThatRejectedThisEntity;
        string encryptedStorjToken;
        string ethPublicKey;
        LoopableAddressStringKeyPair EncryptedTokensCreatedByThisEntityForFunctionaries;
        mapping (address => string) DownstreamNewPatientDefaultPermission;
    }

    mapping(address => InstitutionInfo) Institutions;
    mapping(address => PatientInfo) Patients;
    mapping(address => FunctionaryInfo) Functionaries;
    mapping(address => DoctorInfo) Doctors;
    mapping(address => string) AddressToPublicKey;

    function CreatePatient(string memory ethPublicKey,string memory encryptedStorjToken) public {
        PatientInfo storage patientInfo = Patients[msg.sender];
        patientInfo.ethPublicKey = ethPublicKey;
        patientInfo.encryptedStorjToken = encryptedStorjToken;
    }
    function CreateInstitution(string memory ethPublicKey,string memory encryptedStorjToken) public {
        InstitutionInfo storage institutionInfo = Institutions[msg.sender];
        institutionInfo.ethPublicKey = ethPublicKey;
        institutionInfo.encryptedStorjToken = encryptedStorjToken;
    }
    function CreateFunctionary(string memory ethPublicKey,string memory encryptedStorjToken) public {
        FunctionaryInfo storage functionaryInfo = Functionaries[msg.sender];
        functionaryInfo.ethPublicKey = ethPublicKey;
        functionaryInfo.encryptedStorjToken = encryptedStorjToken;
    }
    function CreateDoctor(string memory ethPublicKey,string memory encryptedStorjToken) public {
        DoctorInfo storage doctorInfo = Doctors[msg.sender];
        doctorInfo.ethPublicKey = ethPublicKey;
        doctorInfo.encryptedStorjToken = encryptedStorjToken;
    }

    function FunctionaryRequestAccessFromFunctionary(address grantingFunctionary) public {
        WriteToLoopableAddressList(grantingFunctionary, functionaryType,  Functionaries[msg.sender].PendingIncoming);
        WriteToLoopableAddressList(msg.sender,functionaryType, Functionaries[grantingFunctionary].PendingOutgoing);
    }
    function FunctionaryRequestInstitutionAccess(address institutionAddress) public {
        WriteToLoopableAddressList(msg.sender,functionaryType,Institutions[institutionAddress].PendingIncoming);
        WriteToLoopableAddressList(institutionAddress, functionaryType,Functionaries[msg.sender].PendingOutgoing);
    }
    function InstitutionRequestPatientAccess(address patientAddress) public {
        WriteToLoopableAddressList(msg.sender, institutionType,Patients[patientAddress].PendingIncoming);
        WriteToLoopableAddressList(patientAddress, institutionType, Institutions[msg.sender].PendingOutgoing);
    }

    function PatientAcceptInstitution(address institutionAddress,string memory encryptedStorjToken) public {
        WriteToLoopableAddressStringKeyPairList(msg.sender,encryptedStorjToken,
            Institutions[institutionAddress].EncryptedTokensCreatedByPatientsForThisEntity);
        WriteToLoopableAddressStringKeyPairList(institutionAddress,encryptedStorjToken, 
            Patients[msg.sender].EncryptedTokensCreatedByThisEntityForInstitutions);
        ClearFromLoopableAddressList(msg.sender, Institutions[institutionAddress].PendingOutgoing);
        ClearFromLoopableAddressList(institutionAddress, Patients[msg.sender].PendingIncoming);
    }
    function InstitutionAcceptFunctionary(address functionaryAddress,string memory encryptedStorjToken) public {
        WriteToLoopableAddressStringKeyPairList(msg.sender,encryptedStorjToken,
            Functionaries[functionaryAddress].EncryptedTokensCreatedByInstitutionsForThisEntity);
        WriteToLoopableAddressStringKeyPairList(functionaryAddress,encryptedStorjToken,
            Institutions[msg.sender].EncryptedTokensCreatedByThisEntityForFunctionaries);
        ClearFromLoopableAddressList(msg.sender, Functionaries[functionaryAddress].PendingOutgoing);
        ClearFromLoopableAddressList(functionaryAddress, Institutions[msg.sender].PendingIncoming);
    }
    function FunctionaryAcceptFunctionary(
        address requestingFunctionaryAddress,
        string memory encryptedStorjToken,
        string memory downstreamNewPatientDefaultPermission
    ) public {
        Functionaries[msg.sender].DownstreamNewPatientDefaultPermission[requestingFunctionaryAddress] = downstreamNewPatientDefaultPermission;
        WriteToLoopableAddressStringKeyPairList(msg.sender,encryptedStorjToken,
            Functionaries[requestingFunctionaryAddress].EncryptedTokensCreatedByFunctionariesForThisEntity);
        WriteToLoopableAddressStringKeyPairList(requestingFunctionaryAddress,encryptedStorjToken,
            Functionaries[msg.sender].EncryptedTokensCreatedByThisEntityForFunctionaries);
        ClearFromLoopableAddressList(msg.sender, Functionaries[requestingFunctionaryAddress].PendingOutgoing);
        ClearFromLoopableAddressList(requestingFunctionaryAddress, Functionaries[msg.sender].PendingIncoming);
    }

    function WriteToLoopableAddressStringKeyPairList(address entityAddress,string memory token,
        LoopableAddressStringKeyPair storage list
    ) private {
        EntityAddressToToken memory addressToTokenToAdd;
        addressToTokenToAdd = EntityAddressToToken(entityAddress, token);
        list.ArrayIndexMapping[entityAddress] = list.addressStringArray.length;
        list.addressStringArray.push(addressToTokenToAdd);
        list.AddressTokenMapping[entityAddress] = addressToTokenToAdd
            .token;
    }
    function ClearFromLoopableAddressStringKeyPairList(address entityAddress,LoopableAddressStringKeyPair storage list) private {
        delete list.AddressTokenMapping[entityAddress];
        uint256 arrayIndexLocation;
        arrayIndexLocation = list.ArrayIndexMapping[entityAddress];
        list.addressStringArray[arrayIndexLocation].token = "NA";
    }
    function WriteToLoopableAddressList(address entityAddress,string memory entityType, LoopableAddress storage list) private {
        list.ArrayIndexMapping[entityAddress] = list.addressArray.length;
        list.addressArray.push(EntityAddressToType(entityAddress, entityType));
    }
    function ClearFromLoopableAddressList(address entityAddress,LoopableAddress storage list) private {
        uint256 arrayIndexLocation;
        arrayIndexLocation = list.ArrayIndexMapping[entityAddress];
        list.addressArray[arrayIndexLocation] = EntityAddressToType(0x0000000000000000000000000000000000000000, 'NA');
    }

    function GetPatientETHPublicKey(address patientAddress) public view returns (string memory) {
        return Patients[patientAddress].ethPublicKey;
    }
    function GetSenderAddress() public view returns (address) {
        return msg.sender;
    }
    function GetAllActiveEncryptedPatientTokensForInstitution() public view returns ( EntityAddressToToken[] memory)  {
        Institutions[msg.sender].EncryptedTokensCreatedByPatientsForThisEntity.addressStringArray;
    }
    function StringCompare(string memory value1, string memory value2) private pure returns (bool){
        if(keccak256(abi.encodePacked(value1)) == keccak256(abi.encodePacked(value2))){
            return true;
        } else {
            return false;
        }
    }
}