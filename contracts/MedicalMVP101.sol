// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;

contract MedicalMVP101 {
    string patientType = "patient";
    string institutionType = "institution";
    string functionaryType = "functionary";

    struct PatientAccess {
        address patientAddress;
        address grantingEntityAddress;
        address grantedToEntityAddress;
        string grantingEntityType;
        string grantedToEntityType;
        string grantedEncryptedToken;
        string permission;
    }
    struct EntityAddressToToken {
        address entityAddress;
        string token;
        string permission;
    }
    struct EntityAddressToType {
        address entityAddress;
        string entityType;
    }
    struct EntityAddressToPermission {
        address entityAddress;
        string entityType;
        string permission;
    }

    struct LoopableAddressToPermission {
        mapping(address => uint256) ArrayIndexMapping;
        EntityAddressToPermission[] addressToPermissionArray;
    }
    struct LoopableAddressStringKeyPair {
        mapping(address => uint256) ArrayIndexMapping;
        EntityAddressToToken[] addressStringArray;
    }
    struct LoopableAddress {
        mapping(address => uint256) ArrayIndexMapping;
        EntityAddressToType[] addressArray;
    }
    struct LoopablePatientAccessSearchByInstitution {
        //outer address granting entity, inner address patient
        mapping(address => mapping(address => uint)) ArrayIndexMapping;
        PatientAccess[] patientAccessArray;
    }

    struct PatientInfo {
        LoopablePatientAccessSearchByInstitution EncryptedAccessCreatedByThisEntityForInstitutions;
        LoopableAddressStringKeyPair EncryptedTokensCreatedByThisEntityForInstitutions;
        LoopableAddress PendingOutgoing;
        LoopableAddress PendingIncoming;
        LoopableAddress entitiesRevokedByThisEntity;
        LoopableAddress entitiesRejectedByThisEntity;
        LoopableAddress entiesThatRevokedThisEntity;
        LoopableAddress entiesThatRejectedThisEntity;
        string encryptedStorjToken;
        string ethPublicKey;
    }
    struct InstitutionInfo {
        PatientAccess[] NewPatientConfirmationInbox;
        LoopableAddressStringKeyPair EncryptedTokensCreatedByPatientsForThisEntity;
        LoopableAddressToPermission FunctionariesApprovedByThisEntity;
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
        PatientAccess[] NewPatientConfirmationInbox;
        LoopableAddressToPermission InstitutionsThatApprovedThisEntity;    
        LoopableAddressToPermission FunctionariesThatApprovedThisEntity;
        LoopableAddressToPermission FunctionariesApprovedByThisEntity;
        LoopableAddress PendingOutgoing;
        LoopableAddress PendingIncoming;
        LoopableAddress entitiesRevokedByThisEntity;
        LoopableAddress entitiesRejectedByThisEntity;
        LoopableAddress entiesThatRevokedThisEntity;
        LoopableAddress entiesThatRejectedThisEntity;
        string encryptedStorjToken;
        string ethPublicKey;
    }

    mapping(address => InstitutionInfo) Institutions;
    mapping(address => PatientInfo) Patients;
    mapping(address => FunctionaryInfo) Functionaries;
    mapping(address => string) AddressToPublicKey;

    function CreateEntity(string memory ethPublicKey,string memory encryptedStorjToken, string memory entityType) public {
        if(StringCompare(entityType, patientType)){
            Patients[msg.sender].ethPublicKey = ethPublicKey;
            Patients[msg.sender].encryptedStorjToken = encryptedStorjToken;
        }
        if(StringCompare(entityType, institutionType)){
            Institutions[msg.sender].ethPublicKey = ethPublicKey;
            Institutions[msg.sender].encryptedStorjToken = encryptedStorjToken;
        }
        if(StringCompare(entityType, functionaryType)){
            Functionaries[msg.sender].ethPublicKey = ethPublicKey;
            Functionaries[msg.sender].encryptedStorjToken = encryptedStorjToken;
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
            InstitutionAcceptFunctionary(senderEntityAddress,permission);
        }
        if(StringCompare(senderEntityType, functionaryType) && StringCompare(acceptorEntityType, functionaryType)){
            FunctionaryAcceptFunctionary(senderEntityAddress,permission);
        }
    }
    function InstitutionApplyAccessFromNewPatientInbox() public{
        PatientAccess[] memory newPatientConfirmationInbox = Institutions[msg.sender].NewPatientConfirmationInbox;

        for (uint i=0; i<newPatientConfirmationInbox.length; i++) {
            WriteToLoopableAddressStringKeyPairList(
                newPatientConfirmationInbox[i].patientAddress,
                newPatientConfirmationInbox[i].grantedEncryptedToken,
                Institutions[msg.sender].EncryptedTokensCreatedByPatientsForThisEntity, newPatientConfirmationInbox[i].permission
            );            
        }
        delete Institutions[msg.sender].NewPatientConfirmationInbox;
    }
    function FunctionaryApplyAccessFromNewPatientInbox() public{
        PatientAccess[] memory newPatientConfirmationInbox = Functionaries[msg.sender].NewPatientConfirmationInbox;

        for (uint i=0; i<newPatientConfirmationInbox.length; i++) {
            if(StringCompare(newPatientConfirmationInbox[i].grantingEntityType, institutionType)){
                WriteToLoopableAddressToPermission(
                    EntityAddressToPermission(
                        newPatientConfirmationInbox[i].grantingEntityAddress,
                        newPatientConfirmationInbox[i].grantedToEntityType,
                        newPatientConfirmationInbox[i].permission
                    ), 
                    Functionaries[msg.sender].InstitutionsThatApprovedThisEntity
                );  
            }
            if(StringCompare(newPatientConfirmationInbox[i].grantingEntityType, functionaryType)){
                WriteToLoopableAddressToPermission(
                    EntityAddressToPermission(
                        newPatientConfirmationInbox[i].grantingEntityAddress,
                        newPatientConfirmationInbox[i].grantedToEntityType,
                        newPatientConfirmationInbox[i].permission
                    ), 
                    Functionaries[msg.sender].FunctionariesThatApprovedThisEntity
                );   
            }          
        }
        delete Functionaries[msg.sender].NewPatientConfirmationInbox;
    }
    function SendToNewPatientInbox(
        address patientAddress,
        address grantingEntityAddress,
        address grantedToEntityAddress,
        string memory grantingEntityType,
        string memory grantedToEntityType,
        string memory grantedEncryptedToken,
        string memory permission
    ) public {
        PatientAccess memory newPatient = PatientAccess(patientAddress, grantingEntityAddress, grantedToEntityAddress, grantingEntityType, grantedToEntityType,grantedEncryptedToken,permission);
        Functionaries[grantedToEntityAddress].NewPatientConfirmationInbox.push(newPatient);
    }

    function GetEncryptedStorjToken(address entityAddress, string memory entityType) public view returns (string memory) {
        if(StringCompare(entityType, patientType)){
            return Patients[entityAddress].encryptedStorjToken;
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
    }
    function GetApprovedFunctionariesForInstitution() public view returns (EntityAddressToPermission[] memory){
        return Institutions[msg.sender].FunctionariesApprovedByThisEntity.addressToPermissionArray;
    }
    function GetNewPatientConfirmationInboxForInstitution() public view returns (PatientAccess[] memory){
        return Institutions[msg.sender].NewPatientConfirmationInbox;
    }
    function GetExistingPatientsForInstitution() public view returns (EntityAddressToToken[] memory){
        return Institutions[msg.sender].EncryptedTokensCreatedByPatientsForThisEntity.addressStringArray;
    }
    function GetApprovedFunctionariesForFunctionary() public view returns (EntityAddressToPermission[] memory){
        return Functionaries[msg.sender].FunctionariesApprovedByThisEntity.addressToPermissionArray;
    }
    function GetNewPatientConfirmationInboxForFunctionary() public view returns (PatientAccess[] memory){
        return Functionaries[msg.sender].NewPatientConfirmationInbox;
    }

    function PatientAcceptInstitution(
        address institutionAddress,
        string memory encryptedStorjToken, 
        string memory permission
    ) private {
        PatientAccess memory newPatientAccess;
        newPatientAccess = PatientAccess(msg.sender, msg.sender, institutionAddress,  patientType, institutionType, encryptedStorjToken, permission);
        Institutions[institutionAddress].NewPatientConfirmationInbox.push(newPatientAccess);
        WriteToLoopableAddressStringKeyPairList(institutionAddress, encryptedStorjToken, 
            Patients[msg.sender].EncryptedTokensCreatedByThisEntityForInstitutions, permission);
        ClearFromLoopableAddressList(msg.sender, Institutions[institutionAddress].PendingOutgoing);
        ClearFromLoopableAddressList(institutionAddress, Patients[msg.sender].PendingIncoming);
    }
    function InstitutionAcceptFunctionary(
        address functionaryAddress,
        string memory permission
    ) private returns (EntityAddressToToken[] memory) {
        WriteToLoopableAddressToPermission(
            EntityAddressToPermission(functionaryAddress, functionaryType, permission),
            Institutions[msg.sender].FunctionariesApprovedByThisEntity
        );
        WriteToLoopableAddressToPermission(
            EntityAddressToPermission(msg.sender, functionaryType, permission),
            Functionaries[functionaryAddress].InstitutionsThatApprovedThisEntity
        );
        ClearFromLoopableAddressList(functionaryAddress, Functionaries[msg.sender].PendingOutgoing);
        ClearFromLoopableAddressList(msg.sender, Institutions[msg.sender].PendingIncoming);
        return Institutions[msg.sender].EncryptedTokensCreatedByPatientsForThisEntity.addressStringArray;
        //institution client will 
        // (1) take this array, 
        // (2) unencrypt, 
        // (3) create access, 
        // (4) recrypt, and finally, 
        // (5) send to functioanry inbox
    }
    function FunctionaryAcceptFunctionary(
        address requestingFunctionaryAddress,
        string memory permission
    ) private {
        WriteToLoopableAddressToPermission(
            EntityAddressToPermission(requestingFunctionaryAddress, functionaryType, permission),
            Functionaries[msg.sender].FunctionariesApprovedByThisEntity
        );
        WriteToLoopableAddressToPermission(
            EntityAddressToPermission(msg.sender, functionaryType, permission),
            Functionaries[requestingFunctionaryAddress].FunctionariesApprovedByThisEntity
        );
        ClearFromLoopableAddressList(requestingFunctionaryAddress, Functionaries[msg.sender].PendingOutgoing);
        ClearFromLoopableAddressList(msg.sender, Functionaries[msg.sender].PendingIncoming);
        //functionary client will have to get it's 
        // (1) patient token array, 
        // (2) unencrypt, 
        // (3) create access, 
        // (4) recrypt, and finally, 
        // (5) send to functionary inbox
    }
    
    function WriteToLoopablePatientAccess(
        PatientAccess memory patientAccess,
        LoopablePatientAccessSearchByInstitution storage list
    ) private{
        list.patientAccessArray.push(patientAccess);
        list.ArrayIndexMapping[patientAccess.grantingEntityAddress][patientAccess.patientAddress] = list.patientAccessArray.length;
    }
    function WriteToLoopableAddressToPermission(
        EntityAddressToPermission memory addressToPermission,
        LoopableAddressToPermission storage list
    ) private {
        list.addressToPermissionArray.push(addressToPermission);
        list.ArrayIndexMapping[addressToPermission.entityAddress] = list.addressToPermissionArray.length;
    }
    function WriteToLoopableAddressStringKeyPairList(
        address entityAddress,
        string memory token,
        LoopableAddressStringKeyPair storage list,
        string memory permission        
    ) private {
        EntityAddressToToken memory addressToTokenToAdd;
        addressToTokenToAdd = EntityAddressToToken(entityAddress, token, permission);
        list.addressStringArray.push(addressToTokenToAdd);
        list.ArrayIndexMapping[entityAddress] = list.addressStringArray.length;
    }
    function ClearFromLoopableAddressStringKeyPairList(address entityAddress,LoopableAddressStringKeyPair storage list) private {
        delete list.ArrayIndexMapping[entityAddress];
        uint256 arrayIndexLocation;
        arrayIndexLocation = list.ArrayIndexMapping[entityAddress];
        list.addressStringArray[arrayIndexLocation].token = "NA";
    }
    function WriteToLoopableAddressList(address entityAddress,string memory entityType, LoopableAddress storage list) private {
        list.addressArray.push(EntityAddressToType(entityAddress, entityType));
        list.ArrayIndexMapping[entityAddress] = list.addressArray.length;
    }
    function ClearFromLoopableAddressList(address entityAddress,LoopableAddress storage list) private {
        uint256 arrayIndexLocation;
        arrayIndexLocation = list.ArrayIndexMapping[entityAddress];
        list.addressArray[arrayIndexLocation] = EntityAddressToType(0x0000000000000000000000000000000000000000, 'NA');
    }

    function StringCompare(string memory value1, string memory value2) private pure returns (bool){
        if(keccak256(abi.encodePacked(value1)) == keccak256(abi.encodePacked(value2))){
            return true;
        } else {
            return false;
        }
    }
}