pragma experimental ABIEncoderV2;

contract Counter {    
    mapping (address => mapping(address => string)) PatientToDoctor;

    function Set(address doctorAddress, string memory token) public returns(bool){
        PatientToDoctor[msg.sender][doctorAddress] = token;
        return true;
    }

    function Get(address patientAddress, address doctorAddress) external view returns(string memory){
       return PatientToDoctor[patientAddress][doctorAddress];
    }
}

//local test wallet: 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1