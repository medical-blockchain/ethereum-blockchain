// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;

library s {
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
}