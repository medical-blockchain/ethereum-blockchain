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
        string permission;
    }

    struct EntityAddressToType {
        address entityAddress;
        string entityType;
    }

    struct LoopableAddressStringKeyPair {
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
    }

    mapping(address => InstitutionInfo) Institutions;
    mapping(address => PatientInfo) Patients;
    mapping(address => FunctionaryInfo) Functionaries;
    mapping(address => DoctorInfo) Doctors;
    mapping(address => string) AddressToPublicKey;

    function CreateEntity(string memory ethPublicKey,string memory encryptedStorjToken, string memory entityType) public {
        if(StringCompare(entityType, patientType)){
            PatientInfo storage patientInfo = Patients[msg.sender];
            patientInfo.ethPublicKey = ethPublicKey;
            patientInfo.encryptedStorjToken = encryptedStorjToken;
        }
        if(StringCompare(entityType, institutionType)){
            InstitutionInfo storage institutionInfo = Institutions[msg.sender];
            institutionInfo.ethPublicKey = ethPublicKey;
            institutionInfo.encryptedStorjToken = encryptedStorjToken;
        }
        if(StringCompare(entityType, functionaryType)){
            FunctionaryInfo storage functionaryInfo = Functionaries[msg.sender];
            functionaryInfo.ethPublicKey = ethPublicKey;
            functionaryInfo.encryptedStorjToken = encryptedStorjToken;
        }
        if(StringCompare(entityType, doctorType)){
            DoctorInfo storage doctorInfo = Doctors[msg.sender];
            doctorInfo.ethPublicKey = ethPublicKey;
            doctorInfo.encryptedStorjToken = encryptedStorjToken;
        }

    }

    function RequestAccess(
        address toEntityAddress, 
        string memory fromEntityType,
        string memory toEntityType) 
        public {
            if(StringCompare(fromEntityType, functionaryType) && StringCompare(toEntityType, functionaryType)){
                WriteToLoopableAddressList(msg.sender, functionaryType,  Functionaries[toEntityAddress].PendingIncoming);
                WriteToLoopableAddressList(toEntityAddress,functionaryType, Functionaries[msg.sender].PendingOutgoing);
            }
            if(StringCompare(fromEntityType, functionaryType) && StringCompare(toEntityType, institutionType)){
                WriteToLoopableAddressList(msg.sender,functionaryType,Institutions[toEntityAddress].PendingIncoming);
                WriteToLoopableAddressList(toEntityAddress, functionaryType,Functionaries[msg.sender].PendingOutgoing);
            }
            if(StringCompare(fromEntityType, institutionType) && StringCompare(toEntityType, patientType)){
                WriteToLoopableAddressList(msg.sender, functionaryType,  Patients[toEntityAddress].PendingIncoming);
                WriteToLoopableAddressList(toEntityAddress,functionaryType, Institutions[msg.sender].PendingOutgoing);
            }
    }

    function AcceptAccessRequest(
        address senderEntityAddress, 
        string memory senderEntityType, 
        string memory acceptorEntityType,
        string memory encryptedStorjToken,
        string memory permission
    ) public {
        if(StringCompare(senderEntityType, institutionType) && StringCompare(acceptorEntityType, patientType)){
            PatientAcceptInstitution(senderEntityAddress,encryptedStorjToken,permission);
        }
        if(StringCompare(senderEntityType, functionaryType) && StringCompare(acceptorEntityType, institutionType)){
            InstitutionAcceptFunctionary(senderEntityAddress,encryptedStorjToken,permission);
        }
        if(StringCompare(senderEntityType, functionaryType) && StringCompare(acceptorEntityType, functionaryType)){
            FunctionaryAcceptFunctionary(senderEntityAddress,encryptedStorjToken,permission);
        }
    }

    function GetEncryptedStorjToken(address entityAddress, string memory entityType) public view returns (string memory) {
        if(StringCompare(entityType, patientType)){
            return Patients[entityAddress].encryptedStorjToken;
        }
        if(StringCompare(entityType, doctorType)){
            return Doctors[entityAddress].encryptedStorjToken;
        }
        if(StringCompare(entityType, institutionType)){
            return Institutions[entityAddress].encryptedStorjToken;
        }
        if(StringCompare(entityType, functionaryType)){
            return Functionaries[entityAddress].encryptedStorjToken;
        }
    }

    function GetPublicKeyFromAddress(address entityAddress, string memory entityType) public view returns (string memory) {
        if(StringCompare(entityType, patientType)){
            return Patients[entityAddress].ethPublicKey;
        }
        if(StringCompare(entityType, doctorType)){
            return Doctors[entityAddress].ethPublicKey;
        }
        if(StringCompare(entityType, institutionType)){
            return Institutions[entityAddress].ethPublicKey;
        }
        if(StringCompare(entityType, functionaryType)){
            return Functionaries[entityAddress].ethPublicKey;
        }
    }

    function GetPendingIncomingRequests (
        address entityRequestedAddress,
        string memory entityType
    ) public view returns (EntityAddressToType[] memory){
        if(StringCompare(entityType, institutionType)){
            return Institutions[entityRequestedAddress].PendingIncoming.addressArray;
        }
        if(StringCompare(entityType, functionaryType)){
            return Functionaries[entityRequestedAddress].PendingIncoming.addressArray;
        }
        if(StringCompare(entityType, patientType)){
            return Patients[entityRequestedAddress].PendingIncoming.addressArray;
        }
        if(StringCompare(entityType, doctorType)){
            return Doctors[entityRequestedAddress].PendingIncoming.addressArray;
        }
    }

    function PatientAcceptInstitution(
        address institutionAddress,
        string memory encryptedStorjToken, 
        string memory permission
    ) private {
        WriteToLoopableAddressStringKeyPairList(msg.sender,encryptedStorjToken,
            Institutions[institutionAddress].EncryptedTokensCreatedByPatientsForThisEntity, permission);
        WriteToLoopableAddressStringKeyPairList(institutionAddress,encryptedStorjToken, 
            Patients[msg.sender].EncryptedTokensCreatedByThisEntityForInstitutions, permission);
        ClearFromLoopableAddressList(msg.sender, Institutions[institutionAddress].PendingOutgoing);
        ClearFromLoopableAddressList(institutionAddress, Patients[msg.sender].PendingIncoming);
    }
    function InstitutionAcceptFunctionary(
        address functionaryAddress,
        string memory encryptedStorjToken,
        string memory permission
    ) private {
        WriteToLoopableAddressStringKeyPairList(msg.sender,encryptedStorjToken,
            Functionaries[functionaryAddress].EncryptedTokensCreatedByInstitutionsForThisEntity, permission);
        WriteToLoopableAddressStringKeyPairList(functionaryAddress,encryptedStorjToken,
            Institutions[msg.sender].EncryptedTokensCreatedByThisEntityForFunctionaries, permission);
        ClearFromLoopableAddressList(msg.sender, Functionaries[functionaryAddress].PendingOutgoing);
        ClearFromLoopableAddressList(functionaryAddress, Institutions[msg.sender].PendingIncoming);
    }
    function FunctionaryAcceptFunctionary(
        address requestingFunctionaryAddress,
        string memory encryptedStorjToken,
        string memory permission
    ) private {
        WriteToLoopableAddressStringKeyPairList(msg.sender,encryptedStorjToken,
            Functionaries[requestingFunctionaryAddress].EncryptedTokensCreatedByFunctionariesForThisEntity,
            permission
        );
        WriteToLoopableAddressStringKeyPairList(requestingFunctionaryAddress,encryptedStorjToken,
            Functionaries[msg.sender].EncryptedTokensCreatedByThisEntityForFunctionaries, permission);
        ClearFromLoopableAddressList(msg.sender, Functionaries[requestingFunctionaryAddress].PendingOutgoing);
        ClearFromLoopableAddressList(requestingFunctionaryAddress, Functionaries[msg.sender].PendingIncoming);
    }

    function WriteToLoopableAddressStringKeyPairList(
        address entityAddress,
        string memory token,
        LoopableAddressStringKeyPair storage list,
        string memory permission        
    ) private {
        EntityAddressToToken memory addressToTokenToAdd;
        addressToTokenToAdd = EntityAddressToToken(entityAddress, token, permission);
        list.ArrayIndexMapping[entityAddress] = list.addressStringArray.length;
        list.addressStringArray.push(addressToTokenToAdd);
    }
    function ClearFromLoopableAddressStringKeyPairList(address entityAddress,LoopableAddressStringKeyPair storage list) private {
        delete list.ArrayIndexMapping[entityAddress];
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