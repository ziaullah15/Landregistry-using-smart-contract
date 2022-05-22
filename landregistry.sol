// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract LandRegistry{
   
    struct Landreg{
        uint LandId;
        uint Area;
        string City;
        string State;
        uint Landprice;
        uint PropertyPID;
    }

    struct Buyer{
        address Id;
        string Name;
        uint Age;
        string City;
        uint CNIC;
        string Email;
    }

    struct Seller{
        address Id;
        string Name;
        uint Age;
        string City;
        uint CNIC;
        string Email;
    }

    struct LandInspector{
        uint Id;
        string Name;
        uint Age;
        string Designation;
    }

    //mapping to store data on key values
    mapping(uint => Landreg) public land;
    mapping(uint => LandInspector) public InspectorMapping;
    mapping(address => Buyer) public BuyerMapping;
    mapping(address => Seller) public SellerMapping;
    mapping(address => bool) public RegisteredAddressMapping;
    mapping(address => bool) public RegisteredSellersMapping;
    mapping(address => bool) public RegisteredBuyersMapping;
    mapping(address => bool) public SellerVerification;
    mapping(address => bool) public SellerRejection;
    mapping(address => bool) public BuyerVerification;
    mapping(address => bool) public BuyerRejection;
    mapping(uint => bool) public LandVerification;
    mapping(uint => address) public LandOwner;
    
    /*Landreg[] private lands;
    Buyer[] private _buyer;
    Seller[] private _seller;
    LandInspector[] private _landinspector;*/
    
    //who deploy the contract will be the landinspector
    address public landinspector;
    address[] public sellers;
    address[] public buyers;

    //public variables 
    uint public land_inspectors;
    uint public landsCount;
    uint public inspectorsCount;
    uint public sellersCount;
    uint public buyersCount;

    event Registration(address _registrationId);
    event AddingLand(uint indexed _landId);
    event Verified(address _id);
    event Rejected(address _id);

    constructor() public{
        landinspector = msg.sender;
    }

    //modifier for Landinspector address
    modifier Landins(){
        require(msg.sender == landinspector , "");
        _;
    }

    //Adding Landinspectors
    function addLandInspector(string memory _name, uint _age, string memory _designation) private {
        land_inspectors++;
        inspectorsCount++;
        InspectorMapping[land_inspectors] = LandInspector(land_inspectors, _name, _age, _designation);
    }
    //Seller verification function
    function verifySeller(address _sellerId) public Landins(){

        SellerVerification[_sellerId] = true;
        emit Verified(_sellerId);
    }
    //Seller rejection function
    function rejectSeller(address _sellerId) public Landins(){
        
        SellerRejection[_sellerId] = true;
        emit Rejected(_sellerId);
    }
    //Buyer verification function
    function verifyBuyer(address _buyerId) public Landins(){
        
        BuyerVerification[_buyerId] = true;
        emit Verified(_buyerId);
    }
    //Buyer rejection function
    function rejectBuyer(address _buyerId) public Landins(){

        BuyerRejection[_buyerId] = true;
        emit Rejected(_buyerId);
    }
    //Land verification function
    function verifyLand(uint landId) public Landins(){
        LandVerification[landId] = true;
    }
    //check weather the land is verified or not
    function isLandVerified(uint _id) public view returns (bool) {
        if(LandVerification[_id]){
            return true;
        }
    }
    //for verification of sellers or buyers
    function isVerified(address _id) public view returns (bool) {
        if(SellerVerification[_id] || BuyerVerification[_id]){
            return true;
        }
    }
    //for rejected sellers or buyers
    function isRejected(address _id) public view returns (bool) {
        if(SellerRejection[_id] || BuyerRejection[_id]){
            return true;
        }
    }
    //check the seller is registered or not
    function isSellerReg(address _id) public view returns (bool) {
        if(RegisteredSellersMapping[_id]){
            return true;
        }
    }

    //check landinspector is registered on mapping or not
    function isLandInspectorReg(address _id) public view returns (bool) {
        if(landinspector == _id){
            return true;
        }
        else{
            return false;
        }
    }

    //check whether the buyer is registered
    function isBuyerReg(address _id) public view returns (bool) {
        if(RegisteredBuyersMapping[_id]){
            return true;
        }
    }
    //function to check registered addresses
    function isAddressReg(address _id) public view returns (bool) {
        if(RegisteredAddressMapping[_id]){
            return true;
        }
    }

    
    //Land registeration by verified seller
    function RegisterLand(uint LandId , uint Area, string memory City, string memory state, uint Landprice, uint PropertyPID) public{
        //lands.push(Landreg(LandId, Area, City, state, Landprice, PropertyPID)); 
        require((isSellerReg(msg.sender)) && (isVerified(msg.sender)));  
         landsCount++;
         land[LandId] = Landreg(LandId, Area, City, state, Landprice, PropertyPID);
         LandOwner[landsCount] = msg.sender;
    }
    
    function getLandCity(uint c) public view returns (string memory){
        return land[c].City;
    }
    
    function getLandPrice(uint p) public view returns (uint){
        return land[p].Landprice;
    }
    
    function getLandArea(uint a) public view returns (uint){
        return land[a].Area;
    }
    
    function LandSeller(address Id, string memory name, uint Age, string memory City, uint CNIC, string memory Email) public{
        RegisteredAddressMapping[Id] = true;
        RegisteredSellersMapping[Id] = true;
        SellerMapping[Id] = Seller(Id, name, Age, City, CNIC, Email);
        sellersCount++;
        sellers.push(Id);
        emit Registration(msg.sender);
    }

       function updateSeller(address _id, string memory _name, uint _age, string memory _city, uint _CNIC, string memory _Email) public {
        //require that Seller address is already registered
        require(RegisteredAddressMapping[msg.sender] && (SellerMapping[msg.sender].Id == msg.sender));

        SellerMapping[_id].Name = _name;
        SellerMapping[_id].Age = _age;
        SellerMapping[_id].City = _city;
        SellerMapping[_id].CNIC = _CNIC;
        SellerMapping[_id].Email = _Email;

    }

    function getSeller() public view returns( address [] memory ){
        return(sellers);
    }
    //function to register landbuyers
    function LandBuyer(address Id, string memory name, uint Age, string memory City, uint CNIC, string memory Email) public{
        RegisteredAddressMapping[Id] = true;
        RegisteredBuyersMapping[Id] = true;
        BuyerMapping[Id] = Buyer(Id, name, Age, City, CNIC, Email);
        buyersCount++;
        buyers.push(Id);
        emit Registration(msg.sender);
    }

    function updateBuyer(address _id, string memory _name, uint _age, string memory _city, uint _CNIC, string memory _Email) public {
        //require that buyer address is already registered   
        require(RegisteredAddressMapping[msg.sender] && (BuyerMapping[msg.sender].Id == msg.sender));
        BuyerMapping[_id].Name = _name;
        BuyerMapping[_id].Age = _age;
        BuyerMapping[_id].City = _city;
        BuyerMapping[_id].CNIC = _CNIC;
        BuyerMapping[_id].Email = _Email;

    }

    function getBuyer() public view returns( address [] memory ){
        return(buyers);
    }

    function Landinspector(uint Id, string memory name, uint Age, string memory Designation) public{
        InspectorMapping[Id] = LandInspector(Id, name, Age, Designation);
    }

    function getLandsCount() public view returns (uint) {
        return landsCount;
    }

    function getBuyersCount() public view returns (uint) {
        return buyersCount;
    }

    function getSellersCount() public view returns (uint) {
        return sellersCount;
    }
    //function that change the owner of land after selling
    function LandOwnershipTransfer(uint _landId, address _newOwner) public Landins(){

        LandOwner[_landId] = _newOwner;
    }

}
