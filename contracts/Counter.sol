pragma experimental ABIEncoderV2;

contract Counter {    
    mapping (address => mapping(address => string)) PatientToDoctor;
    mapping (address => address[]) PatientToDoctorPending;

    function Set(address doctorAddress, string memory token) public returns(bool){
        PatientToDoctor[msg.sender][doctorAddress] = token;
        return true;
    }

    function Get(address patientAddress, address doctorAddress) external view returns(string memory){
       return PatientToDoctor[patientAddress][doctorAddress];
    }

    function SetPending(address doctorAddress) public returns(bool){
        PatientToDoctorPending[msg.sender].push(doctorAddress);
        return true;
    }

    function GetAllPending(address patientAddress) public view returns(address[] memory){
        return PatientToDoctorPending[patientAddress];
    }

    function DeleteAllPending(address patientAddress) public returns(bool){
        delete PatientToDoctorPending[patientAddress];
        return true;
    }
}

//local test wallet: 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1