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
        address currentOwner;
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

    //mapping to store data on key values and addresses
    mapping(uint => Landreg) public landMapping;
    mapping(uint => LandInspector) public InspectorMapping;
    mapping(address => Buyer) public BuyerMapping;
    mapping(address => Seller) public SellerMapping;
    mapping(address => bool) private RegisteredAddressMapping;
    mapping(address => bool) private RegisteredSellersMapping;
    mapping(address => bool) private RegisteredBuyersMapping;
    mapping(address => bool) private SellerVerificationMapping;
    mapping(address => bool) private SellerRejectionMapping;
    mapping(address => bool) private BuyerRejectionMapping;
    mapping(address => bool) private BuyerVerificationMapping;
    mapping(uint => bool) private LandVerificationMapping;
   // mapping(uint => address) public LandOwner;
    mapping(uint => bool) private PaymentReceived;
    
    /*Landreg[] private lands;
    Buyer[] private _buyer;
    Seller[] private _seller;
    LandInspector[] private _landinspector;*/
    
    //who deploy the contract will be the landinspector
    address public landinspector;
    address[] private selleraddress;
    address[] private buyeraddress;

    //public variables 
    uint public land_inspectors;
    uint public landsCount;
    uint public inspectorsCount;
    uint public sellersCount;
    uint public buyersCount;

    event Registration(address _id);
    event Verified(address _id);
    event Rejected(address _id);

    constructor() payable{
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

        SellerVerificationMapping[_sellerId] = true;
        emit Verified(_sellerId);
    }
    //Seller rejection function
    function rejectSeller(address _sellerId) public Landins(){
        
        SellerRejectionMapping[_sellerId] = true;
        emit Rejected(_sellerId);
    }
    //Buyer verification function
    function verifyBuyer(address _buyerId) public Landins(){
        
        BuyerVerificationMapping[_buyerId] = true;
        emit Verified(_buyerId);
    }
    //Buyer rejection function
    function rejectBuyer(address _buyerId) public Landins(){

        BuyerRejectionMapping[_buyerId] = true;
        emit Rejected(_buyerId);
    }
    //Land verification function
    function verifyLand(uint landId) public Landins(){
        LandVerificationMapping[landId] = true;
    }
    //check weather the land is verified or not
    function isLandVerified(uint _id) public view returns (bool) {
        if(LandVerificationMapping[_id]){
            return true;
        }
    }
    //for verification of sellers or buyers
    function isVerified(address _id) public view returns (bool) {
        if(SellerVerificationMapping[_id] || BuyerVerificationMapping[_id]){
            return true;
        }
    }
    //for rejected sellers or buyers
    function isRejected(address _id) public view returns (bool) {
        if(SellerRejectionMapping[_id] || BuyerRejectionMapping[_id]){
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
         landMapping[LandId] = Landreg(LandId, Area, City, state, Landprice, PropertyPID, msg.sender);
         //LandOwner[landsCount] = msg.sender;
    }
    
    function getLandCity(uint c) public view returns (string memory){
        return landMapping[c].City;
    }
    
    function getLandPrice(uint _landId) public view returns (uint){
        return landMapping[_landId].Landprice;
    }
    
    function getLandArea(uint a) public view returns (uint){
        return landMapping[a].Area;
    }
    
    function LandSeller(address Id, string memory name, uint Age, string memory City, uint CNIC, string memory Email) public{
        RegisteredAddressMapping[Id] = true;
        RegisteredSellersMapping[Id] = true;
        SellerMapping[Id] = Seller(Id, name, Age, City, CNIC, Email);
        sellersCount++;
        selleraddress.push(Id);
        emit Registration(msg.sender);
    }

       function updateSeller(address _id, string memory _name, uint _age, string memory _city, uint _CNIC, string memory _Email) public {
        require(RegisteredAddressMapping[msg.sender] && (SellerMapping[msg.sender].Id == msg.sender));
        SellerMapping[_id].Name = _name;
        SellerMapping[_id].Age = _age;
        SellerMapping[_id].City = _city;
        SellerMapping[_id].CNIC = _CNIC;
        SellerMapping[_id].Email = _Email;

    }

    function getSeller() public view returns( address [] memory ){
        return(selleraddress);
    }
    //function to register landbuyers
    function LandBuyer(address Id, string memory name, uint Age, string memory City, uint CNIC, string memory Email) public{
        RegisteredAddressMapping[Id] = true;
        RegisteredBuyersMapping[Id] = true;
        BuyerMapping[Id] = Buyer(Id, name, Age, City, CNIC, Email);
        buyersCount++;
        buyeraddress.push(Id);
        emit Registration(msg.sender);
    }

    function updateBuyer(address _id, string memory _name, uint _age, string memory _city, uint _CNIC, string memory _Email) public {
        require(RegisteredAddressMapping[msg.sender] && (BuyerMapping[msg.sender].Id == msg.sender));
        BuyerMapping[_id].Name = _name;
        BuyerMapping[_id].Age = _age;
        BuyerMapping[_id].City = _city;
        BuyerMapping[_id].CNIC = _CNIC;
        BuyerMapping[_id].Email = _Email;

    }

    //uint landpayment;
    address payable private add; 

    /*function receives() public payable{
        //0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    }*/
    
    function Payment(uint _landId) public payable returns (bool){       
         if(BuyerVerificationMapping[msg.sender] == true){
            landMapping[_landId].currentOwner = add;
            require(landMapping[_landId].Landprice == msg.value, "please pay the full price");
            add.transfer(msg.value);
            landMapping[_landId].currentOwner = msg.sender;
        }
        else{
            return false;
        }
         /*if(PaymentReceived[_landId]){
             return true;
             LandOwner[_landId] = _Newowner;
         }*/
    }

    function getBuyer() public view returns( address [] memory ){
        return(buyeraddress);
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
    //function that change the owner of land
    function LandOwnershipTransfer(uint _landId, address _newOwner) public Landins(){
            landMapping[_landId].currentOwner = _newOwner;
       
    }

}
