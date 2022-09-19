/*
 * Petshop.sol
 * Solidity code for the Petshop contract
 * Editor: Weixuan Yang
 * Date: August 19, 2022
 */

pragma solidity ^0.5.0;

contract Petshop {

struct Pet{
  uint _id;
  string _name;
  string _breed;
  uint _age;
  string _location;
  uint _price;
  string _image;
  uint _vote;
}

struct Supply{
  uint _id;
  string _name;
  uint _stock;
  uint _price;
  string _image;
}

uint constant petmax = 16;
uint constant supplymax = 16;
uint public petn;
uint public supplyn;
uint public ownPetTotal;
uint public userTotal;

address[petmax] public owners;
mapping(uint=>Pet) public pets;
mapping(uint=>Supply) public supplies;
mapping(address=>bool) public hasVoted;

event addPetEvent();
event OwnPetEvent();
event votePetEvent();
event addSupplyEvent();
event buySupplyEvent();

constructor() public {
/* Load the pet and pet supplies in the shop */
  addPet("Frieda", "Scottish Terrier", 3, "Lisco, Alabama", 5, "images/scottish-terrier.jpeg", 0);
  addPet("Gina", "Scottish Terrier", 3, "Tooleville, West Virginia", 3, "images/french-bulldog.jpeg", 0);
  addPet("Collins", "French Bulldog", 2, "Freeburn, Idaho", 4, "images/french-bulldog.jpeg", 0);
  addPet("Melissa", "Boxer", 2, "Camas, Pennsylvania", 4, "images/boxer.jpeg", 0);
  addSupply("Salmon Dog Food", 50, 1, "images/salmon-dog-food.jpeg");
  addSupply("Beef Dog Food", 1, 1, "images/beef-dog-food.jpeg");
}

/*
 * Pet related functions
 */

function addPet(string memory name, string memory breed, uint age, string memory location, uint price, string memory image, uint vote) private returns (uint) {
/* Add a pet to the store for buying or adopting */
  uint id = petn;
  pets[id] = Pet(id, name, breed, age, location, price, image, vote);
  petn++;
  return id;
}

function addPetPublic(string memory name, string memory breed, uint age, string memory location, uint price, string memory image) public payable returns (uint) {
/* Add a pet to the store for buying or adopting with a fee */ 
  userTotal ++;
  emit addPetEvent();
  return addPet(name, breed, age, location, price, image, 0);
}

function adoptPet(uint id) public returns (uint) {
/* Adopting a pet */
  require(id >= 0 && id <= petn, "id out of range");
  require(owners[id] == 0x0000000000000000000000000000000000000000, "owned pet cannot be adopted");
  ownPetTotal++;
  userTotal++;
  owners[id] = msg.sender;
  emit OwnPetEvent();
  return id;
}

function buyPet(uint id) public payable returns (uint) {
/* Buying a pet */
  require(id >= 0 && id <= petn, "id out of range");
  require(owners[id] == 0x0000000000000000000000000000000000000000, "owned pet cannot be bought");
  ownPetTotal ++;
  userTotal ++;
  owners[id] = msg.sender;
  emit OwnPetEvent();
  return id;
}

function votePet(uint id) public returns (uint) {
/* Voting for a pet */
  require(id >= 0 && id <= petn, "id out of range");
  require(!hasVoted[msg.sender], "voted user attempt to vote again");
  hasVoted[msg.sender] = true;
  pets[id]._vote ++; 
  emit votePetEvent();
  return id;
}

function returnPet(uint id) public payable returns (uint){
/* Returning a pet */
  require(id >= 0 && id <= 15, "id out of range");
  require(owners[id] != 0x0000000000000000000000000000000000000000, "unowned pet cannot be returned");
  owners[id] = 0x0000000000000000000000000000000000000000; 
  ownPetTotal --;
  emit OwnPetEvent();
  return id;
}

/*
 * Supply related functions
 */

function addSupply(string memory name, uint stock, uint price, string memory image) private returns (uint) {
/* Add a pet supply to the store for buying */
  uint id = supplyn;
  supplies[id] = Supply(id, name, stock, price, image);
  supplyn ++; 
  return id;
}

function addSupplyPublic(string memory name, uint stock, uint price, string memory image) public payable returns (uint) {
/* Add a pet supply to the store for buying with a fee */ 
  userTotal ++;
  emit addSupplyEvent();
  return addSupply(name, stock, price, image);
}

function buySupply(uint id) public payable returns (uint) {
/* Buying a pet supply */
  require(id >= 0 && id <= supplyn, "id out of range");
  supplies[id]._stock = supplies[id]._stock - 1;
  userTotal ++;
  emit buySupplyEvent();
  return id;
}

/*
 * Contract related functions
 */

function receiveDonation() public payable {
/* Receive donation */ 
}

/*
 * Data retrieving functions
 */

function getOwners() public view returns (address[petmax] memory) {
/* Retrieving the owners of the pets */
  return owners;
}

function getPetPrice(uint id) public view returns (uint) {
/* Retrieving the price of a pet */
  return pets[id]._price;
}

function getPetVote(uint id) public view returns (uint) {
/* Retrieving the vote count of a pet */
  return pets[id]._vote;
}

function getVoted() public view returns (bool) {
/* Retrieving if the user already voted */
  return hasVoted[msg.sender];
}

function getPetName(uint id) public view returns (string memory) {
/* Retrieving the name of a pet */
  return pets[id]._name;
}

function getSupplyPrice(uint id) public view returns (uint) {
/* Retrieving the price of a pet supply */
  return supplies[id]._price;
}

function getSupplyStock(uint id) public view returns (uint) {
/* Retrieving the stock left of a pet supply */
  return supplies[id]._stock;
}

function getSupplyName(uint id) public view returns (string memory) {
/* Retrieving the name of a pet supply */
  return supplies[id]._name;
}

}
