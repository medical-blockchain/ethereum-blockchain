// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {s} from './StructLib.sol';  // imported 

contract MedicalMVP102 {
    
    string pType = "patient";
    string iType = "institution";
    string fType = "functionary";

    mapping(address => s.InstitutionInfo) Institutions;
    mapping(address => s.PatientInfo) Patients;
    mapping(address => s.FunctionaryInfo) Functionaries;
    mapping(address => string) AddressToPublicKey;

    function CreateEntity(string memory ethPublicKey,string memory encryptedStorjToken, string memory entityType) public {
        if(StringCompare(entityType, pType)){
            Patients[msg.sender].ethPublicKey = ethPublicKey;
            Patients[msg.sender].encryptedStorjToken = encryptedStorjToken;
        }
        if(StringCompare(entityType, iType)){
            Institutions[msg.sender].ethPublicKey = ethPublicKey;
            Institutions[msg.sender].encryptedStorjToken = encryptedStorjToken;
        }
        if(StringCompare(entityType, fType)){
            Functionaries[msg.sender].ethPublicKey = ethPublicKey;
            Functionaries[msg.sender].encryptedStorjToken = encryptedStorjToken;
        }

    }
    function RequestAccess(
        address toEntityAddress, 
        string memory fromEntityType,
        string memory toEntityType) 
        public {
            if(StringCompare(fromEntityType, fType) && StringCompare(toEntityType, fType)){
                WriteToLoopableAddressList(msg.sender, fType,  Functionaries[toEntityAddress].PendingIncoming);
                WriteToLoopableAddressList(toEntityAddress,fType, Functionaries[msg.sender].PendingOutgoing);
            }
            if(StringCompare(fromEntityType, fType) && StringCompare(toEntityType, iType)){
                WriteToLoopableAddressList(msg.sender,fromEntityType,Institutions[toEntityAddress].PendingIncoming);
                WriteToLoopableAddressList(toEntityAddress, toEntityType,Functionaries[msg.sender].PendingOutgoing);
            }
            if(StringCompare(fromEntityType, iType) && StringCompare(toEntityType, pType)){
                WriteToLoopableAddressList(msg.sender, fromEntityType,  Patients[toEntityAddress].PendingIncoming);
                WriteToLoopableAddressList(toEntityAddress,toEntityType, Institutions[msg.sender].PendingOutgoing);
            }
    }
    function AcceptAccessRequest(
        address senderEntityAddress, 
        string memory senderEntityType, 
        string memory acceptorEntityType,
        string memory encryptedStorjToken,
        string memory permission
    ) public {
        if(StringCompare(senderEntityType, iType) && StringCompare(acceptorEntityType, pType)){
            PatientAcceptInstitution(senderEntityAddress,encryptedStorjToken,permission);
        }
        if(StringCompare(senderEntityType, fType) && StringCompare(acceptorEntityType, iType)){
            InstitutionAcceptFunctionary(senderEntityAddress,permission);
        }
        if(StringCompare(senderEntityType, fType) && StringCompare(acceptorEntityType, fType)){
            FunctionaryAcceptFunctionary(senderEntityAddress,permission);
        }
    }
    function InstitutionApplyAccessFromNewPatientInbox() public{
        s.PatientAccess[] memory newPatientConfirmationInbox = Institutions[msg.sender].NewPatientConfirmationInbox;

        for (uint i=0; i<newPatientConfirmationInbox.length; i++) {
            WriteToLoopableAddressStringKeyPairList(
                newPatientConfirmationInbox[i].patientAddress,
                newPatientConfirmationInbox[i].grantedEncryptedToken,
                Institutions[msg.sender].EncryptedTokensCreatedByPatientsForThisEntity, newPatientConfirmationInbox[i].permission
            );            
        }
        delete Institutions[msg.sender].NewPatientConfirmationInbox;
    }
    function ClearFunctionariesInbox() public{
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
        s.PatientAccess memory newPatient = s.PatientAccess(patientAddress, grantingEntityAddress, grantedToEntityAddress, grantingEntityType, grantedToEntityType,grantedEncryptedToken,permission);
        Functionaries[grantedToEntityAddress].NewPatientConfirmationInbox.push(newPatient);
    }

    function GetEncryptedStorjToken(address entityAddress, string memory entityType) public view returns (string memory) {
        if(StringCompare(entityType, pType)){
            return Patients[entityAddress].encryptedStorjToken;
        }
        if(StringCompare(entityType, iType)){
            return Institutions[entityAddress].encryptedStorjToken;
        }
        if(StringCompare(entityType, fType)){
            return Functionaries[entityAddress].encryptedStorjToken;
        }
    }
    function GetPublicKeyFromAddress(address entityAddress, string memory entityType) public view returns (string memory) {
        if(StringCompare(entityType, pType)){
            return Patients[entityAddress].ethPublicKey;
        }
        if(StringCompare(entityType, iType)){
            return Institutions[entityAddress].ethPublicKey;
        }
        if(StringCompare(entityType, fType)){
            return Functionaries[entityAddress].ethPublicKey;
        }
    }
    function GetPendingIncomingRequests (
        address entityRequestedAddress,
        string memory entityType
    ) public view returns (s.EntityAddressToType[] memory){
        if(StringCompare(entityType, iType)){
            return Institutions[entityRequestedAddress].PendingIncoming.addressArray;
        }
        if(StringCompare(entityType, fType)){
            return Functionaries[entityRequestedAddress].PendingIncoming.addressArray;
        }
        if(StringCompare(entityType, pType)){
            return Patients[entityRequestedAddress].PendingIncoming.addressArray;
        }
    }
    function GetApprovedFunctionariesForInstitution(address entityAddress) public view returns (s.EntityAddressToPermission[] memory){
        return Institutions[entityAddress].FunctionariesApprovedByThisEntity.addressToPermissionArray;
    }
    function GetNewPatientConfirmationInboxForInstitution(address entityAddress) public view returns (s.PatientAccess[] memory){
        return Institutions[entityAddress].NewPatientConfirmationInbox;
    }
    function GetExistingPatientsForInstitution(address entityAddress) public view returns (s.EntityAddressToToken[] memory){
        return Institutions[entityAddress].EncryptedTokensCreatedByPatientsForThisEntity.addressStringArray;
    }
    function GetApprovedFunctionariesForFunctionary(address entityAddress) public view returns (s.EntityAddressToPermission[] memory){
        return Functionaries[entityAddress].FunctionariesApprovedByThisEntity.addressToPermissionArray;
    }
    function GetNewPatientConfirmationInboxForFunctionary(address entityAddress) public view returns (s.PatientAccess[] memory){
        return Functionaries[entityAddress].NewPatientConfirmationInbox;
    }
    function GetConfirmedInstitutionsForPatient(address entityAddress) public view returns (s.EntityAddressToToken[] memory){
        return Patients[entityAddress].EncryptedTokensCreatedByThisEntityForInstitutions.addressStringArray;
    }

    function PatientAcceptInstitution(
        address institutionAddress,
        string memory encryptedStorjToken, 
        string memory permission
    ) private {
        s.PatientAccess memory newPatientAccess;
        newPatientAccess = s.PatientAccess(msg.sender, msg.sender, institutionAddress,  pType, iType, encryptedStorjToken, permission);
        Institutions[institutionAddress].NewPatientConfirmationInbox.push(newPatientAccess);
        WriteToLoopableAddressStringKeyPairList(institutionAddress, encryptedStorjToken, 
            Patients[msg.sender].EncryptedTokensCreatedByThisEntityForInstitutions, permission);
        ClearFromLoopableAddressList(msg.sender, Institutions[institutionAddress].PendingOutgoing);
        ClearFromLoopableAddressList(institutionAddress, Patients[msg.sender].PendingIncoming);
    }
    function InstitutionAcceptFunctionary(
        address functionaryAddress,
        string memory permission
    ) private returns (s.EntityAddressToToken[] memory) {
        WriteToLoopableAddressToPermission(
            s.EntityAddressToPermission(functionaryAddress, fType, permission),
            Institutions[msg.sender].FunctionariesApprovedByThisEntity
        );
        WriteToLoopableAddressToPermission(
            s.EntityAddressToPermission(msg.sender, fType, permission),
            Functionaries[functionaryAddress].InstitutionsThatApprovedThisEntity
        );
        ClearFromLoopableAddressList(msg.sender, Functionaries[functionaryAddress].PendingOutgoing);
        ClearFromLoopableAddressList(functionaryAddress, Institutions[msg.sender].PendingIncoming);
        return Institutions[msg.sender].EncryptedTokensCreatedByPatientsForThisEntity.addressStringArray;
    }
    function FunctionaryAcceptFunctionary(
        address requestingFunctionaryAddress,
        string memory permission
    ) private {
        WriteToLoopableAddressToPermission(
            s.EntityAddressToPermission(requestingFunctionaryAddress, fType, permission),
            Functionaries[msg.sender].FunctionariesApprovedByThisEntity
        );
        WriteToLoopableAddressToPermission(
            s.EntityAddressToPermission(msg.sender, fType, permission),
            Functionaries[requestingFunctionaryAddress].FunctionariesApprovedByThisEntity
        );
        ClearFromLoopableAddressList(requestingFunctionaryAddress, Functionaries[msg.sender].PendingOutgoing);
        ClearFromLoopableAddressList(msg.sender, Functionaries[msg.sender].PendingIncoming);
    }
    
    function WriteToLoopablePatientAccess(
        s.PatientAccess memory patientAccess,
        s.LoopablePatientAccessSearchByInstitution storage list
    ) private{
        list.patientAccessArray.push(patientAccess);
        list.ArrayIndexMapping[patientAccess.grantingEntityAddress][patientAccess.patientAddress] = list.patientAccessArray.length;
    }
    function WriteToLoopableAddressToPermission(
        s.EntityAddressToPermission memory addressToPermission,
        s.LoopableAddressToPermission storage list
    ) private {
        list.addressToPermissionArray.push(addressToPermission);
        list.ArrayIndexMapping[addressToPermission.entityAddress] = list.addressToPermissionArray.length;
    }
    function WriteToLoopableAddressStringKeyPairList(
        address entityAddress,
        string memory token,
        s.LoopableAddressStringKeyPair storage list,
        string memory permission        
    ) private {
        list.addressStringArray.push(s.EntityAddressToToken(entityAddress, token, permission));
        list.ArrayIndexMapping[entityAddress] = list.addressStringArray.length-1;
    }
    function WriteToLoopableAddressList(address entityAddress,string memory entityType, s.LoopableAddress storage list) private {
        if((list.ArrayIndexMapping[entityAddress]!=uint(0))||
        ((list.addressArray.length==uint(1))&&(list.addressArray[0].entityAddress==entityAddress))){return;}

        list.addressArray.push(s.EntityAddressToType(entityAddress, entityType));
        list.ArrayIndexMapping[entityAddress] = list.addressArray.length-1;
    }
    function ClearFromLoopableAddressStringKeyPairList(address entityAddress,s.LoopableAddressStringKeyPair storage list) private {
        delete list.ArrayIndexMapping[entityAddress];
        uint256 arrayIndexLocation;
        arrayIndexLocation = list.ArrayIndexMapping[entityAddress];
        list.addressStringArray[arrayIndexLocation].token = "NA";
    }
    function ClearFromLoopableAddressList(address entityAddress,s.LoopableAddress storage list) private {
        uint256 arrayIndexLocation;
        arrayIndexLocation = list.ArrayIndexMapping[entityAddress];
        list.addressArray[arrayIndexLocation] = s.EntityAddressToType(0x0000000000000000000000000000000000000000, 'NA');
    }

    function StringCompare(string memory value1, string memory value2) private pure returns (bool){
        if(keccak256(abi.encodePacked(value1)) == keccak256(abi.encodePacked(value2))){
            return true;
        } else {
            return false;
        }
    }
}